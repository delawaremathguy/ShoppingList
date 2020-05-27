//
//  MyFormLabelText.swift
//  ShoppingList
//
//  Created by Jerry on 5/18/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct MyFormLabelText: View {
	var labelText: String
	var body: some View {
		Text(labelText)
			.font(.headline)
			// .foregroundColor(Color.blue)
	}
}

