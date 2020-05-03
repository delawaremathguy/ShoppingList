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
	
	var body: some View {
		Form {
			// 1
			Section {
				TextField("Item name", text: $itemName)
			}
			
			// 2
			Section {
				Button("Save") {
					let newItem = ShoppingItem.addNewItem(name: self.itemName)
					self.shoppingItems.append(newItem)
					self.presentationMode.wrappedValue.dismiss()
				}
			}
			
		} // end of Form
			.navigationBarTitle("Add Book")
	}
	
}


