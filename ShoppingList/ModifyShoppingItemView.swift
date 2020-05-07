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
	//@Binding var shoppingItems: [ShoppingItem]
	@State private var itemName: String = ""
	@State private var itemQuantity: Int = 0
	@State private var selectedLocationIndex: Int = -1
	
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
				Picker(selection: $selectedLocationIndex, label: Text("Choose Location")) {
					ForEach(0 ..< locations.count) {
						Text(self.locations[$0].name!)
					}
				}
			}
			
			// 2
			Section {
				Button("Save") {
					self.commitDataEntry()
				}
				
				//				Button("Delete this Item") {
				//					if let index = self.shoppingItems.firstIndex(of: self.editableItem) {
				//						self.shoppingItems.remove(at: index)
				//						ShoppingItem.delete(item: self.editableItem)
				//						// self.shoppingItems.append(newItem)
//						self.presentationMode.wrappedValue.dismiss()
//					}
//				}

			}
			.onAppear(perform: loadData)
			
		} // end of Form
			.navigationBarTitle("Modify Item", displayMode: .inline)
	}
	
	func loadData() {
		itemName = editableItem.name!
		itemQuantity = Int(editableItem.quantity)
		if let index = locations.firstIndex(where: { $0 == editableItem.location }) {
			selectedLocationIndex = index
		} else {
			selectedLocationIndex = locations.count - 1
		}
	}
	
	func commitDataEntry() {
		editableItem.name = itemName
		editableItem.quantity = Int32(itemQuantity)
		editableItem.location = locations[selectedLocationIndex]
		try? managedObjectContext.save()
		presentationMode.wrappedValue.dismiss()

	}
}
