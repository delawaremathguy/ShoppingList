//
//  ShoppingListTabView2.swift
//  ShoppingList
//
//  Created by Jerry on 6/4/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

// MAJOR OPENING COMMENT.  This is about the most solid version of sectioning
// code that i have come up with.  however, since this whole project is a
// work in progress, you should know this code for sections has been written, rewritten,
// and then thrown out and i started all over again.  the key to this was
// getting the right ForEach argument at the start of the List, and the function
// locations(for: shoppingItems) makes it clear that the entire visual layout is
// dependent on shoppingItems, and that seems to be what guarantees that things
// really do get updated visually after editing.

// AND ONE OTHER MAJOR ITEM.  my method of deleting (tap, go to edit screen,
// tap "Delete This Item," and then returning was working EXCEPT FOR ONE CASE:
// if the list had only one item and you use this delete methodology,
// the program would crash.  I'm still interested in resolving this bug, but I
// have for now patched the code that was crashing in ShoppingItemRowView.
// you can see a note there


struct ShoppingListTabView2: View {
	// Core Data access for the context and the items on shopping list
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>
	
	@State private var isAddNewItemSheetShowing: Bool = false
	
	var body: some View {
		VStack {
			
			// 1. add new item "button" is at top of the list
			// Question: why not put this in the Navigation bar?  i can't do it here, because the
			// MainView owns the Navigation bar.  i could work around this by not having the MainView
			// live inside a NavigationView and put this view inside a NavigationView,
			// but then when i NavigationLink my way off to Add/Modify
			// an item, the tab bar of the MainView cannot be dismissed (which is what i want)
			NavigationLink(destination: AddorModifyShoppingItemView(addItemToShoppingList: true)) {
				Text("Add New Item")
					.foregroundColor(Color.blue)
					.padding(4)
			}

//			// 1. add new item "button" is at top
//			// Question: why is this not used?  because when you move to a Sheet,
//			// the Picker (for setting a Location) will be inactive because it is
//			// not inside a NavigationView.  otherwise, it would be better
//			Button(action: { self.isAddNewItemSheetShowing = true }) {
//				Text("Add New Item")
//					.foregroundColor(Color.blue)
//					.padding(10)
//			}
//			.sheet(isPresented: $isAddNewItemSheetShowing) {
//				AddorModifyShoppingItemView(addItemToShoppingList: true).environment(\.managedObjectContext, self.managedObjectContext)
//			}

			// 2. now comes the sectioned list of items, by Location (or a "no items" message)
			if shoppingItems.isEmpty {
				Spacer()
				Text("There are currently no items")
				Text("on your Shopping List.")
				Spacer()
			} else {
				
				List {
					ForEach(locations(for: shoppingItems)) { location in
						Section(header: MySectionHeaderView(title: location.name!)) {
							
							ForEach(self.shoppingItems.filter({ $0.location! == location })) { item in
								NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
									ShoppingItemRowView(item: item, showLocation: false)
										.contextMenu {
											Button("Mark Purchased") {
												item.moveToPuchased(saveChanges: true)
											}
											Button(item.isAvailable ? "Mark as Unavailable" : "Mark as Available") {
												item.mark(available: !item.isAvailable, saveChanges: true)
											}
									}
								}
								.listRowBackground(self.textColor(for: item))
							} // end of ForEach
								.onDelete(perform: { offsets in
									self.moveToPurchased(at: offsets, within: location)
								})
							
						} // end of Section
					} // end of ForEach
				}  // end of List
					.listStyle(GroupedListStyle())
				
				// clear/ mark as unavailable shopping list buttons
				if !shoppingItems.isEmpty {
					Divider()
					SLCenteredButton(title: "Move All Items off-list", action: self.clearShoppingList)
						.padding([.bottom], 6)

					if shoppingItems.compactMap({ !$0.isAvailable ? "Unavailable" : nil }).count > 0 {
						SLCenteredButton(title: "Mark All Items Available", action: self.markAllAvailable )
							.padding([.bottom], 6)

					}
				}

			} // end of else for if shoppingItems.isEmpty

			
		} // end of VStack
	} // end of body: some View
			
	func locations(for items: FetchedResults<ShoppingItem>) -> [Location] {
		// we first get the locations of each of the shopping items.
		// compactMap seems a better choice than map because of the FetchResults issue
		// -- the result will be [Location]
		let allLocations = items.compactMap({ $0.location })
		// then turn these into a Set (which causes all duplicates to be removed)
		// and sort by visitationOrder (which gives an array)
		return Set(allLocations).sorted(by: <)
	}

	func moveToPurchased(at indexSet: IndexSet, within location: Location) {
		// recreate list of items on the shopping list in this location
		// -- relies on this order being the same as the order in the ForEach above
		let itemsInThisLocation = shoppingItems.filter({ $0.location! == location })
		for index in indexSet.reversed() {
			let item = itemsInThisLocation[index]
			item.moveToPuchased()
		}
		ShoppingItem.saveChanges()
	}

	func clearShoppingList() {
		for item in shoppingItems {
			item.moveToPuchased()
		}
		ShoppingItem.saveChanges()
	}
	
	func markAllAvailable() {
		for item in shoppingItems {
			item.mark(available: true, saveChanges: true)
		}
		ShoppingItem.saveChanges()
	}

	func textColor(for item: ShoppingItem) -> Color {
		let location = item.location!
		return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
	}
}
