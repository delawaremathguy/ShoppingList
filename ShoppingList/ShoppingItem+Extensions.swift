//
//  ShoppingItem+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 4/23/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension ShoppingItem: Identifiable {
	
	fileprivate static var appDelegate: AppDelegate = {
		UIApplication.shared.delegate as! AppDelegate
	}()

	
	static func addNewItem(name: String, location: Location) -> ShoppingItem {
		let newItem = ShoppingItem(context: appDelegate.persistentContainer.viewContext)
		newItem.id = UUID()
		newItem.name = name
		newItem.quantity = 1
		newItem.onList = true
		newItem.setLocation(location: location)
		//newItem.location = location
		// this is "redundant information, but it helps synch order in shoppinglist
		//newItem.visitationOrder = location.visitationOrder
		appDelegate.saveContext()
		return newItem
	}
	
	static func addNewItem(nameAndLocation: String) -> ShoppingItem {
		// note: here, we're adding a ShoppintItem based on an incoming string that
		// is formatted as "Name:LocationName:visitationOrder"
		// we should get 3 String (slices), unless the location name
		// is Unknown Location -- it already exists
		let splitString = nameAndLocation.split(separator: ":")
		
		let newItem = ShoppingItem(context: appDelegate.persistentContainer.viewContext)
		newItem.id = UUID()
		newItem.name = String(splitString[0])
		newItem.quantity = 1
		newItem.onList = true
		
		// figure location name to use
		let locationName = String(splitString[1])

		// get all locations
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		var listOfLocations: [Location]
		do {
			let locations = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
			listOfLocations = locations
		} catch let error as NSError {
			print("Error fetching Locations: \(error.localizedDescription), \(error.userInfo)")
			listOfLocations = []
		}
		
		if let index = listOfLocations.firstIndex(where: { $0.name! == locationName }) {
			let location = listOfLocations[index]
			newItem.setLocation(location: location)
//			location = location
//			newItem.visitationOrder = location.visitationOrder
		} else {
			// create a new Location now
			let visitationOrder = Int(splitString[2]) ?? 100
			let newLocation = Location.addNewLocation(name: locationName, visitationOrder: visitationOrder)
			newItem.setLocation(location: newLocation)
		}

		appDelegate.saveContext()
		return newItem
	}

	
	static func delete(item: ShoppingItem) {
		appDelegate.persistentContainer.viewContext.delete(item)
		appDelegate.saveContext()
	}
	
	func setLocation(location: Location) {
		self.location = location
		visitationOrder = location.visitationOrder
	}
}
