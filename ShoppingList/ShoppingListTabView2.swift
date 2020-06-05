//
//  ShoppingListTabView2.swift
//  ShoppingList
//
//  Created by Jerry on 6/4/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData
import UIKit

// THIS IS NONSENSE FOR NOW, BUT I'M CLOSE TO DOING SECTIONS IN THE SHOPPING LIST.
// PLEASE IGNORE

// defines the ViewModel for this View.  this is where we interpret how to
// use the @FetchRequest var shoppingItems to break the items into sections
// so we need a definition of what is SectionData first, which will be
// all ShoppingItems that share a common Location.

class LocationGroupedItems: Identifiable {
	
	var id = UUID()
	// the items that share a common location and the location they share
	var items = [ShoppingItem]()
	private(set) var location: Location
	// the title for this section = the location's title
	func title() -> String {
		return location.name!
	}
	
	init(items: [ShoppingItem], location: Location) {
		self.items = items
		self.location = location
	}
}

class ShoppingList: ObservableObject {
	@Published var items: [ShoppingItem]
	
	init() {
		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
		fetchRequest.sortDescriptors = [
			NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
			NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)]
		fetchRequest.predicate = NSPredicate(format: "onList == true")
		do {
			let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
			items = try context.fetch(fetchRequest)
		} catch let error as NSError {
			print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
			items = []
		}
	}
	
}

struct ShoppingListTabView2: View {
	// Core Data access for items on shopping list
	// and for Locations where associated items have at least one
	// item on the shopping list
//	@FetchRequest(entity: ShoppingItem.entity(),
//								sortDescriptors: [
//									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
//									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
//								predicate: NSPredicate(format: "onList == true")
//	) var shoppingItems: FetchedResults<ShoppingItem>
		
	@ObservedObject var shoppingList = ShoppingList()
	@State private var itemGroups = [LocationGroupedItems]()
	
	var body: some View {
		VStack {
			
			// add new item "button" is at top
			NavigationLink(destination: AddorModifyShoppingItemView(addItemToShoppingList: true)) {
				Text("Add New Item")
					.foregroundColor(Color.blue)
					.padding(10)
			}
			
			// now comes the sectioned list of items, by Location
			List {
				ForEach(itemGroups) { itemGroup in
					Section(header: Text(itemGroup.title())) {
						ForEach(itemGroup.items) { item in
							NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
								ShoppingItemRowView(item: item)
							}
							.listRowBackground(self.textColor(for: item))
						} // end of ForEach
							.onDelete(perform: { offsets in
								self.moveToPurchased(at: offsets, in: itemGroup)
							})
						
					} // end of Section
				} // end of ForEach
				
				
				// clear shopping list button (yes, it's the last thing in the list
				// but i don't want it at the bottom, in case you accidentally hit
				// it while moving to the purchased item list
				if !shoppingList.items.isEmpty {
					HStack {
						Spacer()
						Button("Move All Items off-list") {
							self.clearShoppingList()
						}
						.foregroundColor(Color.blue)
						Spacer()
					}
				}
				
			}  // end of List
				.listStyle(GroupedListStyle())
			
		} // end of VStack
			.onAppear(perform: rebuildSections)
	} // end of body: some View
	
	func rebuildSections() {
		itemGroups.removeAll()
		let d = Dictionary(grouping: shoppingList.items, by: { $0.location })
		let sortedKeys = d.keys.sorted(by: {$0!.visitationOrder < $1!.visitationOrder })
		for location in sortedKeys where d[location]!.count > 0 {
			itemGroups.append(LocationGroupedItems(items: d[location]!, location: location!))
		}
	}

	func moveToPurchased(at indexSet: IndexSet, in itemGroup: LocationGroupedItems) {
		for index in indexSet.reversed() {
			let item = itemGroup.items[index]
			item.onList = false
		}
		ShoppingItem.saveChanges()
		rebuildSections()
	}

	func clearShoppingList() {
		for item in shoppingList.items {
			item.onList = false
		}
		ShoppingItem.saveChanges()
		rebuildSections()
	}

	func textColor(for item: ShoppingItem) -> Color {
		if let location = item.location {
			return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
		}
		return Color.red
	}
}

//struct sectionView: View {
//	@ObservedObject var sectionData: SectionData
//	@ObservedObject var viewModel: ViewModel
//	
//	var body: some View {
//		Section(header: Text(sectionData.title())) {
//			ForEach(sectionData.items, id:\.self) { item in
//				NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item).environmentObject(self.viewModel)) {
//					ShoppingItemRowView(item: item)
//				}
//				.listRowBackground(self.textColor(for: item))
//			} // end of ForEach
//				.onDelete(perform: { offsets in
//					self.viewModel.moveToPurchased(at: offsets, in: sectionData)
//				})
//			
//		} // end of Section
//
//	}
//}
