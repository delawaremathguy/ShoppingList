//
//  LocationsView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct LocationsView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>
	
	var body: some View {
		
		NavigationView {
			VStack {
				
				
				List {
					NavigationLink(destination: AddLocationView()) {
					HStack {
						Spacer()
						Text("Add New Location")
							.foregroundColor(Color.blue)
						Spacer()
					}
					}
					
					ForEach(locations) { location in
						NavigationLink(destination: ModifyLocationView(location: location)) {
							HStack {
								Text(location.name!)
									.font(.headline)
								if location.visitationOrder != kUnknownLocationVisitationOrder {
									Spacer()
									Text(String(location.visitationOrder))
								}
							}
						}
					.disabled(location.visitationOrder == kUnknownLocationVisitationOrder)
					}
				}
			}
			.navigationBarTitle(Text("Locations"))
		}
	}
}

struct LocationsView_Previews: PreviewProvider {
	static var previews: some View {
		LocationsView()
	}
}
