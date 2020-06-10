//
//  ShoppingItemJSON.swift
//  ShoppingList
//
//  Created by Jerry on 5/10/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

struct ShoppingItemJSON: Codable {
	var id: UUID
	var name: String
	var onList: Bool
	var isAvailable: Bool
	var quantity: Int32
	var locationID: UUID
	
	init(from item: ShoppingItem) {
		id = item.id!
		name = item.name!
		onList = item.onList
		isAvailable = item.isAvailable
		quantity = item.quantity
		locationID = item.location!.id!
	}
	

}

