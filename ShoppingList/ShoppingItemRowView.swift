//
//  ItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct ShoppingItemRowView: View {
	// shows one line in a list for a shopping item, used for consistency
	// note: we must have the parameter as an @ObservedObject, otherwise
	// edits made to an item involving the name or quantity or location
	// will not be updated when the ShippongListView or PurchasedListView
	// is brought back on screen (i.e., it needs to know there's some
	// dependency here on the ShoppingItem, even though we use it in
	// read-only mode).
	@ObservedObject var item: ShoppingItem
	
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

