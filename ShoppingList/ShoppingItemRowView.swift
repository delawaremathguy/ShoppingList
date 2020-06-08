//
//  ItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// ONE MAJOR ITEM.  my method of deleting (tap, go to edit screen,
// tap "Delete This Item," and then returning was working EXCEPT FOR ONE CASE:
// if the list had only one item and you use this delete methodology,
// the program would crash in this View. Essentially, there would be
// crash in calling for item.name! and item.location!.name because
// CoreData had deleted the item (but this was still hanging on to it),
// so it would be a faulted reference with no name and cause of the dreaded
// attempt to force unwrap a nil message.  so you now see nil-coalescing
// code below to work around this problem, although, let's be honest:
// I haven't solved the problem at all, I have just kept the code from crashing.
// eventually i'll get this fixed (!)


struct FlawedShoppingItemRowView: View {
	// shows one line in a list for a shopping item, used for consistency
	// note: we must have the parameter as an @ObservedObject, otherwise
	// edits made to the ShoppingItem will not show when the ShoppingListView
	// or PurchasedListView is brought back on screen.
	@ObservedObject var item: ShoppingItem
	var showLocation: Bool = true
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(item.name ?? "NO NAME")
					.font(.headline)
				if showLocation {
					Text(item.location?.name ?? "NO LOCATION")
						.font(.caption)
				}
			}
			Spacer()
			Text(String(item.quantity))
				.font(.headline)
				.foregroundColor(Color.blue)
		}
	}
}

