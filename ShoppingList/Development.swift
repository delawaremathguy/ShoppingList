//
//  Development.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// i added what i call a "Demo Tools" tab so that if you want to use this
// as a real app (device or simulator), access to all the debugging stuff that's
// I have can be "controlled," so to speak, on a separate tabview, and that tab
// view can be displayed or not by setting this global variable:

let kShowDevToolsTab = true

// I used these constants and routines during development to import and
// export shoppingItems and Locations via JSON
// these are the filenames for JSON output when dumped from the simulator
// (and also the filenames in the bundle used for sample data)
let kJSONDumpDirectory = "/Users/YOUR_OWN_USERNAME_HERE/Desktop/"	// dumps to the Desktop: USE YOUR OWN MAC USERNAME HERE
let kShoppingItemsFilename = "shoppingItems.json"
let kLocationsFilename = "locations.json"

// to write stuff out -- a list of ShoppingItems and a list of Locations --
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
// only want to write out a few fields of data, so we extend each to be able to
// produce a simple, Codable struct holding only what we want to write out
// (ShoppingItemJSON and LocationJSON structs, respectively)
func writeAsJSON<T>(items: [T], to filename: String) where T: JSONRepresentable {
	let jsonizedItems = items.map() { $0.jsonProxy }
	let encoder = JSONEncoder()
	encoder.outputFormatting = .prettyPrinted
	var data = Data()
	do {
		data = try encoder.encode(jsonizedItems)
	} catch let error as NSError {
		print("Error converting items to JSON: \(error.localizedDescription), \(error.userInfo)")
		return
	}
	
	// if in simulator, dump to files somewhere on your Mac (check definition above)
	// and otherwise if on device (or if file dump doesn't work) print to console.
	#if targetEnvironment(simulator)
		let filepath = kJSONDumpDirectory + filename
		do {
			try data.write(to: URL(fileURLWithPath: filepath))
		} catch {
			print(String(data: data, encoding: .utf8)!)
		}
	#else
		print(String(data: data, encoding: .utf8)!)
	#endif
	
	print("List of items dumped as JSON to " + filename)
}


func populateDatabaseFromJSON() {
	// it sure is easy to do with HWS's Bundle extension (!)
	let jsonLocations: [LocationJSON] = Bundle.main.decode(from: kLocationsFilename)
	Location.insertNewLocations(from: jsonLocations)
	let jsonShoppingItems: [ShoppingItemJSON] = Bundle.main.decode(from: kShoppingItemsFilename)
	ShoppingItem.insertNewItems(from: jsonShoppingItems)
	ShoppingItem.saveChanges()
}

func deleteAllData() {
	let items1 = ShoppingItem.allShoppingItems()
	for item in items1 {
		ShoppingItem.delete(item: item)
	}
	
	let items2 = Location.allUserLocations()
	for item in items2 {
		Location.delete(location: item)
	}
	
	Location.saveChanges()
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

// the stuff below is needed to implement my own ListStyle, e.g., so
// section headers in a grouped style are better controlled.  i just don't know
// yet how to do this ... waiting on some SwiftUI documentation (!)

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
