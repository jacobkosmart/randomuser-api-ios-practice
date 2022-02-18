//
//  ProfileImageView.swift
//  RandomUserApi
//
//  Created by Jacob Ko on 2022/02/18.
//

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
