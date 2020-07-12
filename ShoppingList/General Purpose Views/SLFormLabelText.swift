//
//  MyFormLabelText.swift
//  ShoppingList
//
//  Created by Jerry on 5/18/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// a simple view i use so that all labels on a form come out styled
// the same way.

struct SLFormLabelText: View {
	var labelText: String
	var body: some View {
		Text(labelText)
			.font(.headline)
	}
}

