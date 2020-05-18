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

	static func entityCount() -> Int {
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		do {
			let count = try appDelegate.persistentContainer.viewContext.count(for: fetchRequest)
			return count
		}
		catch let error as NSError {
			print("Error couting Locations: \(error.localizedDescription), \(error.userInfo)")
		}
		return 0
	}

	static func allLocations() -> [Location] {
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		do {
			let items = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
			return items
		}
		catch let error as NSError {
			print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
		}
		return [Location]()
	}

	static func addNewLocation() -> Location {
		let newLocation = Location(context: appDelegate.persistentContainer.viewContext)
		newLocation.id = UUID()
		return newLocation
	}

	static func unknownLocation() -> Location? {
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
	
	static func insertNewLocations(from jsonLocations: [LocationJSON]) {
		var count = 0
		for jsonLocation in jsonLocations {
			let newLocation = Location(context: appDelegate.persistentContainer.viewContext)
			newLocation.id = jsonLocation.id
			newLocation.name = jsonLocation.name
			newLocation.visitationOrder = jsonLocation.visitationOrder
			newLocation.red = jsonLocation.red
			newLocation.green = jsonLocation.green
			newLocation.blue = jsonLocation.blue
			newLocation.opacity = jsonLocation.opacity
			count += 1
		}
		print("Inserted \(count) locations.")
	}
	
	static func delete(item: Location) {
		appDelegate.persistentContainer.viewContext.delete(item)
		appDelegate.saveContext()
	}

	
	static func saveChanges() {
		appDelegate.saveContext()
	}


}
	
