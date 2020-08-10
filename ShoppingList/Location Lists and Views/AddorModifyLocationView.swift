//
//  ModifyLocationView.swift
//  ShoppingList
//
//  Created by Jerry on 5/7/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// MARK: - View Definition

struct AddorModifyLocationView: View {
	@Environment(\.presentationMode) var presentationMode
	
	// editableLocation is either a Location to edit, or nil to signify
	// that we're creating a new Location in for the viewModel.
	var editableLocation: Location?
	var viewModel: LocationsListViewModel
	
	// we use a specialized form of a ShoppingListViewModel in this View to
	// drive the list of items at this location.  it must be an observed object
	// so that if move over to the AddorModifyShoppingItemView, we can track
	// edits back here, especially if we either change the object's location
	// or delete the object.
	@ObservedObject var shoppingItemsViewModel: ShoppingListViewModel //(type: .locationSpecificShoppingList)
	
	// all editableData is packaged here:
	@State private var editableData = EditableLocationData()
	
	// this indicates dataHasBeenLoaded from an incoming editableLocation
	// it will be flipped to true once .onAppear() has been called
	@State private var dataHasBeenLoaded = false
	
	// showDeleteConfirmation controls whether an Alert will appear
	// to confirm deletion of a Location
	@State private var showDeleteConfirmation: Bool = false
	
	// we use an init, so the ShoppingListViewModel for the shopping items at this
	// locations gets initialized properly with the location as associated data for
	// the type locationSpecificShoppingList
	init(viewModel: LocationsListViewModel, at location: Location? = nil) {
		self.viewModel = viewModel
		self.editableLocation = location
		shoppingItemsViewModel = ShoppingListViewModel(type: .locationSpecificShoppingList(location))
	}
	
	var body: some View {
		Form {
			// 1: Name, Visitation Order, Colors
			Section(header: SLSectionHeaderView(title: "Basic Information")) {
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
			
			// Section 2: Delete button, if present (must be editing a user location)
			if editableLocation != nil && editableData.visitationOrder != kUnknownLocationVisitationOrder  {
				Section(header: SLSectionHeaderView(title: "Location Management")) {
					SLCenteredButton(title: "Delete This Location", action: { self.showDeleteConfirmation = true })
						.foregroundColor(Color.red)
				}
			}  // end of Section 2
			
			// Section 3: Items assigned to this Location, if we are editing a Location
			if editableLocation != nil {
				Section(header: SLSectionHeaderView(title: "At this Location: \(editableLocation?.items?.count ?? 0) items")) {
					ForEach(shoppingItemsViewModel.items) { item in
						NavigationLink(destination: AddorModifyShoppingItemView(viewModel: self.shoppingItemsViewModel, editableItem: item)) {
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
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { // seems to want more time in simulator
				self.viewModel.delete(location: location)
			}
		}
	}

	func commitData() {
		presentationMode.wrappedValue.dismiss()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.viewModel.updateData(for: self.editableLocation, using: self.editableData)
		}
	}

	func loadData() {
		// called on every .onAppear().  if dataHasBeenLoaded is true, then we have
		// already taken care of setting up the local state variables.
		if !dataHasBeenLoaded {
			if let location = editableLocation {
				editableData = EditableLocationData(location: location)
				shoppingItemsViewModel.loadItems()
			} // else we already have default, editable data set up right
			dataHasBeenLoaded = true
		}
	}
	
}

