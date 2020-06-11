//
//  CenteredButton.swift
//  ShoppingList
//
//  Created by Jerry on 6/11/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// a simple view that contains a button that is horizontally centered onscreen

struct CenteredButton: View {
	let title: String
	let action: () -> Void
	
	var body: some View {
		HStack {
			Spacer()
			Button(title) {
				self.action()
			}
			Spacer()
		}
	}
}

