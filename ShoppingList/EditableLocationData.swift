//
//  EditableLocationData.swift
//  ShoppingList
//
//  Created by Jerry on 8/1/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

struct EditableLocationData {
	// all of the values here provide suitable defaults for a new Location
	var locationName: String = ""
	var visitationOrder: Int = 50
	var red: Double = 0.25
	var green: Double = 0.25
	var blue: Double = 0.25
	var opacity: Double = 0.40
	
	// this copies all the editable data from an incoming Location
	init(location: Location) {
		locationName = location.name!
		visitationOrder = Int(location.visitationOrder)
		red = location.red
		green = location.green
		blue = location.blue
		opacity = location.opacity
	}
	
	// provides simple, default init with values specified above
	init() { }
	
}

// MARK: - ShoppingItem Convenience Extension

extension Location {
	
	func updateValues(from editableData: EditableLocationData) {
		name = editableData.locationName
		visitationOrder = Int32(editableData.visitationOrder)
		red = editableData.red
		green = editableData.green
		blue = editableData.blue
		opacity = editableData.opacity
		
		// make sure all shopping items at this location have the
		// updated visitation information
		if let items = items as? Set<ShoppingItem> {
			for item in items {
				item.visitationOrder = visitationOrder
			}
		}
	}
}
