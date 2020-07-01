//
//  ModifyLocationView.swift
//  ShoppingList
//
//  Created by Jerry on 5/7/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// *** see more detailed comments about the use of this
// struct over in AddOrModifyShoppingItemView

struct EditableLocationData {
	// all of the values here provide suitable defaults for a new Location
	var locationName: String = ""
	var visitationOrder: Int = 50
	var red: Double = 0.25
	var green: Double = 0.25
	var blue: Double = 0.25
	var opacity: Double = 0.40

	// this copies all the editable data from an incoming Location
	init(location: Location) {
		locationName = location.name!
		visitationOrder = Int(location.visitationOrder)
		red = location.red
		green = location.green
		blue = location.blue
		opacity = location.opacity
	}
	
	// provides simple, default init with values specified above
	init() { }
	
}

// MARK: - View Definition

struct AddorModifyLocationView: View {
	@Environment(\.presentationMode) var presentationMode
	
	// editableLocation is either a Location to edit, or nil to signify
	// that we're creating a new Location in this View.
	var editableLocation: Location? = nil
	
	// all editableData is packaged here:
	@State private var editableData = EditableLocationData()
	
	// this indicates dataHasBeenLoaded from an incoming editableLocation
	// it will be flipped to true once .onAppear() has been called
	@State private var dataHasBeenLoaded = false
	
	// showDeleteConfirmation controls whether an Alert will appear
	// to confirm deletion of a Location
	@State private var showDeleteConfirmation: Bool = false
	
	var body: some View {
		Form {
			// 1: Name, Visitation Order, Colors
			Section(header: MySectionHeaderView(title: "Basic Information")) {
				HStack {
					SLFormLabelText(labelText: "Name: ")
					TextField("Location name", text: $editableData.locationName)
				}
				
				if editableData.visitationOrder != kUnknownLocationVisitationOrder {
					Stepper(value: $editableData.visitationOrder, in: 1...100) {
						HStack {
							SLFormLabelText(labelText: "Visitation Order: ")
							Text("\(editableData.visitationOrder)")
						}
					}
				}

				HStack {
					SLFormLabelText(labelText: "Composite Color: ")
					Spacer()
					Capsule()
						.fill(rgbColor())
						.frame(width: 200)
						.overlay(Capsule().stroke(Color.black, lineWidth: 1))
				}

				SLSliderControl(title: "Red: ", amount: $editableData.red)
				SLSliderControl(title: "Green: ", amount: $editableData.green)
				SLSliderControl(title: "Blue: ", amount: $editableData.blue)
				SLSliderControl(title: "Opacity: ", amount: $editableData.opacity)

			} // end of Section 1
			
			// Section 2: Delete button, if present
			if editableData.visitationOrder != kUnknownLocationVisitationOrder && editableLocation != nil {
				Section(header: MySectionHeaderView(title: "Location Management")) {
					SLCenteredButton(title: "Delete This Location", action: { self.showDeleteConfirmation = true })
						.foregroundColor(Color.red)
				}
			}  // end of Section 2
			
			// Section 3: Items assigned to this Location, if we are editing a Location
			if editableLocation != nil {
				Section(header: MySectionHeaderView(title: "At this Location: \(editableLocation?.items?.count ?? 0) items")) {
					ForEach(itemsArray(at: editableLocation)) { item in
						NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item, allowsDeletion: false)) {
							Text(item.name!)
						}
					}
				} // end of Section 3
			}
			
		} // end of Form
			.onAppear(perform: loadData)
			.navigationBarTitle(barTitle(), displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(
				leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }){
					Text("Cancel")
				},
				trailing: Button(action: { self.commitData() }){
					Text("Save")
			})
			.alert(isPresented: $showDeleteConfirmation) {
				Alert(title: Text("Delete \'\(editableLocation!.name!)\'?"),
							message: Text("Are you sure you want to delete this location?"),
							primaryButton: .cancel(Text("No")),
							secondaryButton: .destructive(Text("Yes"), action: self.deleteLocation)
				)}
	}
	
	func rgbColor() -> Color {
		Color(.sRGB, red: editableData.red, green: editableData.green, blue: editableData.blue, opacity: editableData.opacity)
	}
	
	func barTitle() -> Text {
		return editableLocation == nil ? Text("Add New Location") : Text("Modify Location")
	}
	
	func deleteLocation() {
		if let location = editableLocation {
			presentationMode.wrappedValue.dismiss()
			Location.delete(location: location, saveChanges: true)
		}
	}

	func commitData() {
		// do we have an editableLocation or should we create a new Location?
		var locationForCommit: Location
		if let location = editableLocation {
			locationForCommit = location
		} else {
			locationForCommit = Location.addNewLocation()
		}
		
		// copy edited data, save, and we're done
		locationForCommit.updateValues(from: editableData)
		Location.saveChanges()
		presentationMode.wrappedValue.dismiss()
	}

	func loadData() {
		// called on every .onAppear().  if dataLoaded is true, then we have
		// already taken care of setting up the local state variables.
		if !dataHasBeenLoaded {
			if let location = editableLocation {
				editableData = EditableLocationData(location: location)
			} // else we already have default, editable data set up right
			dataHasBeenLoaded = true
		}
	}
	
	func itemsArray(at location: Location?) -> [ShoppingItem] {
		// note: we could add a sorted parameter, here, to indicated whether
		// the array returned should be sorted, but it's not worth the
		// extra code to turn a Set into an Array for the non-sorted case.
		// besides, the list of items in a Location is usually quite short.
		if let shoppingItems = location?.items as? Set<ShoppingItem> {
			return shoppingItems.sorted(by: { $0.name! < $1.name! })
		}
		return [ShoppingItem]()
	}
}

// MARK: - ShoppingItem Convenience Extension

extension Location {
	
	func updateValues(from editableData: EditableLocationData) {
		name = editableData.locationName
		visitationOrder = Int32(editableData.visitationOrder)
		red = editableData.red
		green = editableData.green
		blue = editableData.blue
		opacity = editableData.opacity
		
		// make sure all shopping items at this location have the
		// updated visitation information
		if let items = items as? Set<ShoppingItem> {
			for item in items {
				item.visitationOrder = visitationOrder
			}
		}
	}
}
