//
//  ModifyLocationView.swift
//  ShoppingList
//
//  Created by Jerry on 5/7/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct ModifyLocationView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.presentationMode) var presentationMode
	@ObservedObject var location: Location
	@State private var locationName: String = ""
	@State private var visitationOrder: Int = 0

    var body: some View {
			Form {
				// 1: Name and Quantity
				Section {
					TextField("Location name", text: $locationName)
					Stepper(value: $visitationOrder, in: 1...100) {
						Text("Visitation Order: \(visitationOrder)")
					}
					
					
					// 2
					Section {
						Button("Save") {
							self.commitData()
						}
					}
				} // end of Section
			} // end of Form
				.navigationBarTitle("Add New Location", displayMode: .inline)
				.onAppear(perform: loadData)
	}

	func commitData() {
		location.name = locationName
		location.visitationOrder = Int32(visitationOrder)
		// THE PROBLEM: we now may have reordered the Locations by visitationOrder.
		// and if we return to the list of Locations, that's cool.  but if we move
		// over to the shopping list tab (or if we go back and then move over to the
		// shopping list tab), we're screwed -- it has not seen this update.
		// one possible remedy: reinstate a modificationToken for each ShoppingListItem
		// and id: the list items in the shoppingList by the modificationToken?
		try? managedObjectContext.save()
		presentationMode.wrappedValue.dismiss()
	}

	func loadData() {
		locationName = location.name!
		visitationOrder = Int(location.visitationOrder)
	}
}

