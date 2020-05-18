//
//  ContentView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

struct ShoppingListTabView: View {
	// Core Data access for items on shopping list
	// @Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>

	// boolean state to control whether to show the history section
	@State private var isHistorySectionShowing: Bool = true
	@State private var performInitialDataLoad = kPerformInitialDataLoad
	
	// sections
//	@State private var sections = [[ShoppingItem]]()

	var body: some View {
		NavigationView {
			List {
				
				// add new item "button" is at top
				NavigationLink(destination: AddorModifyShoppingItemView()) {
					HStack {
						Spacer()
						Text("Add New Item")
						.foregroundColor(Color.blue)
						Spacer()
					}
				}
				
				// one main section, showing all items
				Section(header: Text("On List (\(shoppingItems.count) items)")) {
					ForEach(shoppingItems, id:\.self) { item in
						NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
							ShoppingItemView(item: item)
						}
						.listRowBackground(self.textColor(for: item))
					} // end of ForEach
						.onDelete(perform: moveToPurchased)
				
				// here's some working code for separate sections
//				ForEach(sections, id:\.self) { sectionItems in
//					Section(header: Text("Title")) {
//
//						ForEach(sectionItems, id:\.self) { item in
//							NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
//								ShoppingItemView(item: item)
//							}
//							.listRowBackground(self.textColor(for: item))
//						} // end of ForEach
//							.onDelete(perform: { offsets in
//								self.moveToPurchased2(at: offsets, in: sectionItems)
//								})
//
//					} // end of Section
//				} // end of ForEach
					

					// clear shopping list
					if !shoppingItems.isEmpty {
						HStack {
							Spacer()
							Button("Move All Items off-list") {
								self.clearShoppingList()
							}
							.foregroundColor(Color.blue)
							Spacer()
						}
					}
				} // end of Section
				
			}  // end of List
				.listStyle(GroupedListStyle())
				.navigationBarTitle(Text("Shopping List"))
				.onAppear(perform: doAppearanceCode)
			
		}  // end of NavigationView
	}
		
	func clearShoppingList() {
		for item in shoppingItems {
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}
	
//	func moveToPurchased2(at indexSet: IndexSet, in items: [ShoppingItem]) {
//		for index in indexSet {
//			let item = items[index]
//			item.onList = false
//		}
//		ShoppingItem.saveChanges()
//		//doAppearanceCode()
//	}
	
	func moveToPurchased(indexSet: IndexSet) {
		for index in indexSet {
			let item = shoppingItems[index]
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}
	
	func doAppearanceCode() {
//		print(".onAppear in ShoppingListView")
//		sections.removeAll()
//		let d = Dictionary(grouping: shoppingItems, by: { $0.visitationOrder })
//		let sortedKeys = d.keys.sorted()
//		for key in sortedKeys {
//			sections.append(d[key]!)
//		}
	}
	

			
	func textColor(for item: ShoppingItem) -> Color {
		if let location = item.location {
			return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
		}
		return Color.red
	}
}

