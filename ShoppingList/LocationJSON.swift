//
//  LocationJSON.swift
//  ShoppingList
//
//  Created by Jerry on 5/10/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

struct LocationJSON: Codable {
	var id: UUID
	var name: String
	var visitationOrder: Int32
	
	init(from location: Location) {
		id = location.id!
		name = location.name!
		visitationOrder = location.visitationOrder
	}
}
