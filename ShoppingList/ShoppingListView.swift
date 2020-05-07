//
//  ContentView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

struct ShoppingListView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	
	// the list of shoppingItems is loaded in .onAppear so we can control
	// when it gets loaded and then own it ourself
	@State private var isHistorySectionShowing: Bool = true
	
//	@State private var shoppingItems = [ShoppingItem]()

	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.location?.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>

	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == false")
	) var historyItems: FetchedResults<ShoppingItem>

	@State private var showingAddScreen: Bool = false
	
	var body: some View {
		NavigationView {
			List {
				
				Section(header: Text("On List (\(shoppingItems.count) items)")) {
					ForEach(shoppingItems) { item in
						NavigationLink(destination: ModifyShoppingItemView(editableItem: item)) { // }, shoppingItems: self.$shoppingItems)) {
							HStack {
								VStack(alignment: .leading) {
									Text(item.name!)
										.font(.headline)
//										.foregroundColor(self.textColor(for: item))
									Text(item.location!.name!)
										.font(.caption)
								}
								Spacer()
								Text(String(item.quantity))
									.font(.headline)
									.foregroundColor(Color.blue)
							}
							
						}
						.listRowBackground(self.textColor(for: item))
					}
//					.onMove(perform: moveItems)
					.onDelete(perform: moveToHistory)
					
					// add new item
					NavigationLink(destination: AddShoppingItemView()) {
						HStack {
							Spacer()
							Text("Add New Item")
								.foregroundColor(Color.blue)
							Spacer()
						}
					}

					// hide/show History section
					HStack {
						Spacer()
						Button(isHistorySectionShowing ? "Hide History Section" : "Show History Section") {
							self.isHistorySectionShowing.toggle()
						}
						Spacer()
					}
				} // end of Section
				
				
				if isHistorySectionShowing {
					Section(header: Text("History (\(historyItems.count) items)")) {
						ForEach(historyItems) { item in
							Text(item.name!) // (item as! ShoppingItem).name!)
						}
						.onDelete(perform: moveToShoppingList)
						
					}
				}
				
			}  // end of List
				.listStyle(GroupedListStyle())
				.navigationBarTitle(Text("Shopping List"))
				.onAppear(perform: loadData)
			
		}  // end of NavigationView
	}
		
	func moveToShoppingList(indexSet: IndexSet) {
		for index in indexSet {
			let item = historyItems[index]
			item.onList = true
		}
		// saveItemOrder()
		try? managedObjectContext.save()
	}

	func moveToHistory( indexSet: IndexSet) {
		for index in indexSet.reversed() {
			let item = shoppingItems[index]
			item.onList = false
		}
		try? managedObjectContext.save()
	}
	
	func loadData() {
		print("Shopping List appeared.")
//		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
//		fetchRequest.sortDescriptors = [
//										NSSortDescriptor(keyPath: \ShoppingItem.location?.visitationOrder, ascending: true),
//										NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)]
//		fetchRequest.predicate = NSPredicate(format: "onList == true")
//		do {
//			let itemList = try managedObjectContext.fetch(fetchRequest)
//			shoppingItems = itemList
//		} catch let error as NSError {
//			NSLog("Unresolved error fetching shopping list: \(error), \(error.userInfo)")
//			shoppingItems.removeAll()
//		}

		
//		for item in shoppingItems {
//			print("\(item.name!):\(item.location!.name!):\(item.location!.visitationOrder)")
//		}
	}
			
	func textColor(for item: ShoppingItem) -> Color {
		if let location = item.location {
			if location.name! == kUnknownLocationName {
				return Color.gray
			}
			return Color.green
		}
		return Color.red
	}
}

