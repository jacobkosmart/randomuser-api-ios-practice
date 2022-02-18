# RandomUserApi-ios-practice

<!-- ! gif 스크린샷 -->

## 📌 Main Features

- Swift UI 에서 Alamofire 을 통한 API 통신

- 사용 API: RandomUSer.me - https://randomuser.me/documentation

- Combine 을 이용해 비동기 통신 처리

- 이미지 라이브러리: URLImage

- Infinite Scroll 무한 스크롤 기능 구현

- RefreshControl 당겨서 새로고침 기능 구현

## 👉 Swift Package manager -->

### 🔶 URLImage

> https://github.com/dmytro-anokhin/url-image#installation

### 🔶 Alamofire

> https://github.com/Alamofire/Alamofire.git

## 🔷 Model

```swift
// MARK: -  MODEL

struct RandomUser: Codable, Identifiable {
var id = UUID()
var name: Name
var photo: Photo

// Jaon 에서 picture 인데 parsing 할때 photo 로 이름 을 바꿔 줌: CodingKey
private enum CodingKeys: String, CodingKey {
	case name = "name"
	case photo = "picture"
}
// preview 사용을 위한 dummy data 생성
static func getDummy() -> Self {
	print(#fileID, #function, #line, "")
	return RandomUser(name: Name.getDummy(), photo: Photo.getDummy())
}

// randomUser 의 profileImage 를 가져오기
var profileImageUrl : URL {
	get {
		URL(string: photo.medium)!
	}
}
}


struct Name: Codable, CustomStringConvertible {
var title: String
var first: String
var last: String

// title, frist, last name 이 합쳐진 형식의 fullName 생성
var fullName: String {
	return "[\(title)]. \(first) \(last)"
}
static func getDummy() -> Self {
	print(#fileID, #function, #line, "")
	return Name(title: "Mr", first: "Jacob", last: "Ko")
}
}

struct Photo: Codable {
var large: String
var medium: String
var thumbnail: String
static func getDummy() -> Self {
	print(#fileID, #function, #line, "")
	return Photo(large: "https://randomuser.me/api/portraits/men/87.jpg", medium: "https://randomuser.me/api/portraits/men/87.jpg", thumbnail: "https://randomuser.me/api/portraits/men/87.jpg")
}
}


struct Info: Codable {
var seed: String
var resultsCount: Int
var page: Int
var version: String
private enum CodingKeys: String, CodingKey {
	case seed = "seed"
	case resultsCount = "results"
	case page = "page"
	case version = "version"
}
}


struct RandomUserResponse: Codable, CustomStringConvertible {
var results: [RandomUser]
var info: Info

// description 생성
var description: String {
	return "results.count: \(results.count) / info: \(info.seed)"
}
}

```

### 🔷 Part 1.RandomUser API 호출 하기

```swift
import Foundation
import Combine
import Alamofire

// MARK: -  VIEWMODEL

class RandomUserViewModel: ObservableObject {
	// MARK: -  Properties
	// 나중에 메모리에서 날리기 위해서 subscription 생성
	var subscription = Set<AnyCancellable>()

	// randomUsers 빈 배열 생성 - 받아온 데이터 저장 공간
	@Published var randomUsers = [RandomUser]()

	// 호출할 API 주소
	var baseUrl = "https://randomuser.me/api/?results=100"

// ViewModel 이 생성이 될때 API 를 fetch  하게 함
init() {
	// code 자동 완성
	print(#fileID, #function, #line, "")
	fetchRandomUser()
}

// MARK: -  FUNCTION
func fetchRandomUser() {
	print(#fileID, #function, #line, "")
	AF.request(baseUrl)
		.publishDecodable(type: RandomUserResponse.self)
	// combine 에서 옵셔널을 제거 : compatMap 을 사용해서 optional 일 경우에 값이 있는 경우에것만 값으로 가져옴 -> unwrapping 이 자동으로 됨
		.compactMap{ $0.value }
	// RandomUserResponse 에서 그안에 results 만 가져오게 map 하기
		.map { $0.results }
	// sink 를 해서 구독을 해줌
		.sink { completion in
			print("데이터 가져오기 성공")
		} receiveValue: { (receivedValue: [RandomUser]) in
			print("받은 값 : \(receivedValue.count)")
			self.randomUsers = receivedValue
		}
	// 구독이 완료되면 메모리에서 지워줌
		.store(in: &subscription)
}
}

```

#### 🔶 UI

```swift
// in ContentView.swift
import SwiftUI

struct ContentView: View {
// MARK: -  PROPERTY

@ObservedObject var randomUserViewModel = RandomUserViewModel()

// MARK: -  BODY
var body: some View {

	List(randomUserViewModel.randomUsers) { aRandomUser in
		RandomUserRowView(aRandomUser)
	}
}
}
```

```swift
// in RandomUserRowView.swift

import SwiftUI

struct RandomUserRowView: View {
	// MARK: -  PROPERTY

	var randomUser : RandomUser

	init(_ randomUser: RandomUser) {
		self.randomUser = randomUser
	}

	// MARK: -  BODY
	var body: some View {
		HStack {
			ProfileImageView(imageUrl: randomUser.profileImageUrl)
			Text(randomUser.name.fullName)
				.fontWeight(.heavy)
				.font(.title)
				.lineLimit(2)
				.minimumScaleFactor(0.5)
		} //: HSTACK
		.frame(minWidth:0, maxWidth: .infinity, minHeight: 0, maxHeight: 50 , alignment: .leading)
	}
}

// MARK: -  PREVIEW
struct RandomUserRowView_Previews: PreviewProvider {
	static var previews: some View {
		RandomUserRowView(RandomUser.getDummy())
	}
}

```

```swift
import SwiftUI
import URLImage

struct ProfileImageView: View {
// MARK: -  PROPERTY
var imageUrl: URL

// MARK: -  BODY
var body: some View {
URLImage(imageUrl) { image in
	image
		.resizable()
		.aspectRatio(contentMode: .fit)
		.frame(width: 50, height: 60)
		.clipShape(Circle())
		.overlay(Circle().stroke(Color.yellow, lineWidth: 2))
}
}
}

// MARK: -  PREVIEW
struct ProfileImageView_Previews: PreviewProvider {
static var previews: some View {

	let url = (URL(string: "https://randomuser.me/api/portraits/women/12.jpg")!)
	ProfileImageView(imageUrl: url)
}
}

```

<img height="350" alt="스크린샷" src="https://user-images.githubusercontent.com/28912774/154632837-9f279061-4746-4420-8d28-40a8b8f8c42f.gif">

### 🔷 Part 2.Infinite Scroll

### 🔷 Part 3.RefreshControl

<!-- <img height="350" alt="스크린샷" src=""> -->

<!-- README 한 줄에 여러 screenshoot 놓기 예제 -->
<!-- <p>
    <img alt="Clear Spaces demo" src="../assets/demo-clear-spaces.gif" height=400px>
    <img alt="QR code scanner demo" src="../assets/demo-qr-code.gif" height=400px>
    <img alt="Example preview demo" src="../assets/demo-example.gif" height=400px>
</p> -->

---

<!-- 🔶 🔷 📌 🔑 👉 -->

## 🗃 Reference

취준생을 위한 스위프트UI 앱만들기 강좌 Alamofire Combine - SwiftUI 2.0 fundamental Tutorial (2021) - Alamofire - [https://youtu.be/aMes-DVVJg4](https://youtu.be/aMes-DVVJg4)

Alamofire gitHub - [https://github.com/Alamofire/Alamofire](https://github.com/Alamofire/Alamofire)

ImageURL github - [https://github.com/dmytro-anokhin/url-image](https://github.com/dmytro-anokhin/url-image)

RandomUser API Documentation - [https://randomuser.me/documentation](https://randomuser.me/documentation)
