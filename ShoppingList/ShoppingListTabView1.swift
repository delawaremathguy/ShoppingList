//
//  ContentView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

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
					.foregroundColor(Color.blue)
					.padding(10)
			}
						
		List {
			// one main section, showing all items
			Section(header: Text("Items Listed: \(shoppingItems.count)")) {
				ForEach(shoppingItems) { item in
					NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
						ShoppingItemRowView(item: item) 
					}
					.listRowBackground(self.textColor(for: item))
				} // end of ForEach
					.onDelete(perform: moveToPurchased)
								
				// clear shopping list button (yes, it's the last thing in the list
				// but i don't want it at the bottom, in case you accidentally hit
				// it while moving to the purchased item list
				if !shoppingItems.isEmpty {
					HStack {
						Spacer()
						Button("Move All Items off-list") {
							self.clearShoppingList()
						}
						.foregroundColor(Color.blue)
						Spacer()
					}
				}
				
			} // end of Section
		}  // end of List
			.listStyle(GroupedListStyle())
		} // end of VStack
	}
	
	func sectionTitle(for items: [ShoppingItem]) -> Text {
		if let firstItem = items.first {
			return Text(firstItem.location!.name!)
		}
		return Text("Title")
	}
	
	func clearShoppingList() {
		for item in shoppingItems {
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}
	
	func moveToPurchased2(at indexSet: IndexSet, in items: [ShoppingItem]) {
		for index in indexSet {
			let item = items[index]
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}
	
	func moveToPurchased(indexSet: IndexSet) {
		for index in indexSet {
			let item = shoppingItems[index]
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}
	
	func textColor(for item: ShoppingItem) -> Color {
		if let location = item.location {
			return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
		}
		return Color.red
	}
}

