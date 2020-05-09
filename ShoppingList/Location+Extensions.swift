//
//  Location+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import UIKit

// constants
let kUnknownLocationName = "Unknown Location"
let kUnknownLocationVisitationOrder = INT32_MAX

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

}
	
