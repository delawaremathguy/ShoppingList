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
	@State private var red: Double = 0
	@State private var green: Double = 0
	@State private var blue: Double = 0
	@State private var opacity: Double = 0

	var body: some View {
		Form {
			// 1: Name, Visitation Order, Colors
			Section(header: Text("Basic Information")) {
				TextField("Location name", text: $locationName)
				if location.visitationOrder != kUnknownLocationVisitationOrder {
					Stepper(value: $visitationOrder, in: 1...100) {
						Text("Visitation Order: \(visitationOrder)")
					}
				}
				
				HStack {
					Text("Red: \(red)")
					Spacer()
					Slider(value: $red, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Text("Green: \(green)")
					Spacer()
					Slider(value: $green, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Text("Blue: \(blue)")
					Spacer()
					Slider(value: $blue, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Text("Opacity: \(opacity)")
					Spacer()
					Slider(value: $opacity, in: 0 ... 1)
						.frame(width: 200)
				}
				Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)

			}
			
			// 2
			Section(header: Text("Location Management")) {
				HStack {
					Spacer()
					Button("Save") {
						self.commitData()
					}
					.disabled(locationName.isEmpty)
					Spacer()
				}
				
				HStack {
					Spacer()
					Button("Delete This Location") {
						self.deleteLocation()
					}
					.foregroundColor(Color.red)
					.disabled(true)
					Spacer()
				}
			}  // end of Section				}
		} // end of Form
			.navigationBarTitle("Add New Location", displayMode: .inline)
				.onAppear(perform: loadData)
	}
	
	func deleteLocation() {
		// we will move all items in this location to the Unknown Location
		// if we can't find it, however, bail now
		guard let unknownLocation = Location.unknownLocation() else { return }
		
		// ADD ALERT: are you sure ????
		
		// need to move all items in this location to Unknown
		if let items = location.items as? Set<ShoppingItem> {
			for item in items {
				item.location?.removeFromItems(item)
				item.setLocation(location: unknownLocation)
			}
		}
		// now finish and deismiss
		managedObjectContext.delete(location)
		try? managedObjectContext.save()
		presentationMode.wrappedValue.dismiss()
	}

	func commitData() {
		location.name = locationName
		location.visitationOrder = Int32(visitationOrder)
		location.red = red
		location.green = green
		location.blue = blue
		location.opacity = opacity
		// THE PROBLEM: we now may have reordered the Locations by visitationOrder.
		// and if we return to the list of Locations, that's cool.  but if we move
		// over to the shopping list tab (or if we go back and then move over to the
		// shopping list tab), we're screwed -- it has not seen this update.
		// so we will update the parallel visitationOrder in all the shoppingList
		// items to match this order
		if let shoppingItems = location.items as? Set<ShoppingItem> {
			for item in shoppingItems {
				item.visitationOrder = Int32(visitationOrder)
			}
		}
		try? managedObjectContext.save()
		presentationMode.wrappedValue.dismiss()
	}

	func loadData() {
		locationName = location.name!
		visitationOrder = Int(location.visitationOrder)
		red = location.red
		green = location.green
		blue = location.blue
		opacity = location.opacity
	}
}

