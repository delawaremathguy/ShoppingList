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
	) var shoppingItems: FetchedResults<ShoppingItem>
	
	@State private var isAddNewItemSheetShowing: Bool = false
	@State private var isDeleteItemAlertShowing: Bool = false
	@State private var itemToDelete: ShoppingItem?

	var body: some View {
		VStack {
			
			// 1. add new item "button" is at top.  note that this will put up the AddorModifyShoppingItemView
			// inside its own NavigationView (so the Picker will work!) but we must pass along the
			// managedObjectContext manually because sheets don't automatically inherit the environment
			AddNewShoppingItemButtonView(isAddNewItemSheetShowing: $isAddNewItemSheetShowing,
																	 managedObjectContext: managedObjectContext)
			
			// 2. now comes the sectioned list of items, by Location (or a "no items" message)
			if shoppingItems.isEmpty {
				emptyListView(listName: "Shopping")
			} else {

				HStack {
					Text("Items Listed: \(shoppingItems.count)")
						.font(.caption)
						.italic()
						.foregroundColor(.secondary)
						.padding([.leading], 20)
					Spacer()
				}
				Divider()

				List {
					ForEach(locations(for: shoppingItems)) { location in
						Section(header: MySectionHeaderView(title: location.name!)) {
							
							ForEach(self.shoppingItems.filter({ $0.location! == location })) { item in
								
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
								.listRowBackground(Color(item.backgroundColor))
								
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
				
				// clear/mark as unavailable shopping list buttons
				if !shoppingItems.isEmpty {
					Divider()
					SLCenteredButton(title: "Move All Items off-list", action: { ShoppingItem.moveAllItemsOffList() })
						.padding([.bottom], 6)

					if shoppingItems.filter({ !$0.isAvailable }).count > 0 {
						SLCenteredButton(title: "Mark All Items Available", action: { ShoppingItem.markAllItemsAvailable() })
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
		
		// first, recreate the list of items on the shopping list for this location
		// -- relies on this order being the same as the order in the ForEach above
		let itemsInThisLocation = shoppingItems.filter({ $0.location! == location })

		// you can choose what happens here according to the value of kTrailingSwipeMeansDelete
		// that is defined in Development.swift
		if kTrailingSwipeMeansDelete {
			// trigger a deletion alert/confirmation
			isDeleteItemAlertShowing = true
			itemToDelete = itemsInThisLocation[indexSet.first!]
		} else {
			// this moves the item(s) "to the other list"
			indexSet.forEach({ itemsInThisLocation[$0].onList.toggle() })
			ShoppingItem.saveChanges()
		}
	}
	
}

