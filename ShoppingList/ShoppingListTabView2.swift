//
//  ShoppingListTabView2.swift
//  ShoppingList
//
//  Created by Jerry on 6/4/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

// MAJOR OPENING COMMENT.  THIS IS WHERE EVERYTHING BREAKS IN TRYING TO SECTION-OUT
// THE SHOPPING LIST BY LOCATION.  WHATEVER YOU SEE HERE IS NOT WORKING EXACTLY
// BUT IT'S VERY CLOSE.  THIS WHOLE SECTION OF CODE IS MY PLAYGROUND.
// I WOULD NOT TELL YOU THAT IT'S THE RIGHT WAY TO DO IT, I'M WORKING
// ON IT, BUT THE CURRENT VERSION OCCASIONALLY (AND NOT PREDICTABLY THAT I CAN TELL)
// WILL CRASH UPON A TRUE DELETE OF SOME ITEMS WHEN RETURNING TO THIS VIEW.


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
			
			// add new item "button" is at top
			NavigationLink(destination: AddorModifyShoppingItemView(addItemToShoppingList: true)) {
				Text("Add New Item")
					.foregroundColor(Color.blue)
					.padding(10)
			}
			
			// now comes the sectioned list of items, by Location
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
					
					
					// clear shopping list button (yes, it's the last thing in the list
					// but i don't want it at the bottom, in case you accidentally hit
					// it while moving to the purchased item list
					if !shoppingItems.filter({ $0.onList }).isEmpty {
						HStack {
							Spacer()
							Button("Move All Items off-list") {
								self.clearShoppingList()
							}
							.foregroundColor(Color.blue)
							Spacer()
						}
					}
					
				}  // end of List
					.listStyle(GroupedListStyle())
			} // end of else
			
		} // end of VStack
	} // end of body: some View
		
	func locations(for items: FetchedResults<ShoppingItem>) -> [Location] {
		let d = Dictionary(grouping: items, by: { $0.location })
		let sortedKeys = d.keys.sorted(by: {$0!.visitationOrder < $1!.visitationOrder })
		return sortedKeys.map({ $0! })
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
		if let location = item.location {
			return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
		}
		return Color.red
	}
}
