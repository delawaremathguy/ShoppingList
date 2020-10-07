//
//  ViewBuildingCode.swift
//  ShoppingList
//
//  Created by Jerry on 7/7/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

// this is common code for both shopping list tabs and the purchased tab to build a
// context menu

// note for shoppingItemContextMenu below: in XCode 11.5/iOS 13.5, you'll get plenty of layout
// messages about unsatisfiable constraints in the console when displaying a contextMenu.
// that's apparently a SwiftUI problem that seems to not be present in XCode 12/iOS 14 betas.

/// Builds out a context menu for a ShoppingItem that can be used in the shopping list
/// or the purchased list to quickly move the item to the other list, toggle the state
/// of the availability, and delete the item.
/// - Parameter item: a ShoppingItem
/// - Parameter deletionTrigger: a closure to call to set state variables and put up an "Are you sure?" alert before allowing deletion of the item
/// - Returns: Void
@ViewBuilder
func shoppingItemContextMenu(viewModel: ShoppingListViewModel, for item: ShoppingItem,
														 deletionTrigger: @escaping () -> Void) -> some View {
	Button(action: {
		viewModel.moveToOtherList(item: item)
	}) {
		Text(item.onList ? "Move to Purchased" : "Move to ShoppingList")
		Image(systemName: item.onList ? "purchased" : "cart")
	}
	
	Button(action: {
		viewModel.toggleAvailableStatus(for: item)
	}) {
		Text(item.isAvailable ? "Mark as Unavailable" : "Mark as Available")
		Image(systemName: item.isAvailable ? "pencil.slash" : "pencil")
	}
	
//	if !kTrailingSwipeMeansDelete {
		Button(action: {
			deletionTrigger()
		}) {
			Text("Delete This Item")
			Image(systemName: "trash")
		}
//	}
}
