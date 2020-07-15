//
//  PurchasedItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// a simple list of items that are not on the current shopping list
// these are the items that were on the shopping list at some time and
// were later removed -- items we purchased.  you could also call it a
// catalog, of sorts, although we only show items that we know about
// that are not already on the shopping list.

struct PurchasedTabView: View {
	
	// CoreData setup
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == false")
	) var purchasedItems: FetchedResults<ShoppingItem>
	
	// the usual @State variables to handle the Search field and control
	// the action of the confirmation alert that you really do want to
	// delete an item
	@State private var searchText: String = ""
	@State private var isDeleteItemAlertShowing: Bool = false
	@State private var itemToDelete: ShoppingItem?
	@State private var isAddNewItemSheetShowing = false

	var body: some View {
		NavigationView {
		VStack {
			SearchBarView(text: $searchText)
			
			// 1. add new item "button" is at top.  note that this will put up the AddorModifyShoppingItemView
			// inside its own NaviagtionView (so the Picker will work!) but we must pass along the
			// managedObjectContext manually because sheets don't automatically inherit the environment
			AddNewShoppingItemButtonView(isAddNewItemSheetShowing: $isAddNewItemSheetShowing,
																	 managedObjectContext: managedObjectContext,
																	 addItemToShoppingList: false)

			if purchasedItems.isEmpty {
				EmptyListView(listName: "Purchased")
			} else {
				
				// Report purchased item count, or the number of items matching the
				// current search text, essentially as a section header for just the one section
				SLSimpleHeaderView(label: sectionHeaderTitle())
				List {
					ForEach(purchasedItems.filter({ searchTextAppears(in: $0.name!) })) { item in
						NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
							ShoppingItemRowView(itemData: ShoppingItemRowData(item: item))
								.contextMenu {
									shoppingItemContextMenu(for: item, deletionTrigger: {
										self.itemToDelete = item
										self.isDeleteItemAlertShowing = true
									})
							}
						} // end of NavigationLink
					} // end of ForEach
						.onDelete(perform: handleOnDeleteModifier)
						.alert(isPresented: $isDeleteItemAlertShowing) {
							Alert(title: Text("Delete \'\(itemToDelete!.name!)\'?"),
										message: Text("Are you sure you want to delete this item?"),
										primaryButton: .cancel(Text("No")),
										secondaryButton: .destructive(Text("Yes"),
										action: {
											ShoppingItem.delete(item: self.itemToDelete!, saveChanges: true)
										})
							)}
					
				}  // end of List
				
			} // end of if-else
		} // end of VStack
			.navigationBarTitle("Purchased List")
			.navigationBarItems(
				trailing:
				Button(action: { self.isAddNewItemSheetShowing = true }) {
					Image(systemName: "plus")
						.resizable()
						.frame(width: 16, height: 16)
			})

		} // end of NavigationView
	}
	
	func sectionHeaderTitle() -> String {
		if searchText.isEmpty {
			return "Items Listed: \(purchasedItems.count)"
		}
		let itemsShowing = purchasedItems.filter({ searchTextAppears(in: $0.name!) })
		return "Items Matching \"\(searchText)\": \(itemsShowing.count)"
	}
	
	func handleOnDeleteModifier(indexSet: IndexSet) {
		
		// identify what items these indices refer to
		let items = purchasedItems.filter({ searchTextAppears(in: $0.name!) })
		
		// you can choose what happens here according to the value of kTrailingSwipeMeansDelete
		// that is defined in Development.swift
		if kTrailingSwipeMeansDelete {
			// trigger a deletion alert/confirmation
			isDeleteItemAlertShowing = true
			itemToDelete = purchasedItems[indexSet.first!]
		} else {
			// this moves the item(s) "to the other list"
			indexSet.forEach({ items[$0].onList.toggle() })
			ShoppingItem.saveChanges()
		}
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
