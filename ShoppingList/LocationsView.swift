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
	@Environment(\.managedObjectContext) var managedObjectContext
	
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>
	@State private var performJSONOutputDumpOnAppear = false // change to true to dump locations list as JSON onAppear()
	
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
//									.foregroundColor(self.textColor(for: location))
									.font(.headline)
								if location.visitationOrder != kUnknownLocationVisitationOrder {
									Spacer()
									Text(String(location.visitationOrder))
								}
							}
						}
						// .disabled(location.visitationOrder == kUnknownLocationVisitationOrder)
						.listRowBackground(self.textColor(for: location))
					}
				}
			}
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
				print("Locations saved.")
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
