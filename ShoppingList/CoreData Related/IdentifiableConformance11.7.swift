//
//  IdentifiableConformance11.7.swift
//  ShoppingList
//
//  Created by Jerry on 9/20/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// Identifiable Conformance for XCode 11

// the lines below must be added if you are using XCode 11 so that ShoppingItem and Location
// conform to the Identifiable protocol.  there is no code here: each entity has an id
// attribute (a UUID) already defined in the Core Data model; we just need to make
// XCode aware of that.  in XCode 12, the files ShoppingItem+CoreDataProperties and
// Location+CoreDataProperties that are automatically generated include these
// conformances.  that results in duplicate conformance errors if
// this file is included.  to compile under XCode 12, remove/comment out this file.

extension ShoppingItem: Identifiable {
	/* id is already defined in the core data model */
}

extension Location: Identifiable {
	/* id is already defined in the core data model */
}
