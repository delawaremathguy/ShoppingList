//
//  ItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// ONE MAJOR ITEM.  my method of deleting (tap, go to edit screen,
// tap "Delete This Item," and then returning) was working EXCEPT FOR ONE EDGE CASE:
// if the list had only one item and you use this delete methodology,
// the program would crash in this View. Essentially, there would be
// crash in calling for item.name! and item.location!.name because
// CoreData had deleted the item (but some ShoppingItemRowView was still hanging on to it),
// so it would be a faulted reference with no name and cause of the dreaded
// attempt to force unwrap a nil message.

// option 1 is to put nil-coalescing code below to work around this problem, although,
// let's be honest: this does not solve the problem at all, I have just kept the
// code from crashing.

// my current option 2 is found in the Add/ModifyViews for ShoppingItems and Locations.
// in each case, you'll see that i don't "delete then pop back to a list," but instead
// "remember who to delete, pop back to the list, and then finish the deletion in the
// .onDisappear() view modifier.  this seems to be working right now: we see the previous
// List view first, then the onDisappear kicks in, and the item is deleted without incident.

// i'll eventually figure out what's the right way to do this.  but not today.

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
				if !item.isAvailable {
					Text(item.name!) // <-- THIS IS WHERE WE OCCASIONALLY GET A CRASH
						.font(.body)
						.overlay(Rectangle().frame(height: 1.0))
				} else {
					Text(item.name!)
						.font(.body)
				}
				if showLocation {
					Text(item.location!.name!)
						.font(.caption)
						.foregroundColor(.secondary)
				}
			}
			Spacer()
			Text(String(item.quantity))
				.font(.headline)
				.foregroundColor(Color.blue)
		}
	}
}

