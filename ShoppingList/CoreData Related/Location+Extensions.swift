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

extension Location: Identifiable {
	
	fileprivate static var appDelegate: AppDelegate = {
		UIApplication.shared.delegate as! AppDelegate
	}()

	static func count() -> Int {
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "visitationOrder != %d", kUnknownLocationVisitationOrder)
		do {
			let itemCount = try appDelegate.persistentContainer.viewContext.count(for: fetchRequest)
			return itemCount
		}
		catch let error as NSError {
			print("Error counting User Locations: \(error.localizedDescription), \(error.userInfo)")
		}
		return 0
	}

	static func allUserLocations() -> [Location] {
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "visitationOrder != %d", kUnknownLocationVisitationOrder)
		do {
			let items = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
			return items
		}
		catch let error as NSError {
			print("Error getting User Locations: \(error.localizedDescription), \(error.userInfo)")
		}
		return [Location]()
	}

	static func addNewLocation() -> Location {
		let newLocation = Location(context: appDelegate.persistentContainer.viewContext)
		newLocation.id = UUID()
		return newLocation
	}
	
	static func createUnknownLocation() {
		let unknownLocation = Location(context: appDelegate.persistentContainer.viewContext)
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
		// find it because its visitationOrder is the larget 32-bit integer.
		// return nil if no such thing exists, which means that the data store
		// is empty (since all ShoppingItems have an assigned Location).
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "visitationOrder == %d", kUnknownLocationVisitationOrder)
		do {
			let locations = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
			if locations.count == 1 {
				return locations[0]
			}
		} catch let error as NSError {
			print("Error fetching unknown location: \(error.localizedDescription), \(error.userInfo)")
		}
		return nil
	}
	
	// used to insert data from JSON files in the app bundle
	static func insertNewLocations(from jsonLocations: [LocationCodable]) {
		for jsonLocation in jsonLocations {
			let newLocation = addNewLocation() // new UUID created here
			newLocation.name = jsonLocation.name
			newLocation.visitationOrder = jsonLocation.visitationOrder
			newLocation.red = jsonLocation.red
			newLocation.green = jsonLocation.green
			newLocation.blue = jsonLocation.blue
			newLocation.opacity = jsonLocation.opacity
		}
	}
	
	static func delete(location: Location, saveChanges: Bool = false) {
		// you cannot delete the unknownLocation
		guard location.visitationOrder != kUnknownLocationVisitationOrder else { return }
		// retrieve all items for this location tso we can work with them
		// this if let should succeed (!)
		var itemsAtThisLocation = Set<ShoppingItem>()
		if let shoppingItems = location.items as? Set<ShoppingItem> {
			itemsAtThisLocation = shoppingItems
		}
		
		// take all shopping items associated with this location and
		// move then to the unknown location
		let theUnknownLocation = Location.unknownLocation()!
		for item in itemsAtThisLocation {
			location.removeFromItems(item)
			item.setLocation(theUnknownLocation)
		}
		// and finish the deletion
		location.managedObjectContext?.delete(location)
		if saveChanges {
			appDelegate.saveContext()
		}
	}

	static func saveChanges() {
		appDelegate.saveContext()
	}
	
	func uiColor() -> UIColor {
		UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(opacity))
	}
	
}

extension Location: CodableStructRepresentable {
	var codableProxy: some Encodable & Decodable {
		return LocationCodable(from: self)
	}
}
	
extension Location: Comparable {
	public static func < (lhs: Location, rhs: Location) -> Bool {
		lhs.visitationOrder < rhs.visitationOrder
	}
	
}
