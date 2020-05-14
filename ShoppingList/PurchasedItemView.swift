//
//  PurchasedItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct PurchasedItemView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	
	// fetch request to get items off-list
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == false")
	) var purchasedItems: FetchedResults<ShoppingItem>
	@State private var performJSONOutputDumpOnAppear = kPerformJSONOutputDumpOnAppear
	
	var body: some View {
		NavigationView {
			List {
				
				// add new item stays at top
				NavigationLink(destination: AddorModifyShoppingItemView(placeOnShoppingList: false)) {
					HStack {
						Spacer()
						Text("Add New Item")
							.foregroundColor(Color.blue)
						Spacer()
					}
				}
				
				Section(header: Text("Items Listed: \(purchasedItems.count)")) {
					ForEach(purchasedItems) { item in
						NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
							ShoppingItemView(item: item)
						} // end of NavigationLink
					} // end of ForEach
						.onDelete(perform: moveToShoppingList)
					
				} // end of Section
				
			}  // end of List
				.listStyle(GroupedListStyle())
				.navigationBarTitle(Text("Purchased Items"))
			
		}  // end of NavigationView
	}
	
	func moveToShoppingList(indexSet: IndexSet) {
		for index in indexSet {
			let item = purchasedItems[index]
			item.onList = true
		}
		try? managedObjectContext.save()
	}
	
	func writePurchasedListAsJSON() {
		let filepath = "/Users/keough/Desktop/purchasedItemList.json"
		if performJSONOutputDumpOnAppear {
			let jsonShoppingItems = purchasedItems.map() { ShoppingItemJSON(from: $0) }
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			do {
				let data = try encoder.encode(jsonShoppingItems)
				try data.write(to: URL(fileURLWithPath: filepath))
				print("Purchased items dumped as JSON.")
			} catch let error as NSError {
				print("Error: \(error.localizedDescription), \(error.userInfo)")
			}
			performJSONOutputDumpOnAppear = false
		}
	}
}
