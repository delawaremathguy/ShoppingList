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
	
	// this whole bunch of static functions lets me do a simple fetch and
	// CRUD operations through the AppDelegate, including one called saveChanges(),
	// so that i don't have to litter a whole bunch of try? moc.save() statements
	// out in the Views.
	
	fileprivate static var appDelegate: AppDelegate = {
		UIApplication.shared.delegate as! AppDelegate
	}()
	
	static func count() -> Int {
		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
		do {
			let itemCount = try appDelegate.persistentContainer.viewContext.count(for: fetchRequest)
			return itemCount
		}
		catch let error as NSError {
			print("Error counting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
		}
		return 0
	}

	static func allShoppingItems() -> [ShoppingItem] {
		let context = appDelegate.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
		do {
			let items = try context.fetch(fetchRequest)
			return items
		}
		catch let error as NSError {
			print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
		}
		return [ShoppingItem]()
	}
	
	// addNewItem is the user-facing add of a new entity.  since these are
	// Identifiable objects, this makes sure we give the entity a unique id, then
	// hand it back so the user can fill in what's important to them.
	static func addNewItem() -> ShoppingItem {
		let context = appDelegate.persistentContainer.viewContext
		let newItem = ShoppingItem(context: context)
		newItem.id = UUID()
		return newItem
	}

	static func insertNewItems(from jsonShoppingItems: [ShoppingItemJSON]) {
		
		// get all Locations that are not the unknown location
		// group by id for faster lookup below when adding an item to a location
		let locations = Location.allUserLocations()
		let name2Location = Dictionary(grouping: locations, by: { $0.name! })
		
//		var count = 0
		for jsonShoppingItem in jsonShoppingItems {
			let newItem = addNewItem() // new UUID is created here
			newItem.name = jsonShoppingItem.name
			newItem.quantity = jsonShoppingItem.quantity
			newItem.onList = jsonShoppingItem.onList
			newItem.isAvailable = jsonShoppingItem.isAvailable
			
			// look up matching location by id
			// anything that doesn't match goes to the unknown location.
			if let location = name2Location[jsonShoppingItem.locationName]?.first {
				newItem.setLocation(location)
			} else {
				newItem.setLocation(Location.unknownLocation()!)
			}
//			count += 1
		}
//		print("Inserted \(count) shopping items")
	}
	
	static func saveChanges() {
		appDelegate.saveContext()
	}

	static func delete(item: ShoppingItem, saveChanges: Bool = false) {
		// remove reference to this item from its associated location first, then delete
		let location = item.location
		location?.removeFromItems(item)
		let context = appDelegate.persistentContainer.viewContext
		context.delete(item)
		if saveChanges {
			Self.saveChanges()
		}
	}
	
	// these functions coordinate state transitions of ShoppingItems,
	// which are onList or not.
	func moveToShoppingList(saveChanges: Bool = false) {
		onList = true
		if saveChanges {
			Self.saveChanges()
		}
	}
	
	func moveToPuchased(saveChanges: Bool = false) {
		onList = false
		if saveChanges {
			Self.saveChanges()
		}
	}
	
	func mark(available: Bool, saveChanges: Bool = false) {
		isAvailable = available
		if saveChanges {
			Self.saveChanges()
		}
	}
	
	func setLocation(_ location: Location) {
		// if this ShoppingItem is already linked to a Location,
		// remove its reference from that location now (notice use of ?.?.!)
		self.location?.removeFromItems(self)
		self.location = location
		visitationOrder = location.visitationOrder
	}
}

extension ShoppingItem: JSONRepresentable {
	var jsonProxy: some Encodable & Decodable {
		return ShoppingItemJSON(from: self)
	}
}
