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

	
	static func addNewItem(name: String) -> ShoppingItem {
		let newItem = ShoppingItem(context: appDelegate.persistentContainer.viewContext)
		newItem.id = UUID()
		newItem.name = name
		newItem.purchased = false
		appDelegate.saveContext()
		return newItem
	}
	
	static func delete(item: ShoppingItem) {
		appDelegate.persistentContainer.viewContext.delete(item)
		appDelegate.saveContext()
	}
}
