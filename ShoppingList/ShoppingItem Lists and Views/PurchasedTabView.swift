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
	
	// the usual @State variables to handle the Search field and control
	// the action of the confirmation alert that you really do want to
	// delete an item
	@State private var searchText: String = ""
	@State private var isDeleteItemAlertShowing: Bool = false
	@State private var itemToDelete: ShoppingItem?
	@State private var isAddNewItemSheetShowing = false
	@ObservedObject var viewModel = ShoppingListViewModel(type: .purchasedItemShoppingList)
	
	var body: some View {
		NavigationView {
			VStack {
				SearchBarView(text: $searchText)
				
				// 1. add new item "button" is at top.  note that this will put up the AddorModifyShoppingItemView
				// inside its own NavigationView (so the Picker will work!)
				Button(action: { self.isAddNewItemSheetShowing = true }) {
					Text("Add New Item")
						.foregroundColor(Color.blue)
						.padding(10)
				}
				.sheet(isPresented: $isAddNewItemSheetShowing) {
					NavigationView {
						AddorModifyShoppingItemView(viewModel: self.viewModel, addItemToShoppingList: false)
					}
				}
				
				if viewModel.itemCount == 0 {
					EmptyListView(listName: "Purchased")
				} else {
					
					// Report purchased item count, or the number of items matching the
					// current search text, essentially as a section header for just the one section
					SLSimpleHeaderView(label: sectionHeaderTitle())
					List {
						ForEach(viewModel.items.filter({ searchTextAppears(in: $0.name!) })) { item in
							NavigationLink(destination: AddorModifyShoppingItemView(viewModel: self.viewModel, editableItem: item)) {
								ShoppingItemRowView(itemData: ShoppingItemRowData(item: item))
									.contextMenu {
										shoppingItemContextMenu(viewModel: self.viewModel, for: item, deletionTrigger: {
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
												self.viewModel.delete(item: self.itemToDelete!)
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
								.frame(width: 20, height: 20)
						}
					)
			
		} // end of NavigationView
			.onAppear {
				print("PurchasedTabView appear")
				self.viewModel.loadItems()
				self.searchText = ""
		}
		.onDisappear { print("PurchasedTabView disappear") }

	}
	
	func sectionHeaderTitle() -> String {
		if searchText.isEmpty {
			return "Items Listed: \(viewModel.itemCount)"
		}
		let itemsShowing = viewModel.items.filter({ searchTextAppears(in: $0.name!) })
		return "Items Matching \"\(searchText)\": \(itemsShowing.count)"
	}
	
	func handleOnDeleteModifier(indexSet: IndexSet) {
		
		// identify what items these indices refer to
		let items = viewModel.items.filter({ searchTextAppears(in: $0.name!) })
		
		// you can choose what happens here according to the value of kTrailingSwipeMeansDelete
		// that is defined in Development.swift
		if kTrailingSwipeMeansDelete {
			// trigger a deletion alert/confirmation
			isDeleteItemAlertShowing = true
			itemToDelete = items[indexSet.first!]
		} else {
			// this moves the item(s) "to the other list"
			viewModel.moveToOtherList(items: indexSet.map({ items[$0] }))
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
