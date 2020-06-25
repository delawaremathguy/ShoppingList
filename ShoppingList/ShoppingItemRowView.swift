//
//  ItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// DEVELOPMENT COMMENT
// in some previous versions, this code would occasionally crash when items
// were deleted.  my theory of the case was that a shopping item was deleted in
// the AddOrModifyShoppingItemView, that view was dismissed, and in the visual
// transition back to the parent list view, the row view associated with the deleted
// item was still around.  the line below that referenced item.name! crashed --
// the item still existed as a Core Data fault, but the information behind it was gone.
//
// in the current code, when an item is deleted in AddOrModifyShoppingItemView, we
// stash away the item to be deleted, dismiss() the view, and then in .onDisappear()
// delete the item.  this way, the visual transition seems to be completed before
// the item is deleted and the result is perfectly fine.
//
// so my theory of the case is that Core Data's deletion of the item and the
// parent view's discovery of that deletion were out-of-synch; using the .onDisappear()
// modifier seems to guarantee the right order of events.  so far, anyway!

struct ShoppingItemRowView: View {
	// shows one line in a list for a shopping item, used for consistency.
	// note: we must have the parameter as an @ObservedObject, otherwise
	// edits made to the ShoppingItem will not show when the ShoppingListView
	// or PurchasedListView is brought back on screen.
	@ObservedObject var item: ShoppingItem
	var showLocation: Bool = true
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				if !item.isAvailable {
					Text(item.name!)	// <-- site of earlier crash (read comments above)
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

