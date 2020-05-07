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
		// here, we could go through every ShoppingItem that references this location and
		// remove/reinsert links to this Location -- maybe that would trigger a ShoppingListView
		// update.  if not, we should go back to using a modificationToken strategy and update
		// the modificationToken of every ShoppingItem that references this location.
		try? managedObjectContext.save()
		presentationMode.wrappedValue.dismiss()
	}

	func loadData() {
		locationName = location.name!
		visitationOrder = Int(location.visitationOrder)
	}
}

