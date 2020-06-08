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
struct MySectionHeaderView: View {
	
	var title: String
	
	var body: some View {
		GeometryReader { geometry in
			self.body(for: geometry.size)
		}
	}
	
	// this is split out to simplify working with the GeometryReader
	// and see what kind of space is available for us. expect to see some
	// experimentation here going on, although waiting for SwiftUI 2.0 might
	// be the best strategy for customizing the section headers.
	func body(for size: CGSize) -> some View {
		// print(size)
		return Text(title)
			.font(.headline)
			.foregroundColor(.black)
			.frame(minWidth: 0, maxWidth: .infinity)
//			.background(Color.green)
//			.opacity(0.5)
	}
}
