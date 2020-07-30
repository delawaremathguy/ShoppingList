//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by Jerry on 7/29/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// a ShoppingListViewModel object provides a window into the Code Data store that
// can be used by ShoppingListTabView1, ShoppingListTabView2, and PurchasedTabView.
// it provides both data out for the view to consume, and handles user intents from the View
// back to Core Data (with notification to the View that the viewModel has changed).

class ShoppingListViewModel: ObservableObject {
	
	// since we're really wrapping three different types of ShoppingListViewModel here
	// all together, it's useful to define the types for clarity, and record which one we are
	enum viewModelUsageType {
		case singleSectionShoppingList
		case multiSectionShoppingList
		case purchasedItemShoppingList
	}
	var usageType: viewModelUsageType
	
	// the items on our list
	@Published var items = [ShoppingItem]()
	
	// quick accessors as computed properties
	var itemCount: Int { items.count }
	var hasUnavailableItems: Bool { items.count(where: { !$0.isAvailable }) > 0 }
	
	init(type: viewModelUsageType) {
		usageType = type
	}
	
	// call this loadItems once the object has been created and we need the items populated
	func loadItems() {
		switch usageType {
			case .singleSectionShoppingList, .multiSectionShoppingList:
				items = ShoppingItem.currentShoppingList(onList: true)
			case .purchasedItemShoppingList:
				items = ShoppingItem.currentShoppingList(onList: false)
		}
		sortItems()
		print("shopping list loaded. \(items.count) items.")
	}
	
	// we'll not have Core Data sort anything for us; but be sure to sort the
	// items after loading from Core Data and any other time you make an edit
	// that could change the sort order (which is pretty much any edit or addition).
	private func sortItems() {
		switch usageType {
			case .singleSectionShoppingList, .multiSectionShoppingList:
				items.sort(by: { $0.name! < $1.name! })
				items.sort(by: { $0.visitationOrder <= $1.visitationOrder })
			case .purchasedItemShoppingList:
				items.sort(by: { $0.name! < $1.name! })
		}
	}
	
	// changes availability flag for an item
	func toggleAvailableStatus(for item: ShoppingItem) {
		objectWillChange.send()
		item.isAvailable.toggle()
		ShoppingItem.saveChanges()
	}
	
	// helper function to toggle the onList flag and remove the item from
	// the items array (it's no longer on our list)
	private func toggleOnListStatusAndRemove(item: ShoppingItem) {
		item.onList.toggle()
		let index = items.firstIndex(of: item)!
		items.remove(at: index)
	}
	
	// changes on list status for a single item
	func toggleOnListStatus(for item: ShoppingItem) {
		objectWillChange.send()
		toggleOnListStatusAndRemove(item: item)
		ShoppingItem.saveChanges()
	}
	
	// changes on list status for a an array of items
	func toggleOnListStatus(for items: [ShoppingItem]) {
		objectWillChange.send()
		for item in items {
			toggleOnListStatusAndRemove(item: item)
		}
		ShoppingItem.saveChanges()
	}
	
	// moves all items off the current list
	func toggleAllItemsOnListStatus() {
		objectWillChange.send()
		toggleOnListStatus(for: items)
	}
	
	// marks all items in the display as available
	func markAllItemsAvailable() {
		objectWillChange.send()
		for item in items {
			item.isAvailable.toggle()
		}
		ShoppingItem.saveChanges()
	}
	
	func delete(item: ShoppingItem) {
		let index = items.firstIndex(of: item)!
		items.remove(at: index)
		ShoppingItem.delete(item: item, saveChanges: true)
	}
	
	func updateDataFor(item: ShoppingItem?, using editableData: EditableShoppingItemData) {
		// if the incoming item is not nil, then this is just a straight update.
		// otherwise, we must create the new ShoppingItem here and add it to
		// our list of items

		// if we already have an editableItem, use it, else create it now and add to items
		var itemForCommit: ShoppingItem
		if let itemBeingEdited = item {
			itemForCommit = itemBeingEdited
		} else {
			itemForCommit = ShoppingItem.addNewItem()
			items.append(itemForCommit)
		}
		
		// apply the update
		itemForCommit.updateValues(from: editableData) // an extension on ShoppingItem
		
		// the order of items is likely affected, either because of a new object
		// being added, or a name/location change affects the sort order.
		sortItems()
	}
	
	// this is needed because when we get down to the edit screen, we need the list
	// of locations so one can be assigned to the item
	func allLocations() -> [Location] {
		return Location.allLocations(userLocationsOnly: false).sorted(by: <)
	}
	
	// provides a list of locations currently represented by objects in
	// the items array
	func locationsForItems() -> [Location] {
		// returns all the locactions associated with our items, sorted by visitation order.
		// we first get the locations of each of the shopping items.
		let allLocations = items.map({ $0.location! })
		// then turn these into a Set (which causes all duplicates to be removed)
		// and sort by visitationOrder (which gives an array)
		return Set(allLocations).sorted(by: <)
	}
	
	func items(at location: Location) -> [ShoppingItem] {
		return items.filter({ $0.location! == location })
	}

}
