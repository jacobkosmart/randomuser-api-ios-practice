# RandomUserApi-ios-practice

<!-- ! gif 스크린샷 -->

## 📌 Main Features

- Swift UI 에서 Alamofire 을 통한 API 통신

- 사용 API: RandomUSer.me - https://randomuser.me/documentation

- Combine 을 이용해 비동기 통신 처리

- 이미지 라이브러리: URLImage

- Infinite Scroll 무한 스크롤 기능 구현

- RefreshControl 당겨서 새로고침 기능 구현

## 👉 Swift Package manager

### 🔶 URLImage

> https://github.com/dmytro-anokhin/url-image#installation

### 🔶 Alamofire

> https://github.com/Alamofire/Alamofire.git

### 🔶 Introspect

> https://github.com/siteline/SwiftUI-Introspect

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

---

### 🔷 Part 2.RefreshControl (IntroSpect)

> iOS 15 부터는 SwiftUI 자체 내에서 refreshable() modifier 를 지원합니다 - https://www.hackingwithswift.com/quick-start/swiftui/how-to-enable-pull-to-refresh

> iOS 15 이전버전도 지원하기 위해서 라이브 설치가 필요한데, SwiftUI-Introspect 를 사용해서 RefreshControl 을 사용할 수 있습니다 - https://github.com/siteline/SwiftUI-Introspect

- UIViewController 를 SwiftUI 에서 사용하려면, Hosting View 를 사용해야 합니다

#### 🔶 UIKit 의 refresh action 추가

- refresh 기능을 추가하고 action 기능을 추가하기 위해서 RefreshControlHelper 라는 class 를 생성해서 @objc 의 selector 를 이용해 refresh 동작시 action 기능을 추가합니다

```swift
//  ContentView.swift

import SwiftUI
import UIKit
import Introspect

struct ContentView: View {
	// MARK: -  PROPERTY

	@ObservedObject var randomUserViewModel = RandomUserViewModel()

	let refreshControlHelper = RefreshControlHelper()

	// MARK: -  BODY
	var body: some View {

		List(randomUserViewModel.randomUsers) { aRandomUser in
			RandomUserRowView(aRandomUser)
		}
		.listStyle(.plain)
		// MARK: -  Introspect 설정
		.introspectTableView { tableView in

			let myRefresh = UIRefreshControl()
			refreshControlHelper.refreshControl = myRefresh
			refreshControlHelper.parentContentView = self
			myRefresh.addTarget(refreshControlHelper, action: #selector(RefreshControlHelper.didRefresh), for: .valueChanged)

			tableView.refreshControl = myRefresh
		}
	}
}

// MARK: -  PREVIEW
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

// MARK: -  RefreshControl 에 action 추가하기
class RefreshControlHelper {
// Properties
var parentContentView: ContentView?
var refreshControl: UIRefreshControl?

@objc func didRefresh() {
print(#fileID, #function, #line, "")
guard let parentContentView = parentContentView,
			let refreshControl = refreshControl else {
				print("parentContentView, refreshControl 가 nil 입니다")
				return
			}
DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
	print("리프레시가 되었습니다")
	refreshControl.endRefreshing() // refreshing 이 끝났다고 설정 하기
}
}
}

```

<p>
<img height="350" alt="스크린샷" src="https://user-images.githubusercontent.com/28912774/154653577-c459ecbc-f42c-45bf-8d0f-c923ced90c2b.gif">
<img height="350" alt="스크린샷" src="https://user-images.githubusercontent.com/28912774/154653886-7fde6f8d-2a0f-4210-b2b5-4b0cb5f04287.gif">
</p>

#### 🔶 새로고침한 데이터 refresh action 에 추가

- 방법 1: 직접 viewModel 에 접근해서 fetch data method 실행 하기

- 방법 2 : ViewModel 에 직접 접근해서 control 하는것이 아니고, combine 을 통해서 refresh action 을 PassthroughSubject 를 생성해서 그것을 구독해서 fresh action 을 만들수 있습니다

(위 방법의 장점은 view 에서 직접 viewModel 로 접근하지 않기 때문에 `fetchRandomUser()` 함수를 ViewModel 안에서만 사용할 수 있게 fileprivate 할 수 있습니다)

```swift
// ContentView.swfit

// MARK: -  api 새로고침 해서 새로운 정보 가져오기

// 방법 1: 직접 viewModel 접근해서 fetch data 실행하기
// parentContentView 가 ContentView 이니까 거기 viewModel 에 접근해서 fetch 데이터를 실행하기
// parentContentView.randomUserViewModel.fetchRandomUser()

// 방법 2: Combine 을 사용해서 action 을 보내서 viewModel 쪽에서 구독해서 event 를 처리하는 방법
// refreshActionSubject 에 event 보내줌 ㅛ
parentContentView.randomUserViewModel.refreshActionSubject.send()
refreshControl.endRefreshing() // refreshing 이 끝났다고 설정 하기

// MARK: -  Helper Methods
extension ContentView {
fileprivate func configureRefreshControl(_ tableView: UITableView) {
	print(#fileID, #function, #line, "")
	let myRefresh = UIRefreshControl()
	myRefresh.tintColor = #colorLiteral(red: 1, green: 0.6865338683, blue: 0.007479909807, alpha: 1) // Refresh color 변경
	refreshControlHelper.refreshControl = myRefresh
	refreshControlHelper.parentContentView = self
	myRefresh.addTarget(refreshControlHelper, action: #selector(RefreshControlHelper.didRefresh), for: .valueChanged)

	tableView.refreshControl = myRefresh
}
}

```

```swift
//  RandomUserViewModel.swift

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

// refresh action 을 위한 PassthroughSubject subject 생성 - 단방향으로 이벤트를 한번만 보내기
var refreshActionSubject = PassthroughSubject<(), Never>()

// 호출할 API 주소
var baseUrl = "https://randomuser.me/api/?results=100"

// ViewModel 이 생성이 될때 API 를 fetch  하게 함
init() {
	// code 자동 완성
	print(#fileID, #function, #line, "")
	fetchRandomUser()

	// refreshActionSubject 구독하기
	refreshActionSubject.sink{ [weak self] _ in
		guard let self = self else { return }
		print("RandomUserViewmodel 에 init 에 refreshActionSubject 가 호출 되었음")
		self.fetchRandomUser()
	}.store(in: &subscription)
}

// MARK: -  FUNCTION
// combine 형태로
fileprivate func fetchRandomUser() {
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

<p>
<img height="350" alt="스크린샷" src="https://user-images.githubusercontent.com/28912774/154658312-d06b5509-281a-4433-a529-4d6f41c8a904.gif">
<img height="350" alt="스크린샷" src="https://user-images.githubusercontent.com/28912774/154658650-8c94d2f9-188c-4510-8ae1-2368c2d8181d.gif">
</p>

### 🔷 Part 3.Infinite Scroll (Pagination)

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

SwiftUI-Introspect github - [https://github.com/siteline/SwiftUI-Introspect](https://github.com/siteline/SwiftUI-Introspect)
