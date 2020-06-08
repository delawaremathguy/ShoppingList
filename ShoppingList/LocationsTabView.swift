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
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>
	
	var body: some View {
		VStack {
			
			// first item is an add new location "button."  this will stay at the
			// top of the view, and the list beow will scroll underneath it.
			NavigationLink(destination: AddorModifyLocationView()) {
					Text("Add New Location")
						.padding(10)
				}

			// then the list of items
			List {
				Section(header: Text("Locations Listed: \(locations.count)")) {
					ForEach(locations) { location in
						NavigationLink(destination: AddorModifyLocationView(editableLocation: location)) {
							LocationRowView(location: location)
						} // end of NavigationLink
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
