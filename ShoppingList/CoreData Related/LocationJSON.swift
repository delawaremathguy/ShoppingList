//
//  LocationJSON.swift
//  ShoppingList
//
//  Created by Jerry on 5/10/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

struct LocationJSON: Codable {
	var name: String
	var visitationOrder: Int32
	var red: Double
	var green: Double
	var blue: Double
	var opacity: Double


	init(from location: Location) {
		name = location.name!
		visitationOrder = location.visitationOrder
		red = location.red
		green = location.green
		blue = location.blue
		opacity = location.opacity
	}
}
