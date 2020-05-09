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
//	@State private var itemLocationIndex: Int
//	@Binding var shoppingItems: [ShoppingItem]
	@State private var locationNames = [String]()
	@State private var selectedLocationIndex: Int = 0
	
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
			.onAppear(perform: loadData)
	}
	
	func commitTextEntry() {
		let newItem = ShoppingItem.addNewItem(name: itemName, location: locations[selectedLocationIndex])
		newItem.quantity = Int32(itemQuantity)
		let location = locations[selectedLocationIndex]
		newItem.location = location
		newItem.visitationOrder = location.visitationOrder
		try? managedObjectContext.save()
		presentationMode.wrappedValue.dismiss()
	}

	func loadData() {
		locationNames = locations.map() { $0.name! }
		selectedLocationIndex = locationNames.count - 1
	}
	
}


