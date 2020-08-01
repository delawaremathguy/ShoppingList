//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by Jerry on 7/29/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import Combine

// a ShoppingListViewModel object provides a window into the Code Data store that
// can be used by ShoppingListTabView1, ShoppingListTabView2, and PurchasedTabView.
// it provides both data out for the view to consume, and handles user intents from the View
// back to Core Data (with notification to the View that the viewModel has changed).

class ShoppingListViewModel: ObservableObject {
	
	// since we're really wrapping four different types of ShoppingListViewModel here
	// all together, it's useful to define the types for clarity, and record which one we are
	enum viewModelUsageType {
		case singleSectionShoppingList 		// drives ShoppingListTabView1
		case multiSectionShoppingList 		// drives ShoppingListTabView2
		case purchasedItemShoppingList 		// drives PurchasedTabView
		case locationSpecificShoppingList	// drives list of items in LocationsTabView
	}
	var usageType: viewModelUsageType
	
	// for the case of managing a list of items at a specific location, we will
	// need to keep track of which location we're watching.  it's a little
	// clumsy to do it this way -- it'd be nicer to attach the location directly
	// to the case locationSpecificShoppingList as associated data; this may happen
	// eventually, but in the current code sequence at the call site, i don't
	// know the location at the time i create the model.
	var specificLocation: Location? = nil
	
	// the items on our list
	@Published var items = [ShoppingItem]()
	
	// this is an especially important part: we want to know about any changes
	// to the items -- remember, items can be altered outside of the view we provide
	// the model for, e.g., deleting a location moves a whole buch of items to
	// the Unknown Location, which affects what we model -- so we will subscribe
	// to their changes (all are Core Data items, so all are ObservableObjects)
	// and just turn those into "our model has changed messages"
	var cancellables = Set<AnyCancellable>()
	
	// a usage note on the cancellables set: we don't need to keep these directly
	// in synch with the order in the items array.  but, whenever that array
	// grows or shrinks, we need to update the cancellables.
	
	// quick accessors as computed properties
	var itemCount: Int { items.count }
	var hasUnavailableItems: Bool { items.count(where: { !$0.isAvailable }) > 0 }
	
	// init to be one of four different types.
	init(type: viewModelUsageType) {
		usageType = type
	}
	
	// call this loadItems once the object has been created, before using it. in usage,
	// this is called in .onAppear().  the location parameter only plays a role
	// for usage = .locationSpecificShoppingList, and this is where we associate the
	// location for this case
	func loadItems(at location: Location? = nil) {
		switch usageType {
			case .singleSectionShoppingList, .multiSectionShoppingList:
				items = ShoppingItem.currentShoppingList(onList: true)
			case .purchasedItemShoppingList:
				items = ShoppingItem.currentShoppingList(onList: false)
			case .locationSpecificShoppingList:
				specificLocation = location!
				if let locationItems = location!.items as? Set<ShoppingItem> {
					items = Array(locationItems)
				}
		}
		sortItems()
		establishSubscriptions()
		print("shopping list loaded. \(items.count) items.")
	}
	
	// cancellation of subscriptions.  use this is the items array is
	// about to change size, because we'll need to remove a cancellable or
	// add a cancellable.
	func cancelSubscriptions() {
		cancellables.forEach({ $0.cancel() })
		cancellables.removeAll()
	}

	// establish subscriptions sets up the cancellables array.  when called,
	// we assume that the set of cancellables is empty
	func establishSubscriptions() {
		for item in items {
			// add a subscription that will spit back an objectWillChange of ourself
			item.objectWillChange
				.sink(receiveValue: { _ in
					self.objectWillChange.send()
					//print("received a value from shopping item")
				})
				.store(in: &cancellables)
		}
	}
	
	// we'll do all the sorting ourself and not rely on Core Data sorting anything
	// for us -- we'll need to do this when loading data, of course, (yes, Core Data
	// would be better for this), bat also whenever we make an edit of an item
	// that could change the sort order (which is pretty much any edit or addition).
	private func sortItems() {
		switch usageType {
			case .singleSectionShoppingList, .multiSectionShoppingList:
				items.sort(by: { $0.name! < $1.name! })
				items.sort(by: { $0.visitationOrder <= $1.visitationOrder })
			case .purchasedItemShoppingList, .locationSpecificShoppingList:
				items.sort(by: { $0.name! < $1.name! })
		}
	}
	
	// changes availability flag for an item
	func toggleAvailableStatus(for item: ShoppingItem) {
		item.isAvailable.toggle()
		ShoppingItem.saveChanges()
	}
	
	// changes the onList flag and removes the item from
	// the items array (it's no longer on our list)
	private func toggleOnListStatusAndRemove(item: ShoppingItem) {
		item.onList.toggle()
		cancelSubscriptions()
		let index = items.firstIndex(of: item)!
		items.remove(at: index)
		establishSubscriptions()
	}
	
	// changes onList status for a single item
	func toggleOnListStatus(for item: ShoppingItem) {
		toggleOnListStatusAndRemove(item: item)
		ShoppingItem.saveChanges()
	}
	
	// changes onList status for a an array of items
	func toggleOnListStatus(for items: [ShoppingItem]) {
		for item in items {
			toggleOnListStatusAndRemove(item: item)
		}
		ShoppingItem.saveChanges()
	}
	
	// moves all items off the current list.  that means our array
	// will shrink down to the empty list
	func toggleAllItemsOnListStatus() {
		// stop listening to changes from items
		cancelSubscriptions()
		// make the changes
		for item in items {
			item.onList.toggle()
		}
		// empty the array (this triggers objectWillChange)
		// and there's no need here to establish subscriptions
		items = []
	}
	
	// marks all items in the display as available
	func markAllItemsAvailable() {
		for item in items where !item.isAvailable {
			item.isAvailable = true
		}
		ShoppingItem.saveChanges()
	}
	
	// in deleting an item, get the subscriptions out of the way (we do not
	// want to hang on to a Core Data item that's going away), drop the item
	// out of the array, and reset the subscriptions to all items
	func delete(item: ShoppingItem) {
		cancelSubscriptions()
		let index = items.firstIndex(of: item)!
		items.remove(at: index)
		establishSubscriptions()
		ShoppingItem.delete(item: item, saveChanges: true)
	}
	
	func updateDataFor(item: ShoppingItem?, using editableData: EditableShoppingItemData) {
		// if the incoming item is not nil, then this is just a straight update.
		// otherwise, we must create the new ShoppingItem here and add it to
		// our list of items

		// we may be adding a new item here; plus, lets' turn off the change messages
		cancelSubscriptions()
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
		
		// special case: if we're a locationSpecificShoppingList, we have to do a removal
		// of this item from the items array if the item's location was changed.
		if usageType == .locationSpecificShoppingList {
			if itemForCommit.location != specificLocation {
				let index = items.firstIndex(of: itemForCommit)!
				items.remove(at: index)
			}
		}
		
		// the order of items is likely affected, either because of a new object
		// being added, or a name/location change affects the sort order.
		sortItems()
		establishSubscriptions()
		ShoppingItem.saveChanges()
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
