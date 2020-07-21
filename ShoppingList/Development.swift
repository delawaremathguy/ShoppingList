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

// i added what i call a "Dev Tools" tab so that if you want to use this
// as a real app (device or simulator), access to all the debugging stuff that's
// I have can be "controlled," so to speak, on a separate tabview, and that tab
// view can be displayed or not by setting this global variable:

let kShowDevToolsTab = true

// this boolean control whether the Shopping List is shown as multiple Sections,
// one Section per Location, or whether it shows only a one simple list (items
// will still be listed in the same order, just not sectioned).  you can change
// this value here directly (i have multiple sections on by default).  additionally,
// if you have the Dev Tools tab showing, you can change it in real time to see
// the effect.

var kShowMultiSectionShoppingList = true

// i'm torn about this next setting.  i find it easier when i am in the store shopping to swipe
// to say "i just put that in the cart, take it off today's shopping list."  but
// SwiftUI only allows (even with WWDC2020 now in the rear view mirror) a traling
// swipe to be invoked by .onDelete(), and SwiftUI demands the label to be "Delete."
// you may want to change this behaviour.
// so i have code in the app based on the following boolean for whether a trailing
// swipe of ShoppingItems in a list means
//   (1) delete from Core Data
//   (2) remove from the current shopping list and place item into history/purchased list
// my default view of life is that a trailing swipe -- EVEN THOUGH IT SAYS DELETE -- means
// "move to the other list," so i set this boolean to false to choose option (2)
// change this flag to true if you want (1)

let kTrailingSwipeMeansDelete = false

// I used these constants and routines during development to import and
// export shoppingItems and Locations via JSON
// these are the filenames for JSON output when dumped from the simulator
// (and also the filenames in the bundle used for sample data)
let kJSONDumpDirectory = "/Users/USE_YOUR_OWN_MAC_USERNAME_HERE_HERE/Desktop/"	// dumps to the Desktop: Adjust for your Username!
let kShoppingItemsFilename = "shoppingItems.json"
let kLocationsFilename = "locations.json"

// to write stuff out -- a list of ShoppingItems and a list of Locations --
// the code is essentially the same except for the typing of the objects
// in the list.  so we use the power of generics:  we introduce
// (1) a protocol that demands that something be able to produce a simple
// Codable (struct) representation of itself -- a proxy as it were.
protocol CodableStructRepresentable {
	associatedtype DataType: Codable
	var codableProxy: DataType { get }
}

// and (2), knowing that ShoppingItem and Location are NSManagedObjects, and we
// don't want to write our own custom encoder (eventually we will), we extend each to
// be able to produce a simple, Codable struct holding only what we want to write out
// (ShoppingItemJSON and LocationJSON structs, respectively)
func writeAsJSON<T>(items: [T], to filename: String) where T: CodableStructRepresentable {
	let codableItems = items.map() { $0.codableProxy }
	let encoder = JSONEncoder()
	encoder.outputFormatting = .prettyPrinted
	var data = Data()
	do {
		data = try encoder.encode(codableItems)
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
		} catch let error as NSError {
			print("Could not write to desktop file: \(error.localizedDescription), \(error.userInfo)")
			print(String(data: data, encoding: .utf8)!)
		}
	#else
		print(String(data: data, encoding: .utf8)!)
	#endif
	
	print("List of items dumped as JSON to " + filename)
}


func populateDatabaseFromJSON() {
	// it sure is easy to do with HWS's Bundle extension (!)
	let codableLocations: [LocationCodable] = Bundle.main.decode(from: kLocationsFilename)
	Location.insertNewLocations(from: codableLocations)
	let codableShoppingItems: [ShoppingItemCodable] = Bundle.main.decode(from: kShoppingItemsFilename)
	ShoppingItem.insertNewItems(from: codableShoppingItems)
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


