//
//  ContentView.swift
//  RandomUserApi
//
//  Created by Jacob Ko on 2022/02/18.
//

import SwiftUI

struct ContentView: View {
	// MARK: -  PROPERTY

	@ObservedObject var randomUserViewModel = RandomUserViewModel()
	
	// MARK: -  BODY
	var body: some View {
		
		List(randomUserViewModel.randomUsers) { aRandomUser in
			RandomUserRowView(aRandomUser)
		}
		.listStyle(.plain)
	}
}

// MARK: -  PREVIEW
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
