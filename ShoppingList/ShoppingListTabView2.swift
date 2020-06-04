//
//  ShoppingListTabView2.swift
//  ShoppingList
//
//  Created by Jerry on 6/4/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

// THIS IS NONSENSE FOR NOW, BUT I'M CLOSE TO DOING SECTIONS IN THE SHOPPING LIST.
// PLEASE IGNORE

// defines the ViewModel for this View.  this is where we interpret how to
// use the @FetchRequest var shoppingItems to break the items into sections
// so we need a definition of what is SectionData first, which will be
// all ShoppingItems that share a common Location.

struct SectionData {
	// the items that share a common location and the location they share
	var items: [ShoppingItem]
	var location: Location
	// the title for this section = the location's title
	func title() -> String {
		return location.name!
	}
}

class ViewModel: ObservableObject {
	// all ShoppingItems on the list
	private(set) var items: [ShoppingItem]
	// ShoppingItems arranged by section
	@Published var sectionData = [SectionData]()
	
	// how we break out all the items into sections
	func rebuildSections() {
		sectionData.removeAll()
		let d = Dictionary(grouping: items, by: { $0.location })
		let sortedKeys = d.keys.sorted()
		for key in sortedKeys where d[key]!.count > 0 {
			sectionData.append(SectionData(items: d[key]!))
		}
	}
	
	init(shoppingItems: [ShoppingItem]) {
		self.shoppingItems = shoppingItems
		rebuildSections()
	}
	
	func addNewItem(counter: Int) {
		items.append(Item(counter: counter))
	}
	
	func removeItem(item: Item) {
		if let index = items.firstIndex(where: { $0.id == item.id }) {
			self.items.remove(at: index)
		}
	}
}


struct ShoppingListTabView2: View {
	// Core Data access for items on shopping list
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>
	
	@ObservedObject private var viewModel = ViewModel()
	
	var body: some View {
		VStack {
			
			// add new item "button" is at top
			NavigationLink(destination: AddorModifyShoppingItemView(addItemToShoppingList: true)) {
				Text("Add New Item")
					.foregroundColor(Color.blue)
					.padding(10)
			}
			
			List {
				ForEach(sections, id:\.self) { sectionItems in
					Section(header: self.sectionTitle(for: sectionItems)) {
						ForEach(sectionItems, id:\.self) { item in
							NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
								ShoppingItemView(item: item)
							}
							.listRowBackground(self.textColor(for: item))
						} // end of ForEach
							.onDelete(perform: { offsets in
								self.moveToPurchased2(at: offsets, in: sectionItems)
							})
						
					} // end of Section
				} // end of ForEach
					
				
				// clear shopping list button (yes, it's the last thing in the list
				// but i don't want it at the bottom, in case you accidentally hit
				// it while moving to the purchased item list
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
	} // end of VStack

	
	func sectionTitle(for items: [ShoppingItem]) -> Text {
		if let firstItem = items.first {
			return Text(firstItem.location!.name!)
		}
		return Text("Title")
	}
	
	func clearShoppingList() {
		for item in shoppingItems {
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}
	
	func moveToPurchased2(at indexSet: IndexSet, in items: [ShoppingItem]) {
		for index in indexSet {
			let item = items[index]
			item.onList = false
		}
		ShoppingItem.saveChanges()
		//		buildSections()
	}
	
	func moveToPurchased(indexSet: IndexSet) {
		for index in indexSet {
			let item = shoppingItems[index]
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}
	
	func textColor(for item: ShoppingItem) -> Color {
		if let location = item.location {
			return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
		}
		return Color.red
	}
}

