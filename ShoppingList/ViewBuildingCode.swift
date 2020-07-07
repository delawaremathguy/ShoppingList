//
//  ViewBuildingCode.swift
//  ShoppingList
//
//  Created by Jerry on 7/7/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

// this is common code for both shopping list tabs and the purchased tab

// this consolidates the code for what to show when a list is empty
@ViewBuilder
func emptyListView(listName: String) -> some View {
	Group {
		Text("There are no items")
			.padding([.top], 200)
		Text("on your \(listName) List.")
	}
	.font(.title)
	.foregroundColor(.secondary)
	Spacer()
}

// note for shoppingItemContextMenu below: in XCode 11.5/iOS 13.5, you'll get plenty of layout
// messages about unsatisfiable constraints in the console when displaying a contextMenu.
// that's apparently a SwiftUI problem that seems to not be present in XCode 12/iOS 14 beta.

/// Builds out a context menu for a ShoppingItem that can be used in the shopping list
/// or the purchased list to quickly move the item to the other list, toggle the state
/// of the availability, and delete the item.
/// - Parameter item: a ShoppingItem
/// - Parameter deletionTrigger: a closure to call to set state variables and put up an "Are you sure?" alert before allowing deletion of the item
/// - Returns: Void
@ViewBuilder
func shoppingItemContextMenu(for item: ShoppingItem, deletionTrigger: @escaping () -> Void) -> some View {
	Button(action: {
		item.onList.toggle()
		ShoppingItem.saveChanges()
	}) {
		Text(item.onList ? "Mark Purchased" : "Move to ShoppingList")
		Image(systemName: item.onList ? "purchased" : "cart")
	}
	
	Button(action: { item.mark(available: !item.isAvailable, saveChanges: true) }) {
		Text(item.isAvailable ? "Mark as Unavailable" : "Mark as Available")
		Image(systemName: item.isAvailable ? "pencil.slash" : "pencil")
	}
	
	if !kTrailingSwipeMeansDelete {
		Button(action: {
			deletionTrigger()
		}) {
			Text("Delete This Item")
			Image(systemName: "minus.circle")
		}
	}
}
