//
//  NotificationName+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 8/3/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// the whole purpose of the NotificationName+Extensions is to centrally define
// names for the Notifications we pass around to let all view models know that
// something is about to be changed in a Shopping item.  there are generally:
//
// -- item/location was added to the Core Data store
// -- item/location has been edited
// -- item/location will be deleted
//

extension Notification.Name {
	// for changes to shopping items.  the user should pass the relevant ShoppingItem
	// along as the object when posting these notifications
	static let shoppingItemAdded = Notification.Name(rawValue: "shoppingItemAdded")
	static let shoppingItemEdited = Notification.Name(rawValue: "shoppingItemEdited")
	static let shoppingItemWillBeDeleted = Notification.Name(rawValue: "shoppingItemDeleted")

	// for changes to locations.  the user should pass the relevant Location
	// along as the object when posting these notifications
	static let locationAdded = Notification.Name(rawValue: "locationAdded")
	static let locationEdited = Notification.Name(rawValue: "locationEdited")
	static let locationWillBeDeleted = Notification.Name(rawValue: "locationWillBeDeleted")
	
}

