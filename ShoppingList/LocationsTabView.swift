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
	
	// support for context menu deletion
	@State private var locationToDelete: Location?
	@State private var showDeleteConfirmation = false
	
	var body: some View {
		NavigationView {
		VStack(spacing: 0) {
			
			// 1. add new item "button" is at top.  note that this will put up the AddorModifyLocationView
			// inside its own NaviagtionView (so the Picker will work!) and we must pass along the
			// managedObjectContext manually because sheets don't automatically inherit the environment
			addNewLocationButtonView(isAddNewLocationSheetShowing: $isAddNewLocationSheetShowing,
																	 managedObjectContext: managedObjectContext)

			// 1a. Report location count, essentially as a section header for just the one section
			SLSimpleHeaderView(label: "Locations Listed: \(locations.count)")
			
			// 2. then the list of location
			List {
				ForEach(locations) { location in
					NavigationLink(destination: AddorModifyLocationView(editableLocation: location)) {
						LocationRowView(rowData: LocationRowData(location: location))
							.contextMenu {
								Button(action: {
									if !location.isUnknownLocation() {
										self.locationToDelete = location
										self.showDeleteConfirmation = true
									}
								}) {
									Text("Delete This Location")
									Image(systemName: "trash")
								}
						}
					}
					.listRowBackground(Color(location.uiColor()))
				} // end of ForEach
					.alert(isPresented: $showDeleteConfirmation) {
						Alert(title: Text("Delete \'\(locationToDelete!.name!)\'?"),
									message: Text("Are you sure you want to delete this location?"),
									primaryButton: .cancel(Text("No")),
									secondaryButton: .destructive(Text("Yes"), action: self.deleteLocation)
						)}
			} // end of List
			
		} // end of VStack
			.navigationBarTitle("Locations")
			.navigationBarItems(
				trailing:
				Button(action: { self.isAddNewLocationSheetShowing = true }) {
					Image(systemName: "plus")
						.resizable()
						.frame(width: 16, height: 16)
			})

		} // end of NavigationView
	} // end of var body: some View
	
	func deleteLocation() {
		if let location = locationToDelete {
			Location.delete(location: location, saveChanges: true)
		}
	}

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
