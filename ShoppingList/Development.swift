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
// as a real app (device or simulator), access to all the debugging stuff that
// i have can be "controlled," so to speak, on a separate tabview; and that tab
// view can be displayed or not by setting this global variable:

let kShowDevToolsTab = true

// this boolean control whether the Shopping List is iniitally shown as multiple Sections,
// one Section per Location, or whether it shows only a simple list (items
// will still be listed in the same order, just not sectioned).  you can change
// this value here directly (i now have single section on by default).  the eager
// developer might want to put this value in UserDefaults ...

var gShowMultiSectionShoppingList = false

// i'm torn about this next setting.  i find it easier when i am in the store shopping to swipe
// to say "i just put that in the cart, take it off today's shopping list."  but
// SwiftUI only allows (even with WWDC2020 now in the rear view mirror) a traling
// swipe to be invoked by .onDelete(), and SwiftUI demands the label to be "Delete."
// you may want to change this behaviour.
// so i have code in the app based on the following boolean for whether a trailing
// swipe of ShoppingItems in a list means
//   (1) delete from Core Data
//   (2) remove from the current shopping list and place item into history/purchased list
//
// my default view of life is that a trailing swipe -- EVEN THOUGH IT SAYS DELETE -- means
// "move to the other list," so i set this boolean to false to choose option (2)
// change this flag to true if you want (1)

let kTrailingSwipeMeansDelete = false

// i used these constants and routines during development to import and
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
// be able to produce a simple, Codable struct proxy holding only what we want to write out
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
	
	// if in simulator, dump to files somewhere on your Mac (check definition in Development.swift)
	// and otherwise if on device (or if file dump path doesn't work) print to console.
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
	insertNewLocations(from: codableLocations)
	let codableShoppingItems: [ShoppingItemCodable] = Bundle.main.decode(from: kShoppingItemsFilename)
	insertNewShoppingItems(from: codableShoppingItems)
	ShoppingItem.saveChanges()
}

func insertNewShoppingItems(from codableShoppingItems: [ShoppingItemCodable]) {
	
	// get all Locations that are not the unknown location
	// group by name for lookup below when adding an item to a location
	let locations = Location.allLocations(userLocationsOnly: true)
	let name2Location = Dictionary(grouping: locations, by: { $0.name! })
	
	for codableShoppingItem in codableShoppingItems {
		let newItem = ShoppingItem.addNewItem() // new UUID is created here
		newItem.name = codableShoppingItem.name
		newItem.quantity = codableShoppingItem.quantity
		newItem.onList = codableShoppingItem.onList
		newItem.isAvailable = codableShoppingItem.isAvailable
		
		// look up matching location by name
		// anything that doesn't match goes to the unknown location.
		if let location = name2Location[codableShoppingItem.locationName]?.first {
			newItem.location = location
		} else {
			newItem.location = Location.unknownLocation()!
		}
		
		NotificationCenter.default.post(name: .shoppingItemAdded, object: newItem, userInfo: nil)
		NotificationCenter.default.post(name: .locationEdited, object: newItem.location!, userInfo: nil)
	}
}

// used to insert data from JSON files in the app bundle
func insertNewLocations(from codableLocations: [LocationCodable]) {
	for codableLocation in codableLocations {
		let newLocation = Location.addNewLocation() // new UUID created here
		newLocation.name = codableLocation.name
		newLocation.visitationOrder = codableLocation.visitationOrder
		newLocation.red = codableLocation.red
		newLocation.green = codableLocation.green
		newLocation.blue = codableLocation.blue
		newLocation.opacity = codableLocation.opacity
		NotificationCenter.default.post(name: .locationAdded, object: newLocation)
	}
}

// useful only as an introductory tool.  if you want to try out the app, you can
// insert s full, working database of ShoppingItems and Locations; play with it;
// then delete everything and start over.
func deleteAllData() {
	let shoppingItems = ShoppingItem.allShoppingItems()
	for item in shoppingItems {
		ShoppingItem.delete(item: item)
	}
	
	let locations = Location.allLocations(userLocationsOnly: true)
	for location in locations {
		Location.delete(location: location)
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

// MARK: - USeful Extensions to make CodableStructRepresentable work

extension Location: CodableStructRepresentable {
	var codableProxy: some Encodable & Decodable {
		return LocationCodable(from: self)
	}
}

extension ShoppingItem: CodableStructRepresentable {
	var codableProxy: some Encodable & Decodable {
		return ShoppingItemCodable(from: self)
	}
}


// MARK: Identifiable Conformance for XCode 11

// the lines below must be added if you are using XCode 11 so that ShoppingItem and Location
// conform to the Identifiable protocol.  there is no code here: each has an id
// attribute (a UUID) already defined in the Core Data model; we just need to make
// XCode aware of that.  in XCode 12, the files ShoppingItem+CoreDataProperties and
// Location+CoreDataProperties that are automatically generated include these
// conformances, probably because the id field is recognized by name and its
// type (UUID) is Hashable.  that means that this code would result in duplicate
// conformance errors.

// UNCOMMENT THE FOLLOWING LINES IF YOU USE XCODE 11
//extension ShoppingItem: Identifiable {
//	/* id is already defined in the core data model */
//}
//
//extension Location: Identifiable {
//	/* id is already defined in the core data model */
//}

