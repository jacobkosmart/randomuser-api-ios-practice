//
//  ContentView.swift
//  RandomUserApi
//
//  Created by Jacob Ko on 2022/02/18.
//

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
				.onAppear {
					print("RandomUserRowView - onAppear() 호출됨")
					fetchMoreData(aRandomUser)
				}
		}
		.listStyle(.plain)
		// MARK: -  Introspect 설정
		.introspectTableView { tableView in
			self.configureRefreshControl(tableView)
		}
		
		// 데이터 로딩 중이라면, 로딩바 나오게 작동시키기
		if randomUserViewModel.isLoading {
			MYBottomProgressView()
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
			
			// MARK: -  api 새로고침 해서 새로운 정보 가져오기
			
			// 방법 1: 직접 viewModel 접근해서 fetch data 실행하기
			// parentContentView 가 ContentView 이니까 거기 viewModel 에 접근해서 fetch 데이터를 실행하기
			// parentContentView.randomUserViewModel.fetchRandomUser()
			
			// 방법 2: Combine 을 사용해서 action 을 보내서 viewModel 쪽에서 구독해서 event 를 처리하는 방법
			// refreshActionSubject 에 event 보내줌 ㅛ
			parentContentView.randomUserViewModel.refreshActionSubject.send()
			refreshControl.endRefreshing() // refreshing 이 끝났다고 설정 하기
		}
	}
}

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
	
	
	fileprivate func fetchMoreData(_ randomUser: RandomUser) {
		print(#fileID, #function, #line, "")
		// RandomUserRowView 가 나타 날때 마지막 id 와 현재 id 를 비교
		if self.randomUserViewModel.randomUsers.last == randomUser {
			print("마지막 리스트입니다")
			// 마지막 부분일때 ffetchMoreActionSubject 에 event 전송
			randomUserViewModel.fetchMoreActionSubject.send()
		}
	}
}

// Bottom ProgressView
struct MYBottomProgressView: View {
	var body: some View {
		ProgressView()
			.progressViewStyle(CircularProgressViewStyle(tint: Color.yellow)
			).scaleEffect(1.7, anchor: .center)
	}
}
