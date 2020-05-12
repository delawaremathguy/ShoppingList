//
//  ModifyShoppingItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/3/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct ModifyShoppingItemView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.presentationMode) var presentationMode
	@ObservedObject var editableItem: ShoppingItem
	@State private var itemName: String = ""
	@State private var itemQuantity: Int = 0
	@State private var selectedLocationIndex: Int = -1 // signifies @State vars not yet set up
	
	// we need access to the complete list of Locations to populate
	// the picker
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>

	
	var body: some View {
		Form {
			// 1
			Section {
				TextField("Item name", text: $itemName, onCommit: { self.commitDataEntry() })
				Stepper(value: $itemQuantity, in: 1...10) {
					Text("Quantity: \(itemQuantity)")
				}
				Picker(selection: $selectedLocationIndex, label: Text("Location")) {
					ForEach(0 ..< locations.count) { index in
						Text(self.locations[index].name!)
					}
				}
			}
			
			// 2
			Section {
				Button("Save") {
					self.commitDataEntry()
				}
				
				HStack {
					Spacer()
					Button("Delete This Shopping Item") {
						self.deleteItem()
					}
					.foregroundColor(Color.red)
					Spacer()
				}

			}
			.onAppear(perform: initializeDataIfNecessary)
			
		} // end of Form
			.navigationBarTitle("Modify Item", displayMode: .inline)
	}
	
	func initializeDataIfNecessary() {
		// called on every .onAppear().  if selectedLocationIndex is -1, that means we
		// opened up with editableItem set, but the properties we might change have
		// not yet been moved out to the @State variables.  do that now.
		if selectedLocationIndex == -1 {
			itemName = editableItem.name!
			itemQuantity = Int(editableItem.quantity)
			let locationNames = locations.map() { $0.name! }
			if let index = locationNames.firstIndex(of: editableItem.location!.name!) {
				selectedLocationIndex = index
			} else {
				selectedLocationIndex = locations.count - 1 // index of Unknown Location
			}
		}
	}
	
	func commitDataEntry() {
		editableItem.name = itemName
		editableItem.quantity = Int32(itemQuantity)
		// futz a little here to remove old location from this item and then
		// in stall the new location, if this changed
		let newLocation = locations[selectedLocationIndex]
		if newLocation != editableItem.location {
			editableItem.location?.removeFromItems(editableItem)
			editableItem.location = newLocation
			editableItem.visitationOrder = newLocation.visitationOrder
		}
		try? managedObjectContext.save()
		presentationMode.wrappedValue.dismiss()

	}
	
	func deleteItem() {
		// remove reference in locations
		let location = editableItem.location
		location?.removeFromItems(editableItem)
		managedObjectContext.delete(editableItem)
		try? managedObjectContext.save()
	}
}
