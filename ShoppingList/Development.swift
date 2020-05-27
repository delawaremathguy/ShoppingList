//
//  Development.swift
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
// -- make the first one true to dump an existing database
// -- make the second one true to load a new database from the main bundle
//
// (it doesn't make much sense that both would be true)
// in the case of the simulator, data goes to a file on the Desktop
// in the case of a device, it gets printed to the console
let kPerformJSONOutputDumpOnAppear = false // true = dump JSON output in MainView.onAppear()
let kPerformInitialDataLoad = false // true = force initial data loading in MainView.onAppear()

// use these filenames for debug output and initial load from bundle
let kShoppingItemsFilename = "shoppingItems.json"
let kLocationsFilename = "locations.json"

// to write stuff out -- a list of ShoppingItems and a list of Locations,
// the code is essentially the same except for the typing of the objects
// in the list.  so we use the power of generics:  we introduce
// (1) a protocol that demands that something be able to produce a simple
// Codable (struct) representation of itself -- a proxy as it were.
protocol JSONRepresentable {
	associatedtype DataType: Codable
	var jsonProxy: DataType { get }
}

// and (2), knowing that ShoppingItem and Location are NSManagedObjects, we
// don't want to write our own encoder, and we
// only want to write out a few fields of data, we extend each to be able to
// produce a simple, Codable struct holding only what we want to write out
// (ShoppingItemJSON and LocationJSON structs, repsectively)
func writeAsJSON<T>(items: [T], to filename: String) where T: JSONRepresentable {
	let jsonizedItems = items.map() { $0.jsonProxy }
	let encoder = JSONEncoder()
	encoder.outputFormatting = .prettyPrinted
	do {
		let data = try encoder.encode(jsonizedItems)
		#if targetEnvironment(simulator)
			let filepath = "/Users/keough/Desktop/" + filename
			try data.write(to: URL(fileURLWithPath: filepath))
		#else
			print(String(data: data, encoding: .utf8)!)
		#endif
		print("List of items dumped as JSON to " + filename)
	} catch let error as NSError {
		print("Error with \(filename): \(error.localizedDescription), \(error.userInfo)")
	}
}


func populateDatabaseFromJSON() {
	// it sure is easy to do with HSW's Bundle extension (!)
	let jsonLocations: [LocationJSON] = Bundle.main.decode(from: kLocationsFilename)
	Location.insertNewLocations(from: jsonLocations)
	let jsonShoppingItems: [ShoppingItemJSON] = Bundle.main.decode(from: kShoppingItemsFilename)
	ShoppingItem.insertNewItems(from: jsonShoppingItems)
	ShoppingItem.saveChanges()
}

// this is a way to find out where the CoreData database lives,
// primarily for use in the simulator
//func printCoreDataDBPath() {
//	let path = FileManager
//		.default
//		.urls(for: .applicationSupportDirectory, in: .userDomainMask)
//		.last?
//		.absoluteString
//		.replacingOccurrences(of: "file://", with: "")
//		.removingPercentEncoding
//
//	print("Core Data DB Path :: \(path ?? "Not found")")
//}

//import SwiftUI
//struct MyListStyle: ListStyle {
//	static func _makeView<SelectionValue>(value: _GraphValue<_ListValue<MyListStyle, SelectionValue>>, inputs: _ViewInputs) -> _ViewOutputs where SelectionValue : Hashable {
//		<#code#>
//	}
//
//	static func _makeViewList<SelectionValue>(value: _GraphValue<_ListValue<MyListStyle, SelectionValue>>, inputs: _ViewListInputs) -> _ViewListOutputs where SelectionValue : Hashable {
//		<#code#>
//	}
//
//
//}
