//
//  EditableShoppingItemData.swift
//  ShoppingList
//
//  Created by Jerry on 6/28/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// this gives me a way to collect all the data for a shoppingItem that i might want
// to edit.  it defaults to having values appropriate for a new item upon
// creation, or can be initialized from a ShoppingItem.  this is something
// i can then hand off to an edit view.  at some point, that edit view will
// want to update a ShoppingItem with this data, so we also provide an ectension
// on ShoppingItem to copy this data back to a ShoppingItem.

struct EditableShoppingItemData {
	// all of the values here provide suitable defaults for a new shopping item
	var itemName: String = ""
	var itemQuantity: Int = 1
	var selectedLocation = Location.unknownLocation()!
	var onList: Bool = true
	var isAvailable = true
	
	// this copies all the editable data from an incoming ShoppingItem
	init(shoppingItem: ShoppingItem) {
		itemName = shoppingItem.name!
		itemQuantity = Int(shoppingItem.quantity)
		selectedLocation = shoppingItem.location!
		onList = shoppingItem.onList
		isAvailable = shoppingItem.isAvailable
	}
	
	// provides basic init, but can be tweaked in case you want to provide
	// a default (for an item yet to be created) that's not on the shopping list
	init(onList: Bool = true) {
		self.onList = onList
	}
	
	var canBeSaved: Bool { itemName.count > 0 }
}

// MARK: - ShoppingItem Convenience Extension

extension ShoppingItem {
	
	func updateValues(from editableData: EditableShoppingItemData) {
		name = editableData.itemName
		quantity = Int32(editableData.itemQuantity)
		setLocation(editableData.selectedLocation)
		onList = editableData.onList
		isAvailable = editableData.isAvailable
	}
}

