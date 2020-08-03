//
//  NotificationName+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 8/3/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// the whole purpose of the ViewModelCoordinator is that it is a shared
// (or global) resurce that individual view models can talk to, basically with only
// two messages for ShoppingItems and two messages for Locations:
//
// -- item will be deleted
// -- item was added to the Core Data store
// -- item has been edited
//
// it then just rebroadcasts (i.e., sends a notification) about it
// the many view models out and about should sign up for these
// notifications and act appropriately (or ignore)

// these are the message tokens:

extension Notification.Name {
	// for changes to shopping items
	static let shoppingItemAdded = Notification.Name(rawValue: "shoppingItemAdded")
	static let shoppingItemEdited = Notification.Name(rawValue: "shoppingItemEdited")
	static let shoppingItemWillBeDeleted = Notification.Name(rawValue: "shoppingItemEdited")
	
	// for changes to locations
	static let locationEdited = Notification.Name(rawValue: "shoppingItemEdited")
	static let locationWillBeDeleted = Notification.Name(rawValue: "shoppingItemEdited")
}

