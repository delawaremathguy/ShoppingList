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
	
	static func allShoppingItems() -> [ShoppingItem] {
		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
		do {
			let items = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
			return items
		}
		catch let error as NSError {
			print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
		}
		return [ShoppingItem]()
	}

	
	static func addNewItem() -> ShoppingItem {
		let newItem = ShoppingItem(context: appDelegate.persistentContainer.viewContext)
		newItem.id = UUID()
		return newItem
	}

	
	static func insertNewItems(from jsonShoppingItems: [ShoppingItemJSON]) {
		
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
		
		// group by id for faster lookup below
		let uuid2Location = Dictionary(grouping: locations, by: { $0.id! })
		
		var count = 0
		for jsonShoppingItem in jsonShoppingItems {
			let newItem = ShoppingItem(context: appDelegate.persistentContainer.viewContext)
			newItem.id = jsonShoppingItem.id
			newItem.name = jsonShoppingItem.name
			newItem.quantity = jsonShoppingItem.quantity
			newItem.onList = jsonShoppingItem.onList
			if let location = uuid2Location[jsonShoppingItem.locationID]?.first { // we should have a matching location
				newItem.setLocation(location)
			} else { // but in case the data doesn't match, put this item in the unknown location
				newItem.setLocation(Location.unknownLocation()!)
			}
			count += 1
		}
		print("Inserted \(count) shopping items")
	}
	
	static func saveChanges() {
		appDelegate.saveContext()
	}

	
	static func delete(item: ShoppingItem) {
		appDelegate.persistentContainer.viewContext.delete(item)
		appDelegate.saveContext()
	}
	

	func setLocation(_ location: Location) {
		self.location = location
		visitationOrder = location.visitationOrder
	}
}

extension ShoppingItem: JSONRepresentable {
	var jsonProxy: some Decodable & Encodable {
		return ShoppingItemJSON(from: self)
	}
}
