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
	@State private var itemName: String = ""
	@Binding var shoppingItems: [ShoppingItem]
	var saveItemOrderFunction: (() -> ())
	
	var body: some View {
		Form {
			// 1
			Section {
				TextField("Item name", text: $itemName, onCommit: commitTextEntry)
			}
			
			// 2
			Section {
				Button("Save") {
					self.commitTextEntry()
				}
			}
			
		} // end of Form
			.navigationBarTitle("Add New Item", displayMode: .inline)
	}
	
	func commitTextEntry() {
		let newItem = ShoppingItem.addNewItem(name: itemName)
		shoppingItems.append(newItem)
		saveItemOrderFunction()
		presentationMode.wrappedValue.dismiss()
	}

	
}


