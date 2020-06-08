//
//  PurchasedItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// ONE MAJOR ITEM.  my method of deleting (tap, go to edit screen,
// tap "Delete This Item," and then returning was working EXCEPT FOR ONE CASE:
// if the list has only one item and you use this delete methodology,
// the program would crash.  I'm still interested in resolving this bug, but I
// have for now patched the code that was crashing in ShoppingItemRowView.
// you can see a note there


struct PurchasedTabView: View {
	
	// CoreData setup
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == false")
	) var purchasedItems: FetchedResults<ShoppingItem>
	
	@State private var searchText: String = ""
	
	var body: some View {
			
		VStack {
			SearchBarView(text: $searchText)

			// add new item stays at top
			NavigationLink(destination: AddorModifyShoppingItemView(addItemToShoppingList: false)) {
				Text("Add New Item")
					.padding(10)
			}
			
			List {
				Section(header: MySectionHeaderView(title: sectionHeaderTitle())) {
					ForEach(purchasedItems.filter({ searchTextAppears(in: $0.name!) })) { item in 
						NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
							FlawedShoppingItemRowView(item: item)
						} // end of NavigationLink
					} // end of ForEach
						.onDelete(perform: moveToShoppingList)
				} // end of Section
			}  // end of List
				.listStyle(GroupedListStyle())
			
		} // end of VStack
	}
	
	func sectionHeaderTitle() -> String {
		if searchText.isEmpty {
			return "Items Listed: \(purchasedItems.count)"
		}
		let itemsShowing = purchasedItems.filter({ searchTextAppears(in: $0.name!) })
		return "Items Matching \"\(searchText)\": \(itemsShowing.count)"
	}
	
	func moveToShoppingList(indexSet: IndexSet) {
		// the indexSet refers to indices in what's showing -- the filtered list
		let itemsShowing = purchasedItems.filter({ searchTextAppears(in: $0.name!) })
		for index in indexSet {
			let item = itemsShowing[index]
			item.onList = true
		}
		ShoppingItem.saveChanges()
	}
	
	// i added this so that the search is not case sensistive, and also just to
	// simplify the original coding of the filter function used in ForEach
	func searchTextAppears(in name: String) -> Bool {
		let cleanedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		if cleanedSearchText.isEmpty {
			return true
		}
		return name.localizedCaseInsensitiveContains(cleanedSearchText.lowercased())
	}
	
}
