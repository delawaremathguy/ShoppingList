//
//  ModifyLocationView.swift
//  ShoppingList
//
//  Created by Jerry on 5/7/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct AddorModifyLocationView: View {
	// @Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.presentationMode) var presentationMode
	var editableLocation: Location? = nil
	
	@State private var locationName: String = "" // all of these values are suitable defaults for a new location
	@State private var visitationOrder: Int = 50
	@State private var red: Double = 0.25
	@State private var green: Double = 0.25
	@State private var blue: Double = 0.25
	@State private var opacity: Double = 0.40
	
	@State private var dataHasBeenLoaded = false
	@State private var showDeleteConfirmation: Bool = false
			
	var body: some View {
		Form {
			// 1: Name, Visitation Order, Colors
			Section(header: Text("Basic Information")) {
				HStack {
					MyFormLabelText(labelText: "Name: ")
					TextField("Location name", text: $locationName)
				}
				
				if visitationOrder != kUnknownLocationVisitationOrder {
					Stepper(value: $visitationOrder, in: 1...100) {
						HStack {
							MyFormLabelText(labelText: "Visitation Order: ")
							Text("\(visitationOrder)")
						}
					}
				}
			} // end of Section
				
			Section(header: Text("Color Adjustment")) {
				HStack {
					MyFormLabelText(labelText: "Composite Color: ")
					Spacer()
					RoundedRectangle(cornerRadius: 16)
						.fill(Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity))
						.frame(width: 200)
						.overlay(Capsule().stroke(Color.black, lineWidth: 1))
				}
				HStack {
					Spacer()
					HStack {
						Text("Red: ")
						Text(String(format: "%.2f", red))
							.frame(width:40)
					}
					Slider(value: $red, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Spacer()
					HStack {
						Text("Green: ")
						Text(String(format: "%.2f", green))
							.frame(width:40)
					}
					Slider(value: $green, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Spacer()
					HStack {
						Text("Blue: ")
						Text(String(format: "%.2f", blue))
							.frame(width:40)
					}
					Slider(value: $blue, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Spacer()
					HStack {
						Text("Opacity: ")
						Text(String(format: "%.2f", opacity))
							.frame(width:40)
					}
					Slider(value: $opacity, in: 0 ... 1)
						.frame(width: 200)
				}
	
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
				
				if editableLocation != nil {
					HStack {
						Spacer()
						Button("Delete This Location") {
							self.showDeleteConfirmation = true
						}
						.foregroundColor(Color.red)
						Spacer()
					}
				}
			}  // end of Section
			
			
		} // end of Form
			.onAppear(perform: loadData)
			.navigationBarTitle("Add New Location", displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading: Button(action : {
				self.presentationMode.wrappedValue.dismiss()
			}){
				Text("Cancel")
			})
			.alert(isPresented: $showDeleteConfirmation) {
				Alert(title: Text("Delete \'\(locationName)\'?"),
							message: Text("Are you sure you want to delete this location?"),
							primaryButton: .cancel(Text("No")),
							secondaryButton: .destructive(Text("Yes"), action: self.deleteLocation)
				)}
	}
	
	func deleteLocation() {
		// we will move all items in this location to the Unknown Location
		// if we can't find it, however, bail now
		if let unknownLocation = Location.unknownLocation(),
			let location = editableLocation {
			
			// need to move all items in this location to Unknown
			if let shoppingItems = location.items as? Set<ShoppingItem> {
				for item in shoppingItems {
					location.removeFromItems(item)
					item.setLocation(location: unknownLocation)
				}
			}
			
			// now finish and dismiss
			Location.delete(item: location)
			presentationMode.wrappedValue.dismiss()
		}
	}

	func commitData() {
		var locationForCommit: Location
		if let location = editableLocation {
			locationForCommit = location
		} else {
			locationForCommit = Location.addNewLocation()
		}
		
		locationForCommit.name = locationName
		locationForCommit.visitationOrder = Int32(visitationOrder)
		locationForCommit.red = red
		locationForCommit.green = green
		locationForCommit.blue = blue
		locationForCommit.opacity = opacity
		// THE PROBLEM: we now may have reordered the Locations by visitationOrder.
		// and if we return to the list of Locations, that's cool.  but if we move
		// over to the shopping list tab (or if we go back and then move over to the
		// shopping list tab), we're screwed -- it has not seen this update.
		// so we will update the parallel visitationOrder in all the shoppingList
		// items to match this order
		if let shoppingItems = locationForCommit.items as? Set<ShoppingItem> {
			for item in shoppingItems {
				item.visitationOrder = Int32(visitationOrder)
			}
		}
		Location.saveChanges()
		presentationMode.wrappedValue.dismiss()
	}

	func loadData() {
		// called on every .onAppear().  if dataLoaded is true, then we have
		// already taken care of setting up the local state variables.
		if !dataHasBeenLoaded {
			// if there is an incoming editable location, offload its
			// values to the state variables
			if let location = editableLocation {
				locationName = location.name!
				visitationOrder = Int(location.visitationOrder)
				red = location.red
				green = location.green
				blue = location.blue
				opacity = location.opacity
			}
						
			// and be sure we don't do this again (!)
			dataHasBeenLoaded = true
		}
	}
}

