//
//  PurchasedItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

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
				HStack {
					Spacer()
					Text("Add New Item")
						.foregroundColor(Color.blue)
					Spacer()
				}
				.padding(.bottom, 10)
			}
			
			List {
			

			Section(header: Text("Items Listed: \(purchasedItems.count)")) {
				ForEach(purchasedItems.filter({ itemNameContainsSearchText($0.name!) })) { item in // , id:\.self
					NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
						ShoppingItemView(item: item)
					} // end of NavigationLink
				} // end of ForEach
					.onDelete(perform: moveToShoppingList)
			} // end of Section
			
		}  // end of List
			.listStyle(GroupedListStyle())
		}
	}
	
	func moveToShoppingList(indexSet: IndexSet) {
		for index in indexSet {
			let item = purchasedItems[index]
			item.onList = true
		}
		ShoppingItem.saveChanges()
	}
	
	// i added this so that the search is not case sensistive, and also just to
	// simplify the original coding of the filter function used in ForEach
	func itemNameContainsSearchText(_ name: String) -> Bool {
		if searchText.isEmpty {
			return true
		}
		return name.lowercased().contains(searchText.lowercased())
	}
	
}
