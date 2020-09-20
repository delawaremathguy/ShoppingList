//
//  Location+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import UIKit
import CoreData

// constants
let kUnknownLocationName = "Unknown Location"
let kUnknownLocationVisitationOrder: Int32 = INT32_MAX

extension Location: Comparable {
	
	// add Comparable conformance: sort by visitation order
	public static func < (lhs: Location, rhs: Location) -> Bool {
		lhs.visitationOrder < rhs.visitationOrder
	}
	
	// MARK: - Class Functions for CRUD Operations
	
	static func count() -> Int {
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		do {
			let itemCount = try PersistentStore.shared.context.count(for: fetchRequest)
			return itemCount
		}
		catch let error as NSError {
			print("Error counting User Locations: \(error.localizedDescription), \(error.userInfo)")
		}
		return 0
	}

	// return a list of all locations, optionally returning only user-defined location
	// (i.e., excluding the unknown location)
	static func allLocations(userLocationsOnly: Bool) -> [Location] {
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		if userLocationsOnly {
			fetchRequest.predicate = NSPredicate(format: "visitationOrder != %d", kUnknownLocationVisitationOrder)
		}
		do {
			let items = try PersistentStore.shared.context.fetch(fetchRequest)
			return items
		}
		catch let error as NSError {
			print("Error getting User Locations: \(error.localizedDescription), \(error.userInfo)")
		}
		return [Location]()
	}

	// creates a new Location having an id, but then it's the user's responsibility
	// to fill in the field values (and eventually save)
	static func addNewLocation() -> Location {
		let newLocation = Location(context: PersistentStore.shared.context)
		newLocation.id = UUID()
		return newLocation
	}
	
	// parameters for the Unknown Location.  call this only upon startup if
	// the Core Data database has not yet been initialized
	static func createUnknownLocation() {
		let unknownLocation = Location(context: PersistentStore.shared.context)
		unknownLocation.id = UUID()
		unknownLocation.name = kUnknownLocationName
		unknownLocation.red = 0.5
		unknownLocation.green = 0.5
		unknownLocation.blue = 0.5
		unknownLocation.opacity = 0.5
		unknownLocation.visitationOrder = kUnknownLocationVisitationOrder
	}

	static func unknownLocation() -> Location? {
		// we only keep one "UnknownLocation" in the data store.  you can
		// find it because its visitationOrder is the largest 32-bit integer.
		// return nil if no such thing exists, which means that the data store
		// is empty (since all ShoppingItems have an assigned Location).
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "visitationOrder == %d", kUnknownLocationVisitationOrder)
		do {
			let locations = try PersistentStore.shared.context.fetch(fetchRequest)
			if locations.count == 1 {
				return locations[0]
			}
		} catch let error as NSError {
			print("Error fetching unknown location: \(error.localizedDescription), \(error.userInfo)")
		}
		return nil
	}
	
	static func delete(location: Location, saveChanges: Bool = false) {
		// you cannot delete the unknownLocation
		guard location.visitationOrder != kUnknownLocationVisitationOrder else { return }

		// OK, announce what's about to happen
		NotificationCenter.default.post(name: .locationWillBeDeleted, object: location)

		// retrieve all items for this location so we can work with them
		let itemsAtThisLocation = location.items as? Set<ShoppingItem> ?? Set<ShoppingItem>()
		
		// remove all shopping items associated with this location from the Location's
		// NSSet of ShoppingItem, then move then to the unknown location
		let theUnknownLocation = Location.unknownLocation()!
		for item in itemsAtThisLocation {
			item.location?.removeFromItems(item)
			item.location = theUnknownLocation
		}
		// and finish the deletion
		location.managedObjectContext?.delete(location)
		if saveChanges {
			PersistentStore.shared.saveContext()
		}
	}

	static func saveChanges() {
		PersistentStore.shared.saveContext()
	}
	
	// MARK: - Reference functions
	
	func uiColor() -> UIColor {
		UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(opacity))
	}
	
	func isUnknownLocation() -> Bool {
		return visitationOrder == kUnknownLocationVisitationOrder
	}
	
}

