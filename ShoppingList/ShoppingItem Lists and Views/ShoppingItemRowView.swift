//
//  ItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// DEVELOPMENT COMMENT

// this is a display-only view.  yet this one small View was the source of repeated
// problems for some time. my natural tendency was to "pass in" the ShoppingItem
// whose data was displayed in one row of a List, and then read the fields of the
// ShoppingItem directly when drawing out the text fields.

// however, this introduced a problem: if a ShoppingItem was edited somewhere
// else in the code, these changes were not really being propagated back here by the
// List/ForEach.  that seemed counter-intuitive: the List obviously set up this View with
// a dependency on a ShoppingItem, didn't it?  wouldn't that force this
// to be redrawn when the parent view was redrawn? apparently, it did not.
// i think the reason is that SwiftUI only noticed that the list of items still
// looked to be the same ... it was driven by ForEach(shoppingItems) and did not
// really see changes to the fields of the item.

// so to make this "work," i passed in a ShoppingItem as an @ObservedObject. then
// we have other problems.  when this ShoppingItem is deleted elsewhere in
// the app, this View was still holding on to the ShoppingItem (i.e., not really the View,
// which comes and goes, but SwiftUI for when the View might get re-instantiated) and,
// depending upon certain timing conditions, would cause a crash: because the
// shopping item reference became meaningless (it was still a Core Data reference
// to something that was deleted in Core Data terms, but not yet saved out to disk
// -- i.e., a fault for which .isDeleted is/maybe true and .isFault is true).
// so you could no longer refer to the shopping item's name (which was a forced-unwrap,
// which would try to load that data and go BOOM) or even reliably refer to the item's quantity
// (a non-optional Int32).

// so some re-thinking forced me into this little trickery below, to pass in the values
// of an item from the List/ForEach construct for this View for display.
// and now this works fine, although even here, i'm not convinced it should. apparently this
// syntax is enough for the List/ForEach to recognize the change in any relevant fields.

// but at least i am not holding on to a reference to the object; and i may be getting
// either some unseen or accidental help
// because i use a @FetchRequest, which performs a lot of magic behind the scenes in how it
// forces redraws of the List view in which this view displays.

struct ShoppingItemRowData {
	var isAvailable: Bool = true
	var name: String = ""
	var locationName: String = ""
	var quantity: Int32 = 0
	var showLocation: Bool = true	// whether this is a two-line display, with location as secondary line
	
	init(item: ShoppingItem, showLocation: Bool = true) {
		isAvailable  = item.isAvailable
		name = item.name ?? "Item being deleted"
		locationName = item.location?.name ?? "Some Location"
		quantity = item.quantity
		self.showLocation = showLocation
	}
	
	init() { } // syntax necessity, although all values are reasonable setd
	
}

// shows one line in a list for a shopping item.  pass in the data to be shown.
struct ShoppingItemRowView: View {
	
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
			
			Text("\(itemData.quantity)")
				.font(.headline)
				.foregroundColor(Color.blue)
			
		} // end of HStack
	}

}

