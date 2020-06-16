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
	
    var body: some View {
			VStack(spacing: 20) {
				
				Text("These controls are here so that you can add some sample data, play with it, and later delete it.  This tab view can be hidden if you wish (see Development.swift)")
					.padding(.horizontal)
				
				Button("Load sample data") {
					populateDatabaseFromJSON()
					self.confirmDataHasBeenAdded = true
				}
				.alert(isPresented: $confirmDataHasBeenAdded) {
					Alert(title: Text("Data Added"), message: Text("Sample data for the app has been added."),
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
				
				Spacer()
				
			}

	}
	
}

struct OperationTabView_Previews: PreviewProvider {
    static var previews: some View {
        DevToolsTabView()
    }
}
