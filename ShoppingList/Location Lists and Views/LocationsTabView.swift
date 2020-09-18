//
//  LocationsView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct LocationsTabView: View {
	
	@ObservedObject var viewModel = LocationsListViewModel()
	
	@State private var isAddNewLocationSheetShowing = false
	
	// support for context menu deletion
	@State private var locationToDelete: Location?
	@State private var showDeleteConfirmation = false
	
	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				
				// 1. add new location "button" is at top.  note that this will put up the AddorModifyLocationView
				// inside its own NaviagtionView (so the Picker will work!) and we must pass along the
				// viewModel to really accomplish any change
				Button(action: { self.isAddNewLocationSheetShowing = true }) {
					Text("Add New Location")
						.foregroundColor(Color.blue)
						.padding(10)
				}
					
				.sheet(isPresented: $isAddNewLocationSheetShowing) {
					NavigationView {
						AddorModifyLocationView(viewModel: self.viewModel)
					}
				}
				
				// 1a. Report location count, essentially as a section header for just the one section
				SLSimpleHeaderView(label: "Locations Listed: \(viewModel.locationCount)")
				
				// 2. then the list of locations
				List {
					ForEach(viewModel.locations) { location in
						NavigationLink(destination: AddorModifyLocationView(viewModel: self.viewModel, at: location)) {
							LocationRowView(rowData: LocationRowData(location: location))
								.contextMenu {
									Button(action: {
										if !location.isUnknownLocation() {
											self.locationToDelete = location
											self.showDeleteConfirmation = true
										}
									}) {
										Text(location.isUnknownLocation() ? "(Cannot be deleted)" : "Delete This Location")
										Image(systemName: location.isUnknownLocation() ? "trash.slash" : "trash")
									}
							}
						}
						//.listRowBackground(Color(location.uiColor()))
					} // end of ForEach
						.alert(isPresented: $showDeleteConfirmation) {
							Alert(title: Text("Delete \'\(locationToDelete!.name!)\'?"),
										message: Text("Are you sure you want to delete this location?"),
										primaryButton: .cancel(Text("No")),
										secondaryButton: .destructive(Text("Yes"), action: deleteSelectedLocation)
							)}
				} // end of List
				.listStyle(PlainListStyle())

			} // end of VStack
				.navigationBarTitle("Locations")
				.navigationBarItems(
					trailing:
					Button(action: { self.isAddNewLocationSheetShowing = true }) {
						Image(systemName: "plus")
							.resizable()
							.frame(width: 20, height: 20)
				})
				.onAppear {
					print("LocationsTabView appear")
					self.viewModel.loadLocations()
				}
			
		} // end of NavigationView
			.onDisappear { print("LocationsTabView disappear") }
	} // end of var body: some View
	
	
	func deleteSelectedLocation() {
		if let location = locationToDelete {
			viewModel.delete(location: location)
		}
	}
		
}
