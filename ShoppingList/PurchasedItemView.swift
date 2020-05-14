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
	
	var body: some View {
		NavigationView {
			List {
				
				// add new item stays at top
				NavigationLink(destination: ModifyShoppingItemView(placeOnShoppingList: false)) {
					HStack {
						Spacer()
						Text("Add New Item")
							.foregroundColor(Color.blue)
						Spacer()
					}
				}
				
				Section(header: Text("Items Listed: \(purchasedItems.count)")) {
					ForEach(purchasedItems) { item in
						NavigationLink(destination: ModifyShoppingItemView(editableItem: item)) {
							HStack {
								VStack(alignment: .leading) {
									Text(item.name!)
										.font(.headline)
									Text(item.location!.name!)
										.font(.caption)
								}
								Spacer()
								Text(String(item.quantity))
									.font(.headline)
									.foregroundColor(Color.blue)
							}
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
	
//	func textColor(for item: ShoppingItem) -> Color {
//		if let location = item.location {
//			return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
//		}
//		return Color.red
//	}
}
