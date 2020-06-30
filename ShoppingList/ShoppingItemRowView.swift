//
//  ItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// DEVELOPMENT COMMENT

// this one small View was the source of repeated problems for some time.
// my natural tendency was to "pass in" the ShoppingItem whose data was
// displayed in one row of a List, and then read the fields of the
// ShoppingItem below.

// however, this introduces a problem: if the ShoppingItem is edited somewhere
// else in the code, those changes were not being propagated back here by the
// List.  that seemed counter-intuitive: the List obviously set up this View with
// an obvious dependency on a ShoppingItem, didn't it?  wouldn't that force this
// to be redrawn? apparently, it did not.

// so to make this work, i passed in a ShoppingItem as an @ObservedObject. then
// we have other problems.  when this ShoppingItem is deleted elsewhere in
// the app, this View was still holding on to the ShoppingItem and, depending
// upon certain timing conditions, would cause a crash: not because the
// shopping item reference became meaningless (it was still a Core Data reference
// to something that was deleted in Core Data terms, but not yet saved out to disk
// (i.e., a fault for which .isDeleted is true).  so you could no longer refer
// to the shopping item's name (which was an optional, which would try to
// load that data and go BOOM) or even reliably refer to the item's quantity
// (a non-optional Int32).

// short story: this View would want to redraw a deleted item!

// so some re-thinking frced me into this little struct here, to carry the values
// from the List to this View for display, rather than the shopping item itself.
// and now this works fine.

// moral of the story: don't pass along an object if you only want to read some values
// from it.  instead, just pass along the values (in this case, as a struct for
// better bookkeeping).

struct ShoppingItemRowData {
	var isAvailable: Bool = true
	var name: String = ""
	var locationName: String = ""
	var quantity: Int32 = 0
	var showLocation: Bool	// whether this is a two-line display, with location as secondary line
	
	init(item: ShoppingItem, showLocation: Bool = true) {
		isAvailable  = item.isAvailable
		name = item.name!
		locationName = item.location!.name!
		quantity = item.quantity
		self.showLocation = showLocation
	}
}

struct ShoppingItemRowView: View {
	// shows one line in a list for a shopping item.

	var itemData: ShoppingItemRowData
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				
				if itemData.isAvailable {
					Text(itemData.name)
				} else {
					Text(itemData.name)
						.font(.body)
						.overlay(Rectangle().frame(height: 1.0))
				}
				
				if itemData.showLocation {
					Text(itemData.locationName)
						.font(.caption)
						.foregroundColor(.secondary)
				}
			}
			
			Spacer()
			
			Text(String(itemData.quantity))
				.font(.headline)
				.foregroundColor(Color.blue)
			
		} // end of HStack
	}
}

