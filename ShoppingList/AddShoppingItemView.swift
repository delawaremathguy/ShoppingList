//
//  AddShoppingItemView.swift
//  ShoppingList
//
//  Created by Jerry on 4/23/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct AddShoppingItemView: View {
	@Environment(\.presentationMode) var presentationMode
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>

	@State private var itemName: String = ""
	@State private var itemQuantity: Int  = 1
//	@State private var itemLocationIndex: Int
//	@Binding var shoppingItems: [ShoppingItem]
	@State private var locationNames = [String]()
	@State private var selectedLocationIndex: Int = 0
	
	var body: some View {
		Form {
			// 1: Name and Quantity
			Section {
				TextField("Item name", text: $itemName, onCommit: commitTextEntry)
				Stepper("Quantity",
								onIncrement: { self.itemQuantity += 1 },
								onDecrement: { self.itemQuantity -= 1 })
//				Picker("Location", selection: <#T##Binding<_>#>, content: <#T##() -> _#>)
			}
			
			// 2
			Section {
				Button("Save") {
					self.commitTextEntry()
				}
			}
			
		} // end of Form
			.navigationBarTitle("Add New Item", displayMode: .inline)
			.onAppear(perform: loadData)
	}
	
	func commitTextEntry() {
		let _ = ShoppingItem.addNewItem(name: itemName, location: locations[selectedLocationIndex])
//		shoppingItems.append(newItem)
		presentationMode.wrappedValue.dismiss()
	}

	func loadData() {
		locationNames = locations.map() { $0.name! }
		selectedLocationIndex = locationNames.count - 1
	}
	
}


