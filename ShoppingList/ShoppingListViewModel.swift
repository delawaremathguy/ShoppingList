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
	
	// have we ever been loaded or not
	private var dataHasNotBeenLoaded = true
		
	// quick accessors as computed properties
	var itemCount: Int { items.count }
	var hasUnavailableItems: Bool { items.count(where: { !$0.isAvailable }) > 0 }
	
	// MARK: - Initialization
	
	// init to be one of four different types.
	init(type: viewModelUsageType) {
		usageType = type
		// sign us up for ShoppingItem change operations
		NotificationCenter.default.addObserver(self, selector: #selector(shoppingItemAdded),
																					 name: .shoppingItemAdded, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(shoppingItemEdited),
																					 name: .shoppingItemEdited, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(shoppingItemWillBeDeleted),
																					 name: .shoppingItemWillBeDeleted, object: nil)
	}
	
	// MARK: - Responses to changes in ShoppingItem objects
	
	@objc func shoppingItemAdded(_ notification: Notification) {
		// the notification has a reference to the item that has been added
		// if we're interested in it, now's the time to add it to the items array.
		guard let item = notification.object as? ShoppingItem else { return }
		if !items.contains(item) && isOurKind(item: item) {
			addToItems(item: item)
		}
	}

	@objc func shoppingItemEdited(_ notification: Notification) {
		guard let item = notification.object as? ShoppingItem else { return }
		// the logic here is mostly:
		// -- did the edit kick the item off the list? if yes, remove it
		// -- did the edit put the item on th list? if so, add it
		// -- if it's on the list, broadcast the change to SwiftUI
		// if it's not on the list, we don't care
		if items.contains(item) && !isOurKind(item: item) {
			removeFromItems(item: item)
		} else if !items.contains(item) && isOurKind(item: item) {
			addToItems(item: item)
		} else if items.contains(item) {
			objectWillChange.send()
		}
	}
	
	@objc func shoppingItemWillBeDeleted(_ notification: Notification) {
		// the notification has a reference to the item that will be deleted
		// if we're holding on to it, now's the time to remove it from the items array.
		guard let item = notification.object as? ShoppingItem else { return }
		if items.contains(item) {
			removeFromItems(item: item)
		}
	}
		
	func isOurKind(item: ShoppingItem) -> Bool {
		switch usageType {
			case .singleSectionShoppingList, .multiSectionShoppingList:
				return item.onList == true
			case .purchasedItemShoppingList:
				return item.onList == false
			case .locationSpecificShoppingList:
				return item.location == specificLocation
		}

	}
	
	// call this loadItems once the object has been created, before using it. in usage,
	// i have called this in .onAppear(), and even though onAppear() can be called
	// multiple times on the same View (each time you change the tab, you get an onAppear)
	// and reloading seems wasteful, you really need to do it for certain sequences of changes
	// (and remember, even though we see that something has changed, we don;t know
	// exactly what changed).
	// the location parameter only plays a role
	// for usage = .locationSpecificShoppingList, and this is where we associate the
	// location for this case
	func loadItems(at location: Location? = nil) {
		if dataHasNotBeenLoaded {
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
			print("shopping list loaded. \(items.count) items.")
			sortItems()
			dataHasNotBeenLoaded = true
		}
	}
		
	// we'll do all the sorting ourself and not rely on Core Data sorting anything
	// for us -- we'll need to do this when loading data, of course, (yes, Core Data
	// might be better for this), but also whenever we make an edit of an item
	// that could change the sort order (which varies depending on who we are).
	private func sortItems() {
		switch usageType {
			case .singleSectionShoppingList, .multiSectionShoppingList:
				items.sort(by: { $0.name! < $1.name! }) 
				items.sort(by: { $0.visitationOrder < $1.visitationOrder })
			case .purchasedItemShoppingList, .locationSpecificShoppingList:
				items.sort(by: { $0.name! < $1.name! })
		}
	}
	
	// simple utility to remove an item (known to exist)
	private func removeFromItems(item: ShoppingItem) {
		let index = items.firstIndex(of: item)!
		items.remove(at: index)
	}

	// simple utility to add an item (that we know should be on our list)
	private func addToItems(item: ShoppingItem) {
		items.append(item)
		sortItems()
	}

	// changes availability flag for an item
	func toggleAvailableStatus(for item: ShoppingItem) {
		objectWillChange.send()
		item.isAvailable.toggle()
		ShoppingItem.saveChanges()
	}
	
	// changes onList status for a single item
	func moveToOtherList(item: ShoppingItem) {
		removeFromItems(item: item)
		item.onList.toggle()
		ShoppingItem.saveChanges()
	}
	
	// changes onList status for an array of items
	func moveToOtherList(items: [ShoppingItem]) {
		for item in items {
			item.onList.toggle()
			removeFromItems(item: item)
		}
		ShoppingItem.saveChanges()
	}
	
	// moves all items off the current list.  that means our array
	// will shrink down to the empty array
	func moveAllItemsToOtherList() {
		for item in items {
			item.onList.toggle()
		}
		// empty the array (this triggers objectWillChange)
		// and there's no need here to establish subscriptions
		items = []
		ShoppingItem.saveChanges()
	}
	
	// marks all items in the display as available
	func markAllItemsAvailable() {
		objectWillChange.send()
		for item in items where !item.isAvailable {
			item.isAvailable = true
		}
		ShoppingItem.saveChanges()
	}
	
	// deletes an item.  this results in a callback, both to ourself and the other
	// view models like us, to take the item out of the array of items, if we
	// have this item in our array.
	func delete(item: ShoppingItem) {
		NotificationCenter.default.post(name: .shoppingItemWillBeDeleted, object: item, userInfo: nil)
		ShoppingItem.delete(item: item, saveChanges: true)
	}
	
	// updates data for a ShoppingItem
	func updateDataFor(item: ShoppingItem?, using editableData: EditableShoppingItemData) {
		
		// if item is nil, it's a signal to add a new item with the packaged data
		guard let item = item else {
			let newItem = ShoppingItem.addNewItem()
			newItem.updateValues(from: editableData)
			NotificationCenter.default.post(name: .shoppingItemAdded, object: newItem)
			return
		}
		
		// the item is not nil, so it's a normal update
		item.updateValues(from: editableData)
		ShoppingItem.saveChanges()
		NotificationCenter.default.post(name: .shoppingItemEdited, object: item)
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
