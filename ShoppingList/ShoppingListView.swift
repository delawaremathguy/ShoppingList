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
	@State private var loadedDataWasOutput = true // change to false to regenerate or reload shopping list dump
	@State private var initialLoadDataCallWasMade = false
	// fetch requests to get both the items on the list, and those off the list
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>

	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == false")
	) var historyItems: FetchedResults<ShoppingItem>

	var body: some View {
		NavigationView {
			List {
				
				// add new item stays at top
				NavigationLink(destination: AddShoppingItemView()) {
					HStack {
						Spacer()
						Text("Add New Item")
						.foregroundColor(Color.blue)
						Spacer()
					}
				}
				
				Section(header: Text("On List (\(shoppingItems.count) items)")) {
					ForEach(shoppingItems, id:\.self) { item in
						NavigationLink(destination: ModifyShoppingItemView(editableItem: item)) {
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
					

					// clear shopping list
					HStack {
						Spacer()
						Button("Move All Items off-list") {
							self.clearShoppingList()
						}
						.foregroundColor(Color.blue)
						Spacer()
					}

					// hide/show History section
					HStack {
						Spacer()
						Button(isHistorySectionShowing ? "Hide History Section" : "Show History Section") {
							self.isHistorySectionShowing.toggle()
						}
						.foregroundColor(Color.blue)
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
				.listStyle(PlainListStyle())
				.navigationBarTitle(Text("Shopping List"))
				.onAppear(perform: loadInitialData)
			
			
			
		}  // end of NavigationView
	}
		
	func clearShoppingList() {
		for item in shoppingItems {
			item.onList = false
		}
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
		
		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
		do {
			let count = try managedObjectContext.count(for: fetchRequest)
			print("Number of ShoppingItems in database is \(count)")
		}
		catch let error as NSError {
			fatalError("Error couting items: \(error.localizedDescription), \(error.userInfo)")
		}

	}
	
	func loadInitialData() {
		
		if !initialLoadDataCallWasMade {
			// must have at least one Location in the database -- the Unknown Location.  if there is not one,
			// then this sets up an initial database in Core Data
			if Location.unknownLocation() == nil {
				populateDatabaseFromJSON()
			}
			initialLoadDataCallWasMade = true
			writeShoppingListAsJSON()
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
			print("Error inserting locations: \(error.localizedDescription), \(error.userInfo)")
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
			print("Error reading in locations: \(error.localizedDescription), \(error.userInfo)")
		}
		
		try! managedObjectContext.save()
				
	}

	func writeShoppingListAsJSON() {
		let filepath = "/Users/keough/Desktop/shoppingList.json"
		if !loadedDataWasOutput {
			let jsonShoppingItems1 = shoppingItems.map() { ShoppingItemJSON(from: $0) }
			let jsonShoppingItems2 = historyItems.map() { ShoppingItemJSON(from: $0) }
			let jsonShoppingItems = jsonShoppingItems1 + jsonShoppingItems2
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			do {
				let data = try encoder.encode(jsonShoppingItems)
				try data.write(to: URL(fileURLWithPath: filepath))
			} catch let error as NSError {
				print("Error: \(error.localizedDescription), \(error.userInfo)")
			}
			loadedDataWasOutput = true
		}
	}
			
	func textColor(for item: ShoppingItem) -> Color {
		if let location = item.location {
			if location.name! == kUnknownLocationName {
				return Color.init(.sRGB, red: 0.9, green: 0.9, blue: 0.9, opacity: 0.5)
			}
			return Color.clear
		}
		return Color.red
	}
}

