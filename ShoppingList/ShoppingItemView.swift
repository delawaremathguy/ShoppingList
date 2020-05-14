//
//  ItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct ShoppingItemView: View {
	var item: ShoppingItem
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(item.name!)
					.font(.headline)
				Text(item.location!.name!)
					.font(.caption)
			}
			Spacer()
			Text(String(item.quantity))
				.font(.headline)
				.foregroundColor(Color.blue)
		}
	}
}

