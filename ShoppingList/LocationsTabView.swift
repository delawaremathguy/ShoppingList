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
			addNewLocationButtonView(isAddNewLocationSheetShowing: $isAddNewLocationSheetShowing,
																	 managedObjectContext: managedObjectContext)

			// 1a. Report location count, essentially as a section header for just the one section
			HStack {
				Text("Locations Listed: \(locations.count)")
					.font(.caption)
					.italic()
					.foregroundColor(.secondary)
					.padding([.leading], 20)
				Spacer()
			}
			
			// 2. then the list of location
			List {
//				Section(header: MySectionHeaderView(title: "Locations Listed: \(locations.count)")) {
					ForEach(locations) { location in
						NavigationLink(destination: AddorModifyLocationView(editableLocation: location)) {
							LocationRowView(rowData: LocationRowData(location: location))
						}
						.listRowBackground(Color(location.uiColor())) 
					} // end of ForEach
//				} // end of Section
			} // end of List
				//.listStyle(GroupedListStyle())
			
		} // end of VStack
	} // end of var body: some View
	
}

// this is its own View, just to keep the code above a little more readable
struct addNewLocationButtonView: View {
	@Binding var isAddNewLocationSheetShowing: Bool
	var managedObjectContext: NSManagedObjectContext
	
	var body: some View {
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
	}
	
}


struct LocationsView_Previews: PreviewProvider {
	static var previews: some View {
		LocationsTabView()
	}
}
