//
//  LocationsView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

struct LocationsTabView: View {
	// CoreData setup
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>
	@State private var isAddNewLocationSheetShowing = false
	
	var body: some View {
		VStack {
			
			// 1. add new item "button" is at top.  note that this will put up the AddorModifyLocationView
			// inside its own NaviagtionView (so the Picker will work!) and we must pass along the
			// managedObjectContext manually because sheets don't automatically inherit the environment
			Button(action: { self.isAddNewLocationSheetShowing = true }) {
				Text("Add New Location")
					.foregroundColor(Color.blue)
					.padding(10)
			}
			.sheet(isPresented: $isAddNewLocationSheetShowing) {
				NavigationView {
					AddorModifyLocationView()
						.environment(\.managedObjectContext, self.managedObjectContext)
				}
			}

			// 2. then the list of items
			List {
				Section(header: MySectionHeaderView(title: "Locations Listed: \(locations.count)")) {
					ForEach(locations) { location in
						NavigationLink(destination: AddorModifyLocationView(editableLocation: location)) {
							LocationRowView(rowData: LocationRowData(location: location))
						}
						.listRowBackground(self.textColor(for: location))
					} // end of ForEach
				} // end of Section
			} // end of List
				.listStyle(GroupedListStyle())
			
		} // end of VStack
	}
	
	func textColor(for location: Location) -> Color {
		return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
	}
	
}

struct LocationsView_Previews: PreviewProvider {
	static var previews: some View {
		LocationsTabView()
	}
}
