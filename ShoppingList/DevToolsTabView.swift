//
//  OperationTabView.swift
//  ShoppingList
//
//  Created by Jerry on 6/11/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct DevToolsTabView: View {
	
	@State private var confirmDeleteAllDataShowing = false
	@State private var confirmDataHasBeenAdded = false
	@State private var locationsAdded: Int = 0
	@State private var shoppingItemsAdded: Int = 0
	@State private var multiSectionShoppingListDisplay = kShowMultiSectionShoppingList
	
    var body: some View {
			VStack(spacing: 20) {
				
				Text("These controls are here so that you can add some sample data, play with it, and later delete it.  This tab view can be hidden if you wish (see Development.swift)")
					.padding(.horizontal)
				
				Button("Load sample data") {
					self.locationsAdded = Location.count() // what it is now
					self.shoppingItemsAdded = ShoppingItem.count() // what it is now
					populateDatabaseFromJSON()
					self.locationsAdded = Location.count() - self.locationsAdded // now the differential
					self.shoppingItemsAdded = ShoppingItem.count() - self.shoppingItemsAdded // now the differential
					self.confirmDataHasBeenAdded = true
				}
				.alert(isPresented: $confirmDataHasBeenAdded) {
					Alert(title: Text("Data Added"), message: Text("Sample data for the app (\(locationsAdded) locations and \(shoppingItemsAdded) shopping items) have been added."),
								dismissButton: .default(Text("OK")))
				}

				Button("Remove all data") {
					self.confirmDeleteAllDataShowing = true
				}
				.alert(isPresented: $confirmDeleteAllDataShowing) {
					Alert(title: Text("Remove All Data?"), message: Text("All application data will be cleared and this cannot be undone. Are you sure you want to delete all data?"),
								primaryButton: .cancel(Text("No")),
								secondaryButton: .destructive(Text("Yes"), action: { deleteAllData() }))
				}

				
				Button("Write database as JSON") {
					writeAsJSON(items: ShoppingItem.allShoppingItems(), to: kShoppingItemsFilename)
					writeAsJSON(items: Location.allUserLocations(), to: kLocationsFilename)
				}
				
				VStack(spacing: 3) {
					Text("Shopping list display is: ") + Text(multiSectionShoppingListDisplay ? "Multi-Section" : "Single Section")
					Button(changeDisplayButtonName()) {
						self.multiSectionShoppingListDisplay.toggle()
						kShowMultiSectionShoppingList.toggle()
					}
				}

				Spacer()
				
			}

	}
	
	func changeDisplayButtonName() -> String {
		if multiSectionShoppingListDisplay {
			return "Change to single section display"
		}
		return "Change to multiple section display"
	}
	
}

struct OperationTabView_Previews: PreviewProvider {
    static var previews: some View {
        DevToolsTabView()
    }
}
