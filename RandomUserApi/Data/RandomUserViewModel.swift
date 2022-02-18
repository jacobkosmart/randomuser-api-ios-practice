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
	@Published var pageInfo: Info? {
		didSet {
			print("pageInfo: \(pageInfo)")
		}
	}
	
	@Published var isLoading: Bool = false
	
	// refresh action 을 위한 PassthroughSubject subject 생성 - 단방향으로 이벤트를 한번만 보내기
	var refreshActionSubject = PassthroughSubject<(), Never>()
	
	// list 바닥에 닿았을때 refresh action 실행 하고 그 action 에 fetchMore() 가 실행되게 함
	var fetchMoreActionSubject = PassthroughSubject<(), Never>()
	
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
		
		// fetchMoreActionSubject 구독하기
		fetchMoreActionSubject.sink{ [weak self] _ in
			guard let self = self else { return }
			print("RandomUserViewmodel 에 init 에 refreshActionSubject 가 호출 되었음")
			
			// loading 중이 아닐때만 fetchMore 가 실행되게 함
			if !self.isLoading {
				self.fetchMore()
			}
		}.store(in: &subscription)
	}
	
	// MARK: -  FUNCTION
	// fetch 데이터 가져오기
	fileprivate func fetchRandomUser() {
		print(#fileID, #function, #line, "")
		AF.request(RandomUserRouter.getUsers())
			.publishDecodable(type: RandomUserResponse.self)
		// combine 에서 옵셔널을 제거 : compatMap 을 사용해서 optional 일 경우에 값이 있는 경우에것만 값으로 가져옴 -> unwrapping 이 자동으로 됨
			.compactMap{ $0.value }
		// sink 를 해서 구독을 해줌
			.sink { completion in
				print("데이터 가져오기 성공")
			} receiveValue: { receivedValue in
				print("받은 값 : \(receivedValue.results.count)")
				self.randomUsers = receivedValue.results
				self.pageInfo = receivedValue.info
			}
		// 구독이 완료되면 메모리에서 지워줌
			.store(in: &subscription)
	}
	
	// 마지막에 닿았을때 추가로 데이터 가져오기
	fileprivate func fetchMore() {
		print(#fileID, #function, #line, "")
		guard let currentPage = pageInfo?.page else {
			print("페이지 정보가 없습니다")
			return
		}
		
		// 로딩 시작이 안되된것을 알려줌
		self.isLoading = true
		
		// 현재 페이지 에서 +1 해서 다음페이지가 호출되게 함
		let pageToLoad = currentPage + 1
		AF.request(RandomUserRouter.getUsers(page: pageToLoad))
			.publishDecodable(type: RandomUserResponse.self)
		// combine 에서 옵셔널을 제거 : compatMap 을 사용해서 optional 일 경우에 값이 있는 경우에것만 값으로 가져옴 -> unwrapping 이 자동으로 됨
			.compactMap{ $0.value }
		// sink 를 해서 구독을 해줌
			.sink { completion in
				print("데이터 가져오기 성공")
				// 데이터를 가져오면 로딩 false 로 변경
				self.isLoading = false
			} receiveValue: { receivedValue in
				print("받은 값 : \(receivedValue.results.count)")
				// 기존것에 계속 누적 시켜서 api 를 호출 시킴
				self.randomUsers += receivedValue.results
				self.pageInfo = receivedValue.info
			}
		// 구독이 완료되면 메모리에서 지워줌
			.store(in: &subscription)
	}
}
