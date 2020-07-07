//
//  addNewShoppingItemButtonView.swift
//  ShoppingList
//
//  Created by Jerry on 7/7/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

struct AddNewShoppingItemButtonView: View {
	@Binding var isAddNewItemSheetShowing: Bool
	var managedObjectContext: NSManagedObjectContext
	var addItemToShoppingList = true
	
	var body: some View {
		Button(action: { self.isAddNewItemSheetShowing = true }) {
			Text("Add New Item")
				.foregroundColor(Color.blue)
				.padding(10)
		}
		.sheet(isPresented: $isAddNewItemSheetShowing) {
			NavigationView {
				AddorModifyShoppingItemView(allowsDeletion: false, addItemToShoppingList: self.addItemToShoppingList)
					.environment(\.managedObjectContext, self.managedObjectContext)
			}
		}
	}
	
}

//struct addNewShoppingItemButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        addNewShoppingItemButtonView()
//    }
//}
