//
//  RandomUserViewModel.swift
//  RandomUserApi
//
//  Created by Jacob Ko on 2022/02/18.
//

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
