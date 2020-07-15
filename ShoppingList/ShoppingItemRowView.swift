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
// ShoppingItem when drawing out the text fields.

// however, this introduces a problem: if a ShoppingItem is edited somewhere
// else in the code, these changes were not really being propagated back here by the
// List.  that seemed counter-intuitive: the List obviously set up this View with
// a dependency on a ShoppingItem, didn't it?  wouldn't that force this
// to be redrawn when the parent view was redrawn? apparently, it did not.

// so to make this "work," i passed in a ShoppingItem as an @ObservedObject. then
// we have other problems.  when this ShoppingItem is deleted elsewhere in
// the app, this View was still holding on to the ShoppingItem and, depending
// upon certain timing conditions, would cause a crash: because the
// shopping item reference became meaningless (it was still a Core Data reference
// to something that was deleted in Core Data terms, but not yet saved out to disk
// -- i.e., a fault for which .isDeleted is/maybe true and .isFault is true).
// so you could no longer refer
// to the shopping item's name (which was a forced-unwrap, which would try to
// load that data and go BOOM) or even reliably refer to the item's quantity
// (a non-optional Int32).

// short story: this View might want to re-instantiate itself at certain times, but
// without the body property ever being called to draw it

// so some re-thinking forced me into this little struct below, to hold the values of an item
// from the List for this View for display, and set those up whenever the view is redrawn
// (when its body property is called), rather than hold on to or refer to the shopping item itself.
// and now this works fine, although even here, i'm not convinced it should.  but at least
// i am not holding on to a reference to the object; and i may be getting some unseen help
// from @FetchRequest, which performs a lot of magic behind the scenes in how it
// forces redraws of the List view in which this view displays.

// moral of the story: don't use ObservableObject if you don't have to (reason: that's
// more bookkeeping for SwiftUI to backtrack all the dependencies, which could potentially
// produce memory and performance problems at the expense of fidelity to the holy
// grail = source of truth).  if you do have a view that depends on an ObservableObject,
// either make sure that object can't be pulled out from under you, or guarantee that the
// variables that constitute this struct are meaningful even if the object is no longer there.

struct ShoppingItemRowData {
	var isAvailable: Bool = true
	var name: String = ""
	var locationName: String = ""
	var quantity: Int32 = 0
	var showLocation: Bool = true	// whether this is a two-line display, with location as secondary line
	
	init(item: ShoppingItem, showLocation: Bool = true) {
		isAvailable  = item.isAvailable
		name = item.name!
		locationName = item.location!.name!
		quantity = item.quantity
		self.showLocation = showLocation
	}
	
	init() { }
	
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
			
			Text("\(itemData.quantity)")
				.font(.headline)
				.foregroundColor(Color.blue)
			
		} // end of HStack
	}

}

