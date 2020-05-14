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
	
	// boolean state to control whether to show the history section
	@State private var isHistorySectionShowing: Bool = true
	@State private var performJSONOutputDumpOnAppear = kPerformJSONOutputDumpOnAppear 
	@State private var performInitialDataLoad = kPerformInitialDataLoad
	// fetch requests to get both the items on the list, and those off the list
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>

//	@FetchRequest(entity: ShoppingItem.entity(),
//								sortDescriptors: [
//									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
//								predicate: NSPredicate(format: "onList == false")
//	) var historyItems: FetchedResults<ShoppingItem>

	var body: some View {
		NavigationView {
			List {
				
				// add new item stays at top
				NavigationLink(destination: AddorModifyShoppingItemView()) {
					HStack {
						Spacer()
						Text("Add New Item")
						.foregroundColor(Color.blue)
						Spacer()
					}
				}
				
				Section(header: Text("On List (\(shoppingItems.count) items)")) {
					ForEach(shoppingItems, id:\.self) { item in
						NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
							ShoppingItemView(item: item)
						}
						.listRowBackground(self.textColor(for: item))
					} // end of ForEach
//					.onMove(perform: moveItems)
						.onDelete(perform: moveToHistory)
					

					// clear shopping list
					HStack {
						Spacer()
						Button("Move All Items off-list") {
							self.clearShoppingList()
						}
						.foregroundColor(Color.blue)
						Spacer()
					}
				} // end of Section
				
			}  // end of List
				.listStyle(PlainListStyle())
				.navigationBarTitle(Text("Shopping List"))
				.onAppear(perform: loadData)
			
			
			
		}  // end of NavigationView
	}
		
	func clearShoppingList() {
		for item in shoppingItems {
			item.onList = false
		}
	}
	
	func moveToHistory(indexSet: IndexSet) {
		for index in indexSet.reversed() {
			let item = shoppingItems[index]
			item.onList = false
		}
		try? managedObjectContext.save()
	}
	
	func loadData() {
		//print(".onAppear in ShoppingListView")
		if performInitialDataLoad {
			if Location.entityCount() == 0 {
				populateDatabaseFromJSON()
			}
			performInitialDataLoad = false
		}
		if performJSONOutputDumpOnAppear {
			writeShoppingListAsJSON()
			performJSONOutputDumpOnAppear = false
		}
	}
	
	func populateDatabaseFromJSON() {
		// read locations first, and create dictionary to keep track of them
		guard let url1 = Bundle.main.url(forResource: "locations.json", withExtension: nil) else {
			fatalError("Failed to locate locations.json in app bundle.")
		}
		guard let data1 = try? Data(contentsOf: url1) else {
			fatalError("Failed to load locations.json from app bundle.")
		}
		
		let decoder = JSONDecoder()
		
		// insert all new locations
		do {
			let jsonLocations = try decoder.decode([LocationJSON].self, from: data1)
			Location.insertNewLocations(from: jsonLocations)
		} catch let error as NSError {
			fatalError("Error inserting locations: \(error.localizedDescription), \(error.userInfo)")
		}
		
		// read locations first, and create dictionary to keep track of them
		guard let url2 = Bundle.main.url(forResource: "shoppingList.json", withExtension: nil) else {
			fatalError("Failed to locate shoppingItems.json in app bundle.")
		}
		guard let data2 = try? Data(contentsOf: url2) else {
			fatalError("Failed to load shoppingList.json from app bundle.")
		}

		// insert all shoppingItems
		do {
			let jsonShoppingItems = try decoder.decode([ShoppingItemJSON].self, from: data2)
			ShoppingItem.insertNewItems(from: jsonShoppingItems) // , using: locationDictionary)
		} catch let error as NSError {
			fatalError("Error reading in locations: \(error.localizedDescription), \(error.userInfo)")
		}
		
		try! managedObjectContext.save()
				
	}

	func writeShoppingListAsJSON() {
		let filepath = "/Users/keough/Desktop/shoppingList.json"
		let jsonShoppingItems = shoppingItems.map() { ShoppingItemJSON(from: $0) }
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		do {
			let data = try encoder.encode(jsonShoppingItems)
			try data.write(to: URL(fileURLWithPath: filepath))
			print("ShoppingItems dumped as JSON.")
		} catch let error as NSError {
			print("Error: \(error.localizedDescription), \(error.userInfo)")
		}
	}

			
	func textColor(for item: ShoppingItem) -> Color {
		if let location = item.location {
			return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
		}
		return Color.red
	}
}

