//
//  Global.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// Use these constants and routines during development to import and
// export shoppingItems and Locations via JSON
//
// usually, these will both be false for established database.  change only for debugging
//
// -- make the second one true to load a new database from the main bundle
// -- make the first one true to dump an existing database
//
// (it doesn't make much sense that both would be true)
let kPerformJSONOutputDumpOnAppear = false // true = dump JSON files in MainView.onAppear()
let kPerformInitialDataLoad = false // true = force initial data loading in MainView.onAppear()

// use these filenames for debug output and initial load from bundle
let kShoppingItemsFilename = "shoppingItems.json"
let kLocationsFilename = "locations.json"

func writeAsJSON(items: [ShoppingItem]) {
	let jsonShoppingItems = items.map() { ShoppingItemJSON(from: $0) }
	let encoder = JSONEncoder()
	encoder.outputFormatting = .prettyPrinted
	do {
		let data = try encoder.encode(jsonShoppingItems)
		#if targetEnvironment(simulator)
		let filepath = "/Users/keough/Desktop/" + kShoppingItemsFilename
		try data.write(to: URL(fileURLWithPath: filepath))
		#else
		print(String(data: data, encoding: .utf8)!)
		#endif
		print("ShoppingItems dumped as JSON.")
	} catch let error as NSError {
		print("Error: \(error.localizedDescription), \(error.userInfo)")
	}
}

func writeAsJSON(items: [Location]) {
	let jsonLocationList = items.map() { LocationJSON(from: $0) }
	let encoder = JSONEncoder()
	encoder.outputFormatting = .prettyPrinted
	do {
		let data = try encoder.encode(jsonLocationList)
		#if targetEnvironment(simulator)
		let filepath = "/Users/keough/Desktop/" + kLocationsFilename
		try data.write(to: URL(fileURLWithPath: filepath))
		#else
		print(String(data: data, encoding: .utf8)!)
		#endif
		print("Locations dumped as JSON.")
	} catch let error as NSError {
		print("Error: \(error.localizedDescription), \(error.userInfo)")
	}
}

func populateDatabaseFromJSON() {
	// easy to do with HSW's Bundle extension (!)
	let jsonLocations: [LocationJSON] = Bundle.main.decode(from: kLocationsFilename)
	Location.insertNewLocations(from: jsonLocations)
	
	let jsonShoppingItems: [ShoppingItemJSON] = Bundle.main.decode(from: kShoppingItemsFilename)
	ShoppingItem.insertNewItems(from: jsonShoppingItems)
	
	ShoppingItem.saveChanges()
}


