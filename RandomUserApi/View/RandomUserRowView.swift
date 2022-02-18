//
//  RandomUserRowView.swift
//  RandomUserApi
//
//  Created by Jacob Ko on 2022/02/18.
//

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
