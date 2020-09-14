//
//  OperationTabView.swift
//  ShoppingList
//
//  Created by Jerry on 6/11/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct DevToolsTabView: View {
	
	// i have made no real effort to pretty-up this View.  it's purely a
	// development hack to load sample data, remove data, and flip a few
	// switches in the code.  this could become a "settings" or "preferences"
	// tab in the future, in which case i would clean it up; although the only
	// thing that might remain is whether the timer is stopped when in the background.
	
	@State private var confirmDeleteAllDataShowing = false
	@State private var confirmDataHasBeenAdded = false
	@State private var locationsAdded: Int = 0
	@State private var shoppingItemsAdded: Int = 0
	@State private var disableTimerWhenAppIsNotActive = kDisableTimerWhenAppIsNotActive

	var body: some View {
		NavigationView {
		VStack(spacing: 20) {
			
			Group {
			Text("These controls are here so that you can add some sample data, play with it, and later delete it.")
				.padding([.leading, .trailing], 10)
			
			Button("Load sample data") {
				let currentLocationCount = Location.count() // what it is now
				let currentShoppingItemCount = ShoppingItem.count() // what it is now
				populateDatabaseFromJSON()
				self.locationsAdded = Location.count() - currentLocationCount // now the differential
				self.shoppingItemsAdded = ShoppingItem.count() - currentShoppingItemCount // now the differential
				self.confirmDataHasBeenAdded = true
			}
			.alert(isPresented: $confirmDataHasBeenAdded) {
				Alert(title: Text("Data Added"),
							message: Text("Sample data for the app (\(locationsAdded) locations and \(shoppingItemsAdded) shopping items) have been added."),
							dismissButton: .default(Text("OK")))
			}
			
			Button("Remove all data") {
				self.confirmDeleteAllDataShowing = true
			}
			.alert(isPresented: $confirmDeleteAllDataShowing) {
				Alert(title: Text("Remove All Data?"),
							message: Text("All application data will be cleared and this cannot be undone. Are you sure you want to delete all data?"),
							primaryButton: .cancel(Text("No")),
							secondaryButton: .destructive(Text("Yes"), action: deleteAllData)
				)
			}
			
			Text("This button lets you offload existing data to JSON. On the simulator, it will dump to files on the Desktop (see Development.swift to get the path right); on a device, it will simply print to the console.")
				.padding([.leading, .trailing], 10)

			Button("Write database as JSON") {
				writeAsJSON(items: ShoppingItem.allShoppingItems(), to: kShoppingItemsFilename)
				writeAsJSON(items: Location.allLocations(userLocationsOnly: true), to: kLocationsFilename)
			}
			} // end of Group
			
			Text("To see the difference between the single-section or multi-section versions of the Shopping List, just tap the tray or double-tray icon at the top, left of the shopping list.")
				.italic()
				.foregroundColor(.secondary)
				.padding([.leading, .trailing], 10)

			HStack(spacing: 5) {
				Text("Suspend timer in background: ") + Text(disableTimerWhenAppIsNotActive ? "Yes" : "No").bold()
				Button("Change") {
					// it's a little silly to do this: keep a local @State variable synced up with a global,
					// but this View needs a @State variable so it knows when to redraw the Yes/No text
					// and changing only the global won't make that happen.  things could be a little cleaner.
					// but hey, this is a Dev Tools hack screen!
					self.disableTimerWhenAppIsNotActive.toggle()
					kDisableTimerWhenAppIsNotActive.toggle()
				}
			}

			Spacer()

			Text("This tab view can be hidden if you wish (see Development.swift)")
				.padding([.leading, .trailing, .bottom], 10)

			
		} // end of VStack
			.navigationBarTitle("Dev Tools")
		} // end of NavigationView
			.onAppear { print("DevToolsTabView appear") }
			.onDisappear { print("DevToolsTabView disappear") }
	} // end of body
	
}

