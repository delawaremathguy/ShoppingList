//
//  ShoppingListTabView2.swift
//  ShoppingList
//
//  Created by Jerry on 6/4/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

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
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var fetchedShoppingItems: FetchedResults<ShoppingItem>
	
	@State private var isAddNewItemSheetShowing: Bool = false
	@State private var isDeleteItemAlertShowing: Bool = false
	@State private var itemToDelete: ShoppingItem?

	var body: some View {
		VStack {
			
			// 1. add new item "button" is at top.  note that this will put up the AddorModifyShoppingItemView
			// inside its own NaviagtionView (so the Picker will work!) but we must pass along the
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

			// 2. now comes the sectioned list of items, by Location (or a "no items" message)
			if fetchedShoppingItems.isEmpty {
				emptyListView(listName: "Shopping")
			} else {
				
				List {
					ForEach(locations(for: fetchedShoppingItems)) { location in
						Section(header: MySectionHeaderView(title: location.name!)) {
							
							ForEach(self.fetchedShoppingItems.filter({ $0.location! == location })) { item in
								
								// display a single row here for 'item'
								
								NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
									ShoppingItemRowView(itemData: ShoppingItemRowData(item: item, showLocation: false))
										.contextMenu {
											shoppingItemContextMenu(for: item, deletionTrigger: {
												self.itemToDelete = item
												self.isDeleteItemAlertShowing = true
											})
									}
								}
								.listRowBackground(backgroundColor(for: item))
								
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
											ShoppingItem.delete(item: self.itemToDelete!, saveChanges: true)
								})
					}

				}  // end of List
					.listStyle(GroupedListStyle())
				
				// clear/ mark as unavailable shopping list buttons
				if !fetchedShoppingItems.isEmpty {
					Divider()
					SLCenteredButton(title: "Move All Items off-list", action: { ShoppingItem.moveAllItemsOffList() })
						.padding([.bottom], 6)

					if fetchedShoppingItems.compactMap({ !$0.isAvailable ? "Unavailable" : nil }).count > 0 {
						SLCenteredButton(title: "Mark All Items Available", action: self.markAllAvailable )
							.padding([.bottom], 6)

					}
				}

			} // end of else for if shoppingItems.isEmpty
		} // end of VStack
	} // end of body: some View
			
	func locations(for items: FetchedResults<ShoppingItem>) -> [Location] {
		// we first get the locations of each of the shopping items.
		// compactMap seems a better choice than map because of the FetchResults issue
		// -- the result will be [Location]
		let allLocations = items.compactMap({ $0.location })
		// then turn these into a Set (which causes all duplicates to be removed)
		// and sort by visitationOrder (which gives an array)
		return Set(allLocations).sorted(by: <)
	}

	func handleOnDeleteModifier(at indexSet: IndexSet, within location: Location) {
		
		// recreate the list of items on the shopping list in this location
		// -- relies on this order being the same as the order in the ForEach above
		let itemsInThisLocation = fetchedShoppingItems.filter({ $0.location! == location })

		// you can choose what happens here according to the value of kTrailingSwipeMeansDelete
		// that is defined in Development.swift
		if kTrailingSwipeMeansDelete {
			// trigger a deletion alert/confirmation
			isDeleteItemAlertShowing = true
			itemToDelete = itemsInThisLocation[indexSet.first!]
		} else {
			// this moves the item(s) "to the other list"
			for index in indexSet {
				let item = itemsInThisLocation[index]
				item.onList.toggle()
			}
			ShoppingItem.saveChanges()
		}
		
	}
	
	func markAllAvailable() {
		fetchedShoppingItems.forEach({ $0.isAvailable = true })
		ShoppingItem.saveChanges()
	}
	
	func deleteItem() {
		ShoppingItem.delete(item: itemToDelete!, saveChanges: true)
	}

	
}

// common code for both shopping list tabs and the purchased tab

// this first one looks like there's no need, but it turns out that
// .listRowBackground doesn't like the syntax of Color(item.backgroundColor)
// on its own (?)
func backgroundColor(for item: ShoppingItem) -> Color {
	return Color(item.backgroundColor)
}

// simplifies the code for what to show when a list is empty
@ViewBuilder
func emptyListView(listName: String) -> some View {

	Group {
		Text("There are no items")
			.padding([.top], 200)
		Text("on your \(listName) List.")
	}
	.font(.title)
	.foregroundColor(.secondary)
	Spacer()
}

/// Builds out a context menu for a ShoppingItem that can be used in the shopping list
/// or the purchased list to quickly move the item to the other list, toggle the state
/// of the availability, and delete the item.
/// - Parameter item: a ShoppingItem
/// - Parameter deletionTrigger: a closure to call to set state veriables and put up an "Are you sure?" alert before allowing deletion of the item
/// - Returns: none
@ViewBuilder
func shoppingItemContextMenu(for item: ShoppingItem, deletionTrigger: @escaping () -> Void) -> some View {
	Button(action: {
		item.onList.toggle()
		ShoppingItem.saveChanges()
	}) {
		Text(item.onList ? "Mark Purchased" : "Move to ShoppingList")
			Image(systemName: item.onList ? "purchased" : "cart")
	}
	
	Button(action: { item.mark(available: !item.isAvailable, saveChanges: true) }) {
		Text(item.isAvailable ? "Mark as Unavailable" : "Mark as Available")
		Image(systemName: item.isAvailable ? "pencil.slash" : "pencil")
	}
	
	if !kTrailingSwipeMeansDelete {
		Button(action: {
			deletionTrigger()
		}) {
			Text("Delete This Item")
			Image(systemName: "minus.circle")
		}
	}
}


