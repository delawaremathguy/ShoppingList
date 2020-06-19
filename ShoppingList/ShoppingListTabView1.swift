//
//  ContentView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

// This is just a straightforward list display of items on the shopping list.
// a simple @FetchRequest gets these items, arranged by their location's
// visitation order, a copy of which is kept in the shopping item itself.
// why is this kept here, as duplicate information?  if you change a Location's
// visitation order, copying that to the items in the location makes sure that
// this sees the changes.

// See comments over in ShoppingListTabView2, since that's where i spend more of my
// time tweaking the shopping list.

struct ShoppingListTabView1: View {
	// Core Data access for items on shopping list
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>
	
	var body: some View {
		VStack {
			
			// add new item "button" is at top
			NavigationLink(destination: AddorModifyShoppingItemView(addItemToShoppingList: true)) {
				Text("Add New Item")
					.padding(10)
			}
			
			if shoppingItems.isEmpty {
				Spacer()
				Text("There are currently no items")
				Text("on your Shopping List.")
				Spacer()
			} else {
				
				List {
					// one main section, showing all items
					Section(header: MySectionHeaderView(title: "Items Listed: \(shoppingItems.count)")) {
						ForEach(shoppingItems) { item in
							NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
								FlawedShoppingItemRowView(item: item)
									.contextMenu {
										Button("Mark Purchased") {
											item.moveToPuchased(saveChanges: true)
										}
										Button(item.isAvailable ? "Mark as Unavailable" : "Mark as Available") {
											item.mark(available: !item.isAvailable, saveChanges: true)
										}
//										Button("Delete this Item") {
//											// trigger item deletion confirmation here
//											// but at the moment, this third item drives the layout system crazy
//											// and the button will not appear (apparently this is more about
//											// SwiftUI than it is me and this code
//										}
								}
							}
							.listRowBackground(self.textColor(for: item))
						} // end of ForEach
							.onDelete(perform: moveToPurchased)
						
						// clear shopping list button (yes, it's the last thing in the list
						// but i don't want it at the bottom, in case you accidentally hit
						// it while moving to the purchased item list
						if !shoppingItems.isEmpty {
							SLCenteredButton(title: "Move All Items off-list", action: self.clearShoppingList)
							SLCenteredButton(title: "Mark All Items Available", action: {})
						}

					} // end of Section
				}  // end of List
					.listStyle(GroupedListStyle())
			} // end of else
			
		} // end of VStack
	}
	
	func clearShoppingList() {
		for item in shoppingItems {
			item.moveToPuchased()
		}
		ShoppingItem.saveChanges()
	}
	
	func moveToPurchased(indexSet: IndexSet) {
		for index in indexSet {
			let item = shoppingItems[index]
			item.moveToPuchased()
		}
		ShoppingItem.saveChanges()
	}
	
	func textColor(for item: ShoppingItem) -> Color {
		let location = item.location!
		return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
	}
}

