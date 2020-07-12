//
//  MySectionHeaderView.swift
//  ShoppingList
//
//  Created by Jerry on 6/8/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// this is here to give a consistent theme to section titles, but
// there's certainly a better way to do it using a customized ListStyle.
// but that's a matter for another day.  besides, the View we provide
// here does not really own the space in which it appears.
struct SLSectionHeaderView: View {
	
	var title: String
	
	var body: some View {
		GeometryReader { geometry in
			self.body(for: geometry.size)
		}
	}
	
	// this is split out to simplify working with the GeometryReader
	// and see what kind of space is available for us. expect to see some
	// experimentation here going on.
	func body(for size: CGSize) -> some View {
		//		print(size)
		//		return
		Text(title)
			.font(.body)
			.foregroundColor(.black)
		//			.background(Color.green)
		//			.opacity(0.5)
		//			.frame(minWidth: 0, maxWidth: .infinity)
	}
}
