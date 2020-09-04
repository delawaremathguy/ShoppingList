//
//  ContentView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// this is a list display of items on the shopping list. we use a ShoppingListViewModel
// object to mediate for us between the data that's over in Core Data and the
// data we need to drive this View.  the view will display either as a single
// section list, or a multi-section list (initial display is single section), with
// these areas of the view handled by separate views, each of which has its own,
// specific List/ForEach constructs.

struct ShoppingListTabView: View {
	// our view model = a window into Core Data so we can use it and be
	// notified when changes are made via the ObservableObject protocol
	@ObservedObject var viewModel = ShoppingListViewModel(type: .shoppingList)

	// local state to trigger showing a sheet to add a new item
	@State private var isAddNewItemSheetShowing = false
	// local states to trigger a destructive Alert either to delete
	// an item, or to move all items off the list
	@State private var isDestructiveAlertShowing = false
	@State private var itemToDelete: ShoppingItem? // item to delete, if that's what we want to do
	@State private var destructiveMoveToOtherList = false  // set to true if moving to other list
	
	// local state for are we a multisection display or not.  this must remain in
	// sync with the global setting (in case this View is destroyed and later recreated)
	@State var multiSectionDisplay: Bool = gShowMultiSectionShoppingList
	
	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				
/* ---------
1. add new item "button" is at top.  note that this will put up the
AddorModifyShoppingItemView inside its own NavigationView (so the Picker will work!)
----------*/
				
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
				
/* ---------
2. we display either a "List is Empty" view, a single-section shopping list view
or multi-section shopping list view.  these call out to other views below, because
the looping construct is quite different, as is how the .onDelete() modifier is
invoked on an item in the list
----------*/

				if viewModel.itemCount == 0 {
					EmptyListView(listName: "Shopping")
				} else {
					SLSimpleHeaderView(label: "Items Listed: \(viewModel.itemCount)")
					if multiSectionDisplay {
						MultiSectionShoppingListView(viewModel: viewModel,
																				 isDeleteItemAlertShowing: $isDestructiveAlertShowing,
																				 itemToDelete: $itemToDelete,
																				 processSwipeToDelete: handleMultiOnDeleteModifier)
					} else {
						SingleSectionShoppingListView(viewModel: viewModel,
																					isDeleteItemAlertShowing: $isDestructiveAlertShowing,
																					itemToDelete: $itemToDelete,
																					processSwipeToDelete: handleOnDeleteModifier)
					}
				}
		
/* ---------
3. for non-empty lists, we tack on a few buttons at the end.
----------*/

				// clear/ mark as unavailable shopping list buttons
				if viewModel.itemCount > 0 {
					Rectangle()
						.frame(minWidth: 0, maxWidth: .infinity, minHeight: 1, idealHeight: 1, maxHeight: 1)
					
					SLCenteredButton(title: "Move All Items Off-list", action: {
						// setting tese allow the Alert to come up with the right messages and actions
						self.destructiveMoveToOtherList = true
						self.isDestructiveAlertShowing = true
						})
						.padding([.bottom, .top], 6)
					
					if viewModel.hasUnavailableItems {
						SLCenteredButton(title: "Mark All Items Available", action: { self.viewModel.markAllItemsAvailable() })
							.padding([.bottom], 6)
						
					}
				} //end of if viewModel.itemCount > 0

			} // end of VStack
				.navigationBarTitle("Shopping List")
				
				.navigationBarItems(
					leading:
						Button(action: {
							self.multiSectionDisplay.toggle()
							gShowMultiSectionShoppingList.toggle()
						}) {
							Image(systemName: self.multiSectionDisplay ? "tray.2" : "tray")
								.resizable()
								.scaledToFill()
								.frame(height: 20)
					},
					trailing:
						Button(action: { self.isAddNewItemSheetShowing = true }) {
							Image(systemName: "plus")
								.resizable()
								.frame(width: 20, height: 20)
					})
				
				.alert(isPresented: $isDestructiveAlertShowing) {
					Alert(title: Text(destructiveAlertTitle()),
								message: Text(destructiveAlertMessage()),
								primaryButton: .cancel(Text("No"), action: destructiveAlertCancel),
								secondaryButton: .destructive(Text("Yes"), action: destructiveAlertAction)
					)
				}

			
		} // end of NavigationView
			.onAppear {
				print("ShoppingListTabView appear")
				self.viewModel.loadItems()
			}
			.onDisappear { print("ShoppingListTabView disappear") }
		
	} // end of body: some View
	
	// data to pass along to the destructive alert that eithers deletes an item
	// or moves all items off the list.  which these do depend on
	func destructiveAlertTitle() -> String {
		if destructiveMoveToOtherList {
			return "Move All Items Off-List"
		} else {
			return "Delete \'\(itemToDelete!.name!)\'?"
		}
	}
	
	func destructiveAlertMessage() -> String {
		if destructiveMoveToOtherList {
			return ""
		} else {
			return "Are you sure you want to delete this item?"
		}
	}
	
	func destructiveAlertCancel() {
		self.destructiveMoveToOtherList = false
	}
	
	func destructiveAlertAction() {
		if destructiveMoveToOtherList {
			self.viewModel.moveAllItemsToOtherList()
			self.destructiveMoveToOtherList = false
		} else if let item = itemToDelete {
			viewModel.delete(item: item)
		}
	}


	
	// this function is used to do a swipe-to-delete operation in the SingleSection
	// view of the shopping list.  we get the index set of the items to "delete,"
	// and what we do depends on what you mean by "delete" -- it's either move
	// to the other list, or it's a true delete for which we trigger an Alert
	// to ask if you really want to delete, then delete on confirm.
	func handleOnDeleteModifier(indexSet: IndexSet) {
		if kTrailingSwipeMeansDelete {
			// trigger a deletion alert/confirmation for (only) the first item
			isDestructiveAlertShowing = true
			itemToDelete = viewModel.items[indexSet.first!]
		} else {
			// this moves the item(s) "to the other list"
			let itemsToToggle = viewModel.items
			viewModel.moveToOtherList(items: indexSet.map({ itemsToToggle[$0] }))
		}
	}
	
	// same for handling a swipe-to-delete in the MultiSection view; but in
	// this case, we're getting both the index set and the location to which
	// that index set applies (just the items at the location)
	func handleMultiOnDeleteModifier(at indexSet: IndexSet, within location: Location) {
		// first, get the list of items on the shopping list for this location
		let itemsInThisLocation = viewModel.items(at: location)
		if kTrailingSwipeMeansDelete {
			// trigger a deletion alert/confirmation for (only) the first item
			isDestructiveAlertShowing = true
			itemToDelete = itemsInThisLocation[indexSet.first!]
		} else {
			// this moves the item(s) "to the other list"
			viewModel.moveToOtherList(items: indexSet.map({ itemsInThisLocation[$0] }))
		}
	}
	
}


// this is the inner section of a single section list, which is mostly just a List/ForEach
// construct with a NavgiationLink and a contextMenu for each item
struct SingleSectionShoppingListView: View {
	
	@ObservedObject var viewModel: ShoppingListViewModel
	@Binding var isDeleteItemAlertShowing: Bool
	@Binding var itemToDelete: ShoppingItem?
	
	var processSwipeToDelete: (IndexSet) -> ()
	
	var body: some View {

		List {
			// one main section, showing all items
			ForEach(viewModel.items) { item in
				// display a single row here for 'item'
				NavigationLink(destination: AddorModifyShoppingItemView(viewModel: self.viewModel, editableItem: item)) {
					ShoppingItemRowView(itemData: ShoppingItemRowData(item: item))
						.contextMenu {
							shoppingItemContextMenu(viewModel: self.viewModel,
																			for: item, deletionTrigger: {
																				self.itemToDelete = item
																				self.isDeleteItemAlertShowing = true
							})
					} // end of contextMenu
				} // end of NavigationLink
			} // end of ForEach
				.onDelete(perform: processSwipeToDelete)
		}  // end of List
		
	}
}

// this is the inner section of a multi section list, which is a much more
// complicated List/ForEach/Section/ForEach construct to break the sections
// by the locations which have items on the shopping list.  as in the single section
// version, each item has a NavigationLink and a contextMenu on it

struct MultiSectionShoppingListView: View {
	
	@ObservedObject var viewModel: ShoppingListViewModel
	@Binding var isDeleteItemAlertShowing: Bool
	@Binding var itemToDelete: ShoppingItem?
	
	var processSwipeToDelete: (IndexSet, Location) -> ()
	
	var body: some View {
		List {
			ForEach(viewModel.locationsForItems()) { location in
				Section(header: SLSectionHeaderView(title: location.name!)) {
					// display items in this location
					ForEach(self.viewModel.items(at: location)) { item in
						// display a single row here for 'item'
						NavigationLink(destination: AddorModifyShoppingItemView(viewModel: self.viewModel, editableItem: item)) {
							ShoppingItemRowView(itemData: ShoppingItemRowData(item: item, showLocation: false))
								.contextMenu {
									shoppingItemContextMenu(viewModel: self.viewModel,
																					for: item, deletionTrigger: {
																						self.itemToDelete = item
																						self.isDeleteItemAlertShowing = true
									})
							}
						}
						//.listRowBackground(Color(item.backgroundColor))
						
					} // end of ForEach
						.onDelete(perform: { offsets in
							self.processSwipeToDelete(offsets, location)
						})
					
				} // end of Section
			} // end of ForEach
		}  // end of List
			.listStyle(GroupedListStyle())
	}
}

