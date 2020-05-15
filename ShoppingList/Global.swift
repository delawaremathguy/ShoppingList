//
//  Global.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// Use these constants and routines to assist is importing and
// exporting shoppingItems and Locations

// usually, these will both be false for established database
// make the first one true to dump an existing database
// make the second one true to load a new database from the main bundle
// doesn't make sense that both would be true
let kPerformJSONOutputDumpOnAppear = false // change to true to dump JSON files in MainView.onAppear()
let kPerformInitialDataLoad = false // change to true to force initial data loading in MainView.onAppear()

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
	
	let jsonLocations: [LocationJSON] = Bundle.main.decode(from: kLocationsFilename)
	Location.insertNewLocations(from: jsonLocations)
	
	let jsonShoppingItems: [ShoppingItemJSON] = Bundle.main.decode(from: kShoppingItemsFilename)
	ShoppingItem.insertNewItems(from: jsonShoppingItems)
	
	ShoppingItem.saveChanges()
	
//	// read locations first, and create dictionary to keep track of them
//	guard let url1 = Bundle.main.url(forResource: kLocationsFilename, withExtension: nil) else {
//		fatalError("Failed to locate " + kLocationsFilename + " in app bundle.")
//	}
//	guard let data1 = try? Data(contentsOf: url1) else {
//		fatalError("Failed to load " + kLocationsFilename + " from app bundle.")
//	}
//
//	let decoder = JSONDecoder()
//
//	// insert all new locations
//	do {
//		let jsonLocations = try decoder.decode([LocationJSON].self, from: data1)
//		Location.insertNewLocations(from: jsonLocations)
//	} catch let error as NSError {
//		fatalError("Error inserting locations: \(error.localizedDescription), \(error.userInfo)")
//	}
//
//	// read locations first, and create dictionary to keep track of them
//	guard let url2 = Bundle.main.url(forResource: kShoppingItemsFilename, withExtension: nil) else {
//		fatalError("Failed to locate " + kShoppingItemsFilename + " in app bundle.")
//	}
//	guard let data2 = try? Data(contentsOf: url2) else {
//		fatalError("Failed to load " + kShoppingItemsFilename + " from app bundle.")
//	}
//
//	// insert all shoppingItems
//	do {
//		let jsonShoppingItems = try decoder.decode([ShoppingItemJSON].self, from: data2)
//		ShoppingItem.insertNewItems(from: jsonShoppingItems) // , using: locationDictionary)
//	} catch let error as NSError {
//		fatalError("Error reading in locations: \(error.localizedDescription), \(error.userInfo)")
//	}
//
//	ShoppingItem.saveChanges()
	
}


