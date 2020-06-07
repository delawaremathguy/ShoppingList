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

// ALSO A MAJOR BUG (this is true of ShoppingListTabView1 as well).  the program will
// crash if you truly delete an item from the list which causes it to become empty.
// i'm still looking for a fix, in case you know one!


struct ShoppingListTabView2: View {
	// Core Data access for items on shopping list
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>
		
	var body: some View {
		VStack {
			
			// 1. add new item "button" is at top
			NavigationLink(destination: AddorModifyShoppingItemView(addItemToShoppingList: true)) {
				Text("Add New Item")
					.foregroundColor(Color.blue)
					.padding(10)
			}
			
			// 2. now comes the sectioned list of items, by Location (or a "no items" message)
			if shoppingItems.isEmpty {
				Text("There are no items on your Shopping List.")
				Spacer()
			} else {
				
				List {
					ForEach(locations(for: shoppingItems)) { location in
						Section(header: Text(location.name!)) {
							
							ForEach(self.shoppingItems.filter({ $0.location! == location })) { item in
								NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
									ShoppingItemRowView(item: item)
								}
								.listRowBackground(self.textColor(for: item))
							} // end of ForEach
								.onDelete(perform: { offsets in
									self.moveToPurchased(at: offsets, in: self.shoppingItems.filter({ $0.location! == location }))
								})
							
						} // end of Section
					} // end of ForEach
					
					// clear shopping list button
					HStack {
						Spacer()
						Button("Move All Items off-list") {
							self.clearShoppingList()
						}
						Spacer()
					}
					
				}  // end of List
					.listStyle(GroupedListStyle())
			} // end of else
			
		} // end of VStack
	} // end of body: some View
		
	func locations(for items: FetchedResults<ShoppingItem>) -> [Location] {
		// we first get the locations of each of the shopping items.
		// compactMap seems a better choice than map because of the FetchResults issue
		// -- the result will be [Location]
		let allLocations = items.compactMap({ $0.location })
		// then turn these into a Set (which causes all duplicates to be removed)
		// and sort by visitationOrder
		return Set(allLocations).sorted(by: <)
	}

	func moveToPurchased(at indexSet: IndexSet, in items: [ShoppingItem]) {
		for index in indexSet.reversed() {
			let item = items[index]
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}

	func clearShoppingList() {
		for item in shoppingItems {
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}

	func textColor(for item: ShoppingItem) -> Color {
		let location = item.location!
		return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
	}
}
