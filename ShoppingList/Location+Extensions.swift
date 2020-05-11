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

	static func addNewLocation(name: String, visitationOrder: Int) -> Location {
		let newLocation = Location(context: appDelegate.persistentContainer.viewContext)
		newLocation.id = UUID()
		newLocation.name = name
		newLocation.visitationOrder = Int32(visitationOrder)
		appDelegate.saveContext()
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
			count += 1
		}
		print("Inserted \(count) locations.")
	}

}
	
