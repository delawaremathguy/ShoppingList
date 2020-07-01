//
//  ContentView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

// This is a straightforward list display of items on the shopping list.
// a simple @FetchRequest gets these items, arranged by their location's
// visitation order, a copy of which is kept in the shopping item itself.
// why is this kept here, as duplicate information?  if you change a Location's
// visitation order, copying that to the items in the location makes sure that
// this sees the changes.

// be sure to see comments over in ShoppingListTabView2, since that's where i
// spend more of my time tweaking the shopping list code and i may not always
// keep these two views in synch

struct ShoppingListTabView1: View {
	// Core Data access for the context and the items on shopping list
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>
	
	@State private var isAddNewItemSheetShowing = false
	@State private var itemToDelete: ShoppingItem?
	@State private var isDeleteItemAlertShowing = false
	
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

			if shoppingItems.isEmpty {
				Spacer()
				Text("There are currently no items")
				Text("on your Shopping List.")
				Spacer()
				
			} else {
				
				List {
					// one main section, showing all items
					Section(header: MySectionHeaderView(title: "Items Listed: \(shoppingItems.count)")) {
						ForEach(shoppingItems) { item in
							NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
								ShoppingItemRowView(itemData: ShoppingItemRowData(item: item))
									.contextMenu {
										
										Button(action: {
											item.moveToPuchased(saveChanges: true)
										}) {
											Text("Mark Purchased")
											Image(systemName: "purchased")
										}
										
										Button(action: { item.mark(available: !item.isAvailable, saveChanges: true) }) {
											Text(item.isAvailable ? "Mark as Unavailable" : "Mark as Available")
											Image(systemName: item.isAvailable ? "pencil.slash" : "pencil")
										}
										
										if !kTrailingSwipeMeansDelete {
											Button(action: {
												self.itemToDelete = item
												self.isDeleteItemAlertShowing = true
											}) {
												Text("Delete This Item")
												Image(systemName: "minus.circle")
											}
										}
								} // end of contextMenu
							}
							.listRowBackground(self.backgroundColor(for: item))
						} // end of ForEach
							.onDelete(perform: handleOnDeleteModifier)
							.alert(isPresented: $isDeleteItemAlertShowing) {
								Alert(title: Text("Delete \'\(itemToDelete!.name!)\'?"),
											message: Text("Are you sure you want to delete this item?"),
											primaryButton: .cancel(Text("No")),
											secondaryButton: .destructive(Text("Yes")) {
												ShoppingItem.delete(item: self.itemToDelete!, saveChanges: true)
									})
						}

					} // end of Section
				}  // end of List
					.listStyle(GroupedListStyle())
				
				// clear/ mark as unavailable shopping list buttons
				if !shoppingItems.isEmpty {
					Divider()
					SLCenteredButton(title: "Move All Items off-list", action: { ShoppingItem.moveAllItemsOffList() })
						.padding([.bottom], 6)
					
					if shoppingItems.compactMap({ !$0.isAvailable ? "Unavailable" : nil }).count > 0 {
						SLCenteredButton(title: "Mark All Items Available", action: self.markAllAvailable )
							.padding([.bottom], 6)
						
					}
				}

			} // end of else
			
		} // end of VStack
	}
	
	func markAllAvailable() {
		shoppingItems.forEach({ $0.mark(available: true )})
		ShoppingItem.saveChanges()
	}

	
	func handleOnDeleteModifier(indexSet: IndexSet) {
		// you can choose what happens here according to the value of kTrailingSwipeMeansDelete
		// that is defined in Development.swift
		if kTrailingSwipeMeansDelete {
			// trigger a deletion alert/confirmation
			isDeleteItemAlertShowing = true
			itemToDelete = shoppingItems[indexSet.first!]
		} else {
			// this moves the item(s) "to the other list"
			for index in indexSet {
				let item = shoppingItems[index]
				item.moveToPuchased()
			}
			ShoppingItem.saveChanges()
		}
	}
		
	func backgroundColor(for item: ShoppingItem) -> Color {
		return Color(item.backgroundColor)
	}
}

