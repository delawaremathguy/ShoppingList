//
//  MainView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

let kUnknownLocationName = "Unknown Location"

struct MainView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	var body: some View {
		TabView {
			ShoppingListView()
				.tabItem {
					Image(systemName: "cart")
					Text("Shopping List")
			}
			
			LocationsView()
				.tabItem {
					Image(systemName: "map")
					Text("Locations")
			}
		}
		.onAppear(perform: loadInitialData)
	}
	
	func loadInitialData() {
		// must have at least one Location in the database.  if there is not one,
		// this sets up an initial database in Core Data
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		do {
			let count = try managedObjectContext.count(for: fetchRequest)
			if count > 0 {
				return
			}
		} catch {
			// nothing to do
		}
		
		// first, demand that there's a default, Unknown location
		let newLocation = Location(context: managedObjectContext)
		newLocation.id = UUID()
		newLocation.name = kUnknownLocationName
		newLocation.visitationOrder = 100
		
		// now read data from seedData.txt
		let fileName = "DataSeed.txt"
		guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
			fatalError("Failed to locate \(fileName) in app bundle.")
		}
		
		guard let data = try? Data(contentsOf: url) else {
			fatalError("Failed to load DataSeed.txt in app bundle.")
		}
		
		if let seedDataNames = String(data: data, encoding: .utf8)?.split(separator: "\n") {
			for substring in seedDataNames {
				_ = ShoppingItem.addNewItem(nameAndLocation: String(substring))
			}
		}
		
		try? managedObjectContext.save()
		
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
