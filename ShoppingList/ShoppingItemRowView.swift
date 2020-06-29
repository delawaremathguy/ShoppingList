//
//  ItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// DEVELOPMENT COMMENT

// this has been an ongoing problem: when i deleted a ShoppingItem from
// the AddorModifyShoppingItemView, two things were happening in sequence:
// this view was getting a "redraw" message through its ObservedObject
// status in the view, and after that, the actual deletion came through
// as the FetchRequest updated, which then removed this view.

// but the problem is that we're first getting redrawn, then removed; but the
// the ObservedObject was already deleted in Core Data.  the curiosity is
// that the ObservedObject "item" was still there because we're hanging on to it
// but it exists only as a Core Data fault in memory.
// what that means is that item.isAvailable and item.showLocation and
// item.quantity are probably all zero (but could have any value), but
// item.name! and item.location!.name! are meaningless, since each would cause
// the fault to reload and it can't.  so" BOOM.

// there's no way around this problem, at least until i know more.
// indeed, the .onDelete() modifier knows enough about the problem
// that it probably deletes the "cell" in such a way that no visual update
// is delivered here.

struct ShoppingItemRowView: View {
	// shows one line in a list for a shopping item.
	// note: we must have the parameter as an @ObservedObject, otherwise
	// edits made to the ShoppingItem will not show when the ShoppingListView
	// or PurchasedListView is brought back on screen.
	
	// second, important note: if the item is marked in Core Data as "isDeleted,"
	// that means we have a deferred "save to disk" out there that will eventually
	// kick in (and it may happen sooner).  but this prevents the basic bug i've
	// been fighting for some time, concerning the timing of when Core Data objects
	// really go away and when they don't, and how a View such as this is still holding onto
	// an object that is going away on the next layout/body result pass.
	
	@ObservedObject var item: ShoppingItem
	var showLocation: Bool = true
	
	var body: some View {
		HStack {
			if item.isDeleted {
				Text("Being Deleted")
					.font(.body)

			} else {

				VStack(alignment: .leading) {
					if !item.isAvailable {
						Text(item.name!)
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
			} // end of if-then-else
		} // end of HStack
	}
}

