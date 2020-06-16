//
//  ShoppingItemJSON.swift
//  ShoppingList
//
//  Created by Jerry on 5/10/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

struct ShoppingItemJSON: Codable {
	var name: String
	var onList: Bool
	var isAvailable: Bool
	var quantity: Int32
	var locationName: String	// there's some assumption here that location names are unique
	
	init(from item: ShoppingItem) {
		name = item.name!
		onList = item.onList
		isAvailable = item.isAvailable
		quantity = item.quantity
		locationName = item.location!.name!
	}
	

}

