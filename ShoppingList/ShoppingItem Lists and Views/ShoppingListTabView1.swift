//
//  ContentView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// this is a "straightforward" list display of items on the shopping list.
// we use a ShoppingListViewModel object to mediate for use between the
// data that's over in Core Data and the data we need to drive this View.

struct ShoppingListTabView1: View {
	// our view model = a window into Core Data so we can use it and be
	// notified when changes are made via the ObservableObject protocol
	@ObservedObject var viewModel = ShoppingListViewModel(type: .singleSectionShoppingList)

	// local states
	@State private var isAddNewItemSheetShowing = false
	@State private var itemToDelete: ShoppingItem?
	@State private var isDeleteItemAlertShowing = false
	
	// access to section option (just so we can change the MainView's section preference)
	@Binding var multiSectionDisplay: Bool
	
	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				
				// 1. add new item "button" is at top.  note that this will put up the AddorModifyShoppingItemView
				// inside its own NavigationView (so the Picker will work!)
				Button(action: { self.isAddNewItemSheetShowing = true }) {
					Text("Add New Item")
						.foregroundColor(Color.blue)
						.padding(10)
				}
				.sheet(isPresented: $isAddNewItemSheetShowing) {
					NavigationView {
						AddorModifyShoppingItemView(viewModel: self.viewModel, addItemToShoppingList: true)
					}
				}
				
				// 2.  now come the items, if there are any
				if viewModel.itemCount == 0 {
					EmptyListView(listName: "Shopping")
				} else {
					
					SLSimpleHeaderView(label: "Items Listed: \(viewModel.itemCount)")
					List {
						// one main section, showing all items
						ForEach(viewModel.items) { item in
							
							// display a single row here for 'item'
							NavigationLink(destination: AddorModifyShoppingItemView(viewModel: self.viewModel, editableItem: item)) {
								ShoppingItemRowView(itemData: ShoppingItemRowData(item: item))
									.contextMenu {
										shoppingItemContextMenu(viewModel: self.viewModel, for: item, deletionTrigger: {
											self.itemToDelete = item
											self.isDeleteItemAlertShowing = true
										})
								}
							}
							//.listRowBackground(Color(item.backgroundColor))
							
						} // end of ForEach
							.onDelete(perform: handleOnDeleteModifier)
							.alert(isPresented: $isDeleteItemAlertShowing) {
								Alert(title: Text("Delete \'\(itemToDelete!.name!)\'?"),
											message: Text("Are you sure you want to delete this item?"),
											primaryButton: .cancel(Text("No")),
											secondaryButton: .destructive(Text("Yes")) {
												self.viewModel.delete(item: self.itemToDelete!)
									})
						}
						
					}  // end of List
					
					// clear/ mark as unavailable shopping list buttons
					if viewModel.itemCount > 0 {
						Rectangle()
							.frame(minWidth: 0, maxWidth: .infinity, minHeight: 1, idealHeight: 1, maxHeight: 1)
						SLCenteredButton(title: "Move All Items off-list", action: { self.viewModel.moveAllItemsToOtherList() })
							.padding([.bottom, .top], 6)
						
						if viewModel.hasUnavailableItems {
							SLCenteredButton(title: "Mark All Items Available", action: { self.viewModel.markAllItemsAvailable() })
								.padding([.bottom], 6)
							
						}
					}
					
				} // end of else for if shoppingItems.isEmpty
			} // end of VStack
				.navigationBarTitle("Shopping List")
				.navigationBarItems(
					leading:
						Button(action: { self.multiSectionDisplay = true }) {
							Image(systemName: "tray")
								.resizable()
								.frame(width: 20, height: 20)
						},
					trailing:
						Button(action: { self.isAddNewItemSheetShowing = true }) {
							Image(systemName: "plus")
								.resizable()
								.frame(width: 20, height: 20)
					})
			
		} // end of NavigationView
			.onAppear {
//				print("onAppear ShoppingListTabView1")
				self.viewModel.loadItems()
			}
//			.onDisappear { print("ShoppingListTabView1 disappear") }
//		.onReceive(viewModel.objectWillChange) { _ in
//			print("objectWillChange received in ShoppingListTabView1")
//		}

		
	} // end of body: some View
	
	func handleOnDeleteModifier(indexSet: IndexSet) {
		// you can choose what happens here according to the value of kTrailingSwipeMeansDelete
		// that is defined in Development.swift
		if kTrailingSwipeMeansDelete {
			// trigger a deletion alert/confirmation for (only) the first item
			isDeleteItemAlertShowing = true
			itemToDelete = viewModel.items[indexSet.first!]
		} else {
			// this moves the item(s) "to the other list"
			let itemsToToggle = viewModel.items
			viewModel.moveToOtherList(items: indexSet.map({ itemsToToggle[$0] }))
		}
	}
	
}

