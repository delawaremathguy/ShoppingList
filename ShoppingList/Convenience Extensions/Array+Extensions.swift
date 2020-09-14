//
//  Array+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 6/4/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

extension Array {
	
	// count the number of elements that satisy a given boolean condition
	func count(where selector: (Element) -> Bool) -> Int {
		reduce(0) { (sum, Element) -> Int in
			return selector(Element) ? sum + 1 : sum
		}
	}
}
