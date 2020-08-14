//
//  ShoppingListTabView2.swift
//  ShoppingList
//
//  Created by Jerry on 6/4/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

THIS VIEW IS NO LONGER USED AND THE FILE WILL NOT COMPILE
BECAUSE OF THIS TEXT IN THE FILE.

// this is a "less-than-straightforward" list display of items on the shopping list.
// in this view, we mirror most of the code from ShoppingListTabView1, but the
// inner view constructs handles sectioning of the list by Location.
// we use a ShoppingListViewModel object to mediate for use between the
// data that's over in Core Data and the data we need to drive this View.
// in particular, the viewModel object provides the sectioning information
// we need

// MAJOR OPENING COMMENT.  This is about the most solid version of sectioning
// code that i have come up with.  however, since this whole project is a
// work in progress, you should know this code for sections has been written, rewritten,
// and then thrown out and i started all over again.  the key to this was
// getting the right ForEach argument at the start of the List, and the function
// locations(for: shoppingItems) makes it clear that the entire visual layout is
// dependent on shoppingItems, and that seems to be what guarantees that things
// really do get updated visually after editing.

struct ShoppingListTabView2: View {
	// Core Data access for the context and the items on shopping list
	@Environment(\.managedObjectContext) var managedObjectContext
	
	@State private var isAddNewItemSheetShowing: Bool = false
	@State private var isDeleteItemAlertShowing: Bool = false
	@State private var itemToDelete: ShoppingItem?
	@ObservedObject var viewModel = ShoppingListViewModel(type: .shoppingList)

	// access to section option (just so we can change the MainView's section preference)
	@Binding var multiSectionDisplay: Bool
	
	var body: some View {
		NavigationView {
		VStack(spacing: 0) {
			
			// 1. add new item "button" is at top.  note that this will put up the AddorModifyShoppingItemView
			// inside its own NavigationView (so the Picker will work!) but we must pass along the
			// managedObjectContext manually because sheets don't automatically inherit the environment
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

			// 2. now comes the sectioned list of items, by Location (or a "no items" message)
			if viewModel.itemCount == 0 {
				EmptyListView(listName: "Shopping")
			} else {

				SLSimpleHeaderView(label: "Items Listed: \(viewModel.itemCount)")
				List {
					ForEach(viewModel.locationsForItems()) { location in
						Section(header: SLSectionHeaderView(title: location.name!)) {
							
							ForEach(self.viewModel.items(at: location)) { item in
								
								// display a single row here for 'item'
								NavigationLink(destination: AddorModifyShoppingItemView(viewModel: self.viewModel, editableItem: item)) {
									ShoppingItemRowView(itemData: ShoppingItemRowData(item: item, showLocation: false))
										.contextMenu {
											shoppingItemContextMenu(viewModel: self.viewModel, for: item, deletionTrigger: {
												self.itemToDelete = item
												self.isDeleteItemAlertShowing = true
											})
									}
								}
								//.listRowBackground(Color(item.backgroundColor))
								
							} // end of ForEach
								.onDelete(perform: { offsets in
									self.handleOnDeleteModifier(at: offsets, within: location)
								})
							
						} // end of Section
					} // end of ForEach
						.alert(isPresented: $isDeleteItemAlertShowing) {
							Alert(title: Text("Delete \'\(itemToDelete!.name!)\'?"),
										message: Text("Are you sure you want to delete this item?"),
										primaryButton: .cancel(Text("No")),
										secondaryButton: .destructive(Text("Yes")) {
											self.viewModel.delete(item: self.itemToDelete!)
								})
					}

				}  // end of List
					.listStyle(GroupedListStyle())
				
				// clear/mark as unavailable shopping list buttons
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
					Button(action: { self.multiSectionDisplay = false }) {
						Image(systemName: "tray.2")
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
//				print("onAppear in ShoppingListTabView2")
				self.viewModel.loadItems()
			}
//			.onReceive(viewModel.objectWillChange) { _ in
//				print("objectWillChange received in ShoppingListTabView2")
//			}
	} // end of body: some View
			
	func handleOnDeleteModifier(at indexSet: IndexSet, within location: Location) {
		
		// first, recreate the list of items on the shopping list for this location
		// -- relies on this order being the same as the order in the ForEach above
		let itemsInThisLocation = viewModel.items(at: location)

		// you can choose what happens here according to the value of kTrailingSwipeMeansDelete
		// that is defined in Development.swift
		if kTrailingSwipeMeansDelete {
			// trigger a deletion alert/confirmation
			isDeleteItemAlertShowing = true
			itemToDelete = itemsInThisLocation[indexSet.first!]
		} else {
			// this moves the item(s) "to the other list"
			viewModel.moveToOtherList(items: indexSet.map({ itemsInThisLocation[$0] }))
		}
	}
	
}

