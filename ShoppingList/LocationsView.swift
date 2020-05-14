//
//  LocationsView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

struct LocationsView: View {
	// CoreData setup
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>
	
	// local used to dump location data as JSON in .onAppear() if global flag says to do it
	@State private var performJSONOutputDumpOnAppear = kPerformJSONOutputDumpOnAppear
	
	var body: some View {
		
		NavigationView {
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
					ForEach(locations) { location in
						NavigationLink(destination: AddorModifyLocationView(editableLocation: location)) {
							HStack {
								Text(location.name!)
										.font(.headline)
								if location.visitationOrder != kUnknownLocationVisitationOrder {
									Spacer()
									Text(String(location.visitationOrder))
								}
							}
						} // end of NavigationLink
							.listRowBackground(self.textColor(for: location))
					} // end of ForEach
					
				} // end of List
			.navigationBarTitle(Text("Locations"))
		}
		.onAppear(perform: loadData)
	}
	
	func loadData() {
		//print(".onAppear in LocationsView")
		if performJSONOutputDumpOnAppear {
			let filepath = "/Users/keough/Desktop/locations.json"
			let jsonLocationList = locations.map() { LocationJSON(from: $0) }
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			do {
				let data = try encoder.encode(jsonLocationList)
				try data.write(to: URL(fileURLWithPath: filepath))
				print("Locations dumped as JSON.")
			} catch let error as NSError {
				print("Error: \(error.localizedDescription), \(error.userInfo)")
			}
			performJSONOutputDumpOnAppear = false
		}
		
	}
	
	func textColor(for location: Location) -> Color {
		return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
	}

	
}

struct LocationsView_Previews: PreviewProvider {
	static var previews: some View {
		LocationsView()
	}
}
