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

	static func entityCount() -> Int {
		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
		do {
			let count = try appDelegate.persistentContainer.viewContext.count(for: fetchRequest)
			return count
		}
		catch let error as NSError {
			print("Error couting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
		}
		return 0
	}
	
	static func addNewItem2(name: String, quantity: Int) -> ShoppingItem {
		let newItem = ShoppingItem(context: appDelegate.persistentContainer.viewContext)
		newItem.id = UUID()
		newItem.name = name
		newItem.quantity = Int32(quantity)
		newItem.onList = true
		appDelegate.saveContext()
		return newItem
	}
	
	static func addNewItem() -> ShoppingItem {
		let newItem = ShoppingItem(context: appDelegate.persistentContainer.viewContext)
		newItem.id = UUID()
		return newItem
	}

	
	static func insertNewItems(from jsonShoppingItems: [ShoppingItemJSON]) { // }, using uuid2Location: [UUID : [Location]]) {
		
		// get all Locations
		var locations: [Location]
		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
		do {
			let list = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
			locations = list
		} catch let error as NSError {
			print("Error looking up locations: \(error.localizedDescription), \(error.userInfo)")
			locations = []
		}
		
		var count = 0
		for jsonShoppingItem in jsonShoppingItems {
			let newItem = ShoppingItem(context: appDelegate.persistentContainer.viewContext)
			newItem.id = jsonShoppingItem.id
			newItem.name = jsonShoppingItem.name
			newItem.quantity = jsonShoppingItem.quantity
			newItem.onList = jsonShoppingItem.onList
			let location = locations.filter({ $0.id! == jsonShoppingItem.locationID }).first!
//			let location = uuid2Location[jsonShoppingItem.locationID]!.first!
			newItem.setLocation(location: location)
			count += 1
		}
		print("Inserted \(count) shopping items")
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
