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
		List {
			
			// first item is an add new location "button"
			NavigationLink(destination: AddorModifyLocationView()) {
				HStack {
					Spacer()
					Text("Add New Location")
						.foregroundColor(Color.blue)
					Spacer()
				}
			}
			
			// then come all the locations
			Section(header: Text("Location Listed: \(locations.count)")) {
				ForEach(locations, id:\.self) { location in
					NavigationLink(destination: AddorModifyLocationView(editableLocation: location)) {
						HStack {
							VStack(alignment: .leading) {
								Text(location.name!)
									.font(.headline)
								Text("\(location.items!.count) items")
									.font(.caption)
							}
							if location.visitationOrder != kUnknownLocationVisitationOrder {
								Spacer()
								Text(String(location.visitationOrder))
							}
						}
					} // end of NavigationLink
						.listRowBackground(self.textColor(for: location))
				} // end of ForEach
			} // end of Section
			
		} // end of List
			.listStyle(GroupedListStyle())
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
