//
//  AddShoppingItemView.swift
//  ShoppingList
//
//  Created by Jerry on 4/23/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct AddShoppingItemView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.presentationMode) var presentationMode
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>

	@State private var itemName: String = ""
	@State private var itemQuantity: Int = 1
	@State private var locationNames = [String]()
	@State private var selectedLocationIndex: Int = -1 // signifies @State not set up yet
	var placeOnShoppingList: Bool  = true // assume we want new items on shopping list
	
	var body: some View {
		Form {
			// 1: Name, Quantity, and location
			Section {
				TextField("Item name", text: $itemName, onCommit: commitTextEntry)
				Stepper(value: $itemQuantity, in: 1...100) {
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
					self.commitTextEntry()
				}
				.disabled(itemName.count == 0)
			}
			
		} // end of Form
			.navigationBarTitle("Add New Item", displayMode: .inline)
			.onAppear(perform: initializeDataIfNecessary)
	}
	
	func commitTextEntry() {
		//print(selectedLocationIndex)
		// adds basic info for new shopping item
		let newItem = ShoppingItem.addNewItem()  // (name: itemName, quantity: itemQuantity)
		newItem.name = itemName
		newItem.quantity = Int32(itemQuantity)
		newItem.onList = placeOnShoppingList
		let location = locations[selectedLocationIndex]
		// then links to intended location
		newItem.setLocation(location: location)
		try? managedObjectContext.save()
		presentationMode.wrappedValue.dismiss()
	}

	func initializeDataIfNecessary() {
		if selectedLocationIndex == -1 {
			locationNames = locations.map() { $0.name! }
			selectedLocationIndex = locationNames.count - 1
		}
	}
	
}


