//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by Jerry on 7/29/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// a ShoppingListViewModel object provides a window into the Code Data store that
// can be used by ShoppingListTabView and PurchasedTabView.
// it provides both data out for the view to consume, and handles user intents from the View
// back to Core Data (with notification to the View that the viewModel has changed).

class ShoppingListViewModel: ObservableObject {
		
	// since we're really wrapping four different types of ShoppingListViewModel here
	// all together, it's useful to define the types for clarity, and record which one we are
	enum viewModelUsageType {
		case shoppingList 		// drives ShoppingListTabView
		case purchasedItemShoppingList 		// drives PurchasedTabView
		case locationSpecificShoppingList(Location?)	// drives LocationsTabView with associated data
	}
	var usageType: viewModelUsageType
		
	// the items on our list
	@Published var items = [ShoppingItem]()
	
	// have we ever been loaded or not?  once is enough, thank you.  the reason
	// is that we will see notifications for all creations, deletions, and updates
	// for the items we manage, so can male appropriate modifications to the items
	// array without having to go back to Core Data and refetch
	private var dataHasBeenLoaded = false
		
	// quick accessors as computed properties
	var itemCount: Int { items.count }
	var hasUnavailableItems: Bool { items.count(where: { !$0.isAvailable }) > 0 }
	
	// MARK: - Initialization and Startup
	
	// init to be one of four different types. for a location-specific model, the
	// type will have associated data of the location we're attached to
	init(type: viewModelUsageType) {
		usageType = type
		// sign us up for ShoppingItem change operations, and also for Location changes
		// because the order of the items will change if a Location is deleted or have
		// its visitationOrder modified
		NotificationCenter.default.addObserver(self, selector: #selector(shoppingItemAdded),
																					 name: .shoppingItemAdded, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(shoppingItemEdited),
																					 name: .shoppingItemEdited, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(shoppingItemWillBeDeleted),
																					 name: .shoppingItemWillBeDeleted, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationEdited),
																					 name: .locationEdited, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationWillBeDeleted),
																					 name: .locationWillBeDeleted, object: nil)
	}
	
	// call this loadItems once the object has been created, before using it. in usage,
	// i have called this in .onAppear(), and even though onAppear() can be called
	// multiple times on the same View -- that's why we have the dataHasBeenLoaded so
	// that we're not constantly reloading the items array.  after all, all changes
	// to items come through us, no matter whether we are on- or off-screen, so we
	// claim that we're always in the right state once loaded.
	func loadItems() {
		if !dataHasBeenLoaded {
			switch usageType {
				case .shoppingList: //, .multiSectionShoppingList:
					items = ShoppingItem.currentShoppingList(onList: true)
				case .purchasedItemShoppingList:
					items = ShoppingItem.currentShoppingList(onList: false)
				case .locationSpecificShoppingList(let location):
					if let locationItems = location!.items as? Set<ShoppingItem> {
						items = Array(locationItems)
				}
			}
			print("shopping list loaded. \(items.count) items.")
			sortItems()
			dataHasBeenLoaded = true
		}
	}

	
	// MARK: - Responses to changes in ShoppingItem objects
	
	// ALL OF THESE FUNCTIONS RESPOND TO NOTIFICATIONS that an item has possibly
	// been created, edited, or deleted.  Each must determine whether
	// the event affects the items array.  Note that no other functions
	// should be changing the items array on their own -- the whole idea is that
	// sending a notification let's every other shopping list view model know about
	// the change so they can adjust their own list of items.
	
	@objc func shoppingItemAdded(_ notification: Notification) {
		// the notification has a reference to the item that has been added.
		// if we're interested in it, now's the time to add it to the items array.
		guard let item = notification.object as? ShoppingItem else { return }
		if !items.contains(item) && isOurKind(item: item) {
			addToItems(item: item)
		}
	}

	@objc func shoppingItemEdited(_ notification: Notification) {
		guard let item = notification.object as? ShoppingItem else { return }
		// the logic here is mostly:
		// -- did the edit kick the item off our list? if yes, remove it
		// -- did the edit put the item on our list? if so, add it
		// -- if it's on the list, sort the items (the edit may have changed the sorting order)
		// -- otherwise, we don't care
		if items.contains(item) && !isOurKind(item: item) {
			removeFromItems(item: item)
		} else if !items.contains(item) && isOurKind(item: item) {
			addToItems(item: item)
		} else if items.contains(item) {
			sortItems()  // an edit may have compromised the sort order
		}
	}
	
	@objc func shoppingItemWillBeDeleted(_ notification: Notification) {
		// the notification has a reference to the item that will be deleted.
		// if we're holding on to it, now's the time to remove it from the items array.
		guard let item = notification.object as? ShoppingItem else { return }
		if items.contains(item) {
			removeFromItems(item: item)
		}
	}
	
	@objc func locationEdited(_ notification: Notification) {
		// the notification has a reference to the location that was edited.  we need
		// to see this notification: if the location's visitationOrder has been changed, that
		// (may) require a new sort of the items if any item is affected by the change.
		guard let location = notification.object as? Location else { return }
		switch usageType {
			case .shoppingList:
				if !items.allSatisfy({ $0.location! == location }) {
					sortItems()
			}
			case .purchasedItemShoppingList, .locationSpecificShoppingList(_):
				break
		}
	}
		
	@objc func locationWillBeDeleted(_ notification: Notification) {
		// the notification has a reference to the location that will be deleted.  we need
		// to see this notification: changes to the location's name will be handled fine
		// in display, but if the location's visitationOrder has been changed, that
		// (may) require a new sort of the items if any item is affected by the change.
		guard let location = notification.object as? Location else { return }
		if !items.allSatisfy({ $0.location! == location }) {
			sortItems()
		}
	}
		
	// says whether a shopping item is of interest to us.
	func isOurKind(item: ShoppingItem) -> Bool {
		switch usageType {
			case .shoppingList: //, .multiSectionShoppingList:
				return item.onList == true
			case .purchasedItemShoppingList:
				return item.onList == false
			case .locationSpecificShoppingList(let location):
				return item.location == location! // this must be not nil
		}
	}
		
	// we keep the items array sorted at all times.  whenever the content of the items array
	// changes, be sure we call sortItems(), which will trigger an objectWillChange.send().
	private func sortItems() {
		switch usageType {
			case .shoppingList: // , .multiSectionShoppingList:
				items.sort(by: { $0.name! < $1.name! }) 
				items.sort(by: { $0.location!.visitationOrder < $1.location!.visitationOrder })
			case .purchasedItemShoppingList, .locationSpecificShoppingList:
				items.sort(by: { $0.name! < $1.name! })
		}
	}
	
	// simple utility to remove an item (known to exist)
	private func removeFromItems(item: ShoppingItem) {
		let index = items.firstIndex(of: item)!
		items.remove(at: index) // will not change the sort order of the item array
	}

	// simple utility to add an item (that we know should be on our list)
	private func addToItems(item: ShoppingItem) {
		items.append(item) // may have compromised the sort order
		sortItems()
	}

	// MARK: - User Intents
	
	// ALL FUNCTIONS IN THIS AREA do CRUD changes to an item directly and then send
	// a notification to this and to all other shopping list view models that we've done
	// something to an item. if those view models are interested in the item, then
	// they will adjust their items array accordingly and will publish the change
	
	// changes availability flag for an item
	func toggleAvailableStatus(for item: ShoppingItem) {
		item.isAvailable.toggle()
		NotificationCenter.default.post(name: .shoppingItemEdited, object: item)
		ShoppingItem.saveChanges()
	}
	
	// changes onList status for a single item
	func moveToOtherList(item: ShoppingItem) {
		item.onList.toggle()
		NotificationCenter.default.post(name: .shoppingItemEdited, object: item)
		ShoppingItem.saveChanges()
	}
	
	// changes onList status for an array of items
	func moveToOtherList(items: [ShoppingItem]) {
		for item in items {
			item.onList.toggle()
			NotificationCenter.default.post(name: .shoppingItemEdited, object: item)
		}
		ShoppingItem.saveChanges()
	}
	
	// moves all items off the current list.  that means our array
	// will shrink down to the empty array
	func moveAllItemsToOtherList() {
		for item in items {
			item.onList.toggle()
			NotificationCenter.default.post(name: .shoppingItemEdited, object: item)
		}
		ShoppingItem.saveChanges()
	}
	
	// marks all items in the display as available
	func markAllItemsAvailable() {
		for item in items where !item.isAvailable {
			item.isAvailable = true
			NotificationCenter.default.post(name: .shoppingItemEdited, object: item)
		}
		ShoppingItem.saveChanges()
	}
	
	// deletes an item.  this results in a callback (notification), both to ourself and all other
	// view models like us, to take the item out of the array of items before
	// we delete it from Core Data
	func delete(item: ShoppingItem) {
		ShoppingItem.delete(item: item, saveChanges: true)
	}
	
	// updates data for a ShoppingItem
	func updateData(for item: ShoppingItem?, using editableData: EditableShoppingItemData) {
		
		if let item = item {
			item.updateValues(from: editableData)
			NotificationCenter.default.post(name: .shoppingItemEdited, object: item)
		} else {
			let newItem = ShoppingItem.addNewItem()
			newItem.updateValues(from: editableData)
			NotificationCenter.default.post(name: .shoppingItemAdded, object: newItem)
		}
		
		ShoppingItem.saveChanges()
	}
		
	// MARK: - Functions used by a multi-section view model
	
	// provides a list of locations currently represented by objects in
	// the items array to drive the sections of the list
	func locationsForItems() -> [Location] {
		// returns all the locactions associated with our items, sorted by visitation order.
		// we first get the locations of each of the shopping items.
		let allLocations = items.map({ $0.location! })
		// then turn these into a Set (which causes all duplicates to be removed)
		// and sort by visitationOrder (which gives an array)
		return Set(allLocations).sorted(by: <)
	}
	
	// returns the items at a location to drive list items in each section
	func items(at location: Location) -> [ShoppingItem] {
		return items.filter({ $0.location! == location }).sorted(by: { $0.name! < $1.name! }) 
	}

}
