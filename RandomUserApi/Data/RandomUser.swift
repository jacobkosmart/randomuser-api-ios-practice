//
//  RandomUser.swift
//  RandomUserApi
//
//  Created by Jacob Ko on 2022/02/18.
//

import Foundation

// MARK: -  MODEL

struct RandomUser: Codable, Identifiable, Equatable {
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
	
	// 비교를 위한 Equatable protocol logic
	// 첫번째, 두번째 값이 같다는 판단기준을 어떻게 할건지에 대해 작성하기
	static func == (lhs: RandomUser, rhs: RandomUser) -> Bool {
		return lhs.id == rhs.id
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


struct Info: Codable, CustomStringConvertible {
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
	var infoDescription: String {
		return "seed: \(seed) / resultCount: \(resultsCount) / page : \(page)"
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
