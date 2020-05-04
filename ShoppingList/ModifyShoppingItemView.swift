//
//  ModifyShoppingItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/3/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct ModifyShoppingItemView: View {
	@Environment(\.presentationMode) var presentationMode
	var editableItem: ShoppingItem
	@Binding var shoppingItems: [ShoppingItem]
	@State private var itemName: String = ""
	
	var body: some View {
		Form {
			// 1
			Section {
				TextField("Item name", text: $itemName, onCommit: { self.commitTextEntry() })
			}
			
			// 2
			Section {
				Button("Save") {
					self.commitTextEntry()
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
	}
	
	func loadData() {
		itemName = editableItem.name!
	}
	
	func commitTextEntry() {
		editableItem.name = itemName
		if let index = self.shoppingItems.firstIndex(of: editableItem) {
			shoppingItems[index].name = itemName
		}
		presentationMode.wrappedValue.dismiss()

	}
}
