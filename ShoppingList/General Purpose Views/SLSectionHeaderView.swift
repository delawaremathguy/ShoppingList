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
		GeometryReader { geo in
			if #available(iOS 14, *) {
				// default section titles in iOS 14 are upper-case and left-justified
				// so this uses case as intended and centers the title, as in iOS 13
				Text(title)
					.font(.body)
					.foregroundColor(.black)
					.textCase(.none) // an iOS 14 modifier
					.position(x: geo.size.width/2, y: geo.size.height/2)
				
			} else {
				Text(title)
					.font(.body)
					.foregroundColor(.black)
			}
		}
	}
	
}
