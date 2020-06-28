//
//  ContentView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

// This is a straightforward list display of items on the shopping list.
// a simple @FetchRequest gets these items, arranged by their location's
// visitation order, a copy of which is kept in the shopping item itself.
// why is this kept here, as duplicate information?  if you change a Location's
// visitation order, copying that to the items in the location makes sure that
// this sees the changes.

// be sure to see comments over in ShoppingListTabView2, since that's where i
// spend more of my time tweaking the shopping list code and i may not always
// keep these two views in synch

struct ShoppingListTabView1: View {
	// Core Data access for the context and the items on shopping list
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>
	
	@State private var isAddNewItemSheetShowing = false
	
	var body: some View {
		VStack {
			
			// 1. add new item "button" is at top.  note that this will put up the AddorModifyShoppingItemView
			// inside its own NaviagtionView (so the Picker will work!) and we must pass along the
			// managedObjectContext manually because sheets don't automatically inherit the environment
			Button(action: { self.isAddNewItemSheetShowing = true }) {
				Text("Add New Item")
					.foregroundColor(Color.blue)
					.padding(10)
			}
			.sheet(isPresented: $isAddNewItemSheetShowing) {
				NavigationView {
					AddorModifyShoppingItemView(allowsDeletion: false) 
						.environment(\.managedObjectContext, self.managedObjectContext)
				}
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
								ShoppingItemRowView(item: item)
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
	
	func markAllAvailable() {
		for item in shoppingItems {
			item.mark(available: true, saveChanges: true)
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

