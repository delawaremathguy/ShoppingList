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
	
//	fileprivate static var appDelegate: AppDelegate = {
//		UIApplication.shared.delegate as! AppDelegate
//	}()
	
	static func count() -> Int {
		let context = PersistentStore.shared.context
		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
		do {
			let itemCount = try context.count(for: fetchRequest)
			return itemCount
		}
		catch let error as NSError {
			print("Error counting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
		}
		return 0
	}

	static func allShoppingItems() -> [ShoppingItem] {
		let context = PersistentStore.shared.context
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
	
	static func moveAllItemsOffList() {
		let context = PersistentStore.shared.context
		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "onList == true")
		do {
			let items = try context.fetch(fetchRequest)
			items.forEach({ $0.onList = false })
		}
		catch let error as NSError {
			print("Error getting items onList: \(error.localizedDescription), \(error.userInfo)")
		}
		saveChanges()
	}
	
	static func markAllItemsAvailable() {
		let context = PersistentStore.shared.context
		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "isAvailable == false")
		do {
			let items = try context.fetch(fetchRequest)
			items.forEach({ $0.isAvailable = true })
		}
		catch let error as NSError {
			print("Error getting items not available: \(error.localizedDescription), \(error.userInfo)")
		}
		saveChanges()
	}
	

	// addNewItem is the user-facing add of a new entity.  since these are
	// Identifiable objects, this makes sure we give the entity a unique id, then
	// hand it back so the user can fill in what's important to them.
	static func addNewItem() -> ShoppingItem {
		let context = PersistentStore.shared.context
		let newItem = ShoppingItem(context: context)
		newItem.id = UUID()
		return newItem
	}

	static func insertNewItems(from codableShoppingItems: [ShoppingItemCodable]) {
		
		// get all Locations that are not the unknown location
		// group by id for faster lookup below when adding an item to a location
		let locations = Location.allUserLocations()
		let name2Location = Dictionary(grouping: locations, by: { $0.name! })
		
		for codableShoppingItem in codableShoppingItems {
			let newItem = addNewItem() // new UUID is created here
			newItem.name = codableShoppingItem.name
			newItem.quantity = codableShoppingItem.quantity
			newItem.onList = codableShoppingItem.onList
			newItem.isAvailable = codableShoppingItem.isAvailable
			
			// look up matching location by id
			// anything that doesn't match goes to the unknown location.
			if let location = name2Location[codableShoppingItem.locationName]?.first {
				newItem.setLocation(location)
			} else {
				newItem.setLocation(Location.unknownLocation()!)
			}
		}
	}
	
	static func saveChanges() {
		PersistentStore.shared.saveContext()
	}

	static func delete(item: ShoppingItem, saveChanges: Bool = false) {
		// remove reference to this item from its associated location first, then delete
		let location = item.location
		location?.removeFromItems(item)
		let context = PersistentStore.shared.context
		context.delete(item)
		if saveChanges {
			Self.saveChanges()
		}
	}
	
	var backgroundColor: UIColor {
		return location!.uiColor()
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

extension ShoppingItem: CodableStructRepresentable {
	var codableProxy: some Encodable & Decodable {
		return ShoppingItemCodable(from: self)
	}
}
