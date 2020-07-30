//
//  LocationsListViewModel.swift
//  ShoppingList
//
//  Created by Jerry on 7/30/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// a LocationsListViewModel object provides a window into the Code Data store that
// can be used by LocationsTabView.
// it provides both data out for the view to consume, and handles user intents from the View
// back to Core Data (with notification to the View that the viewModel has changed).

class LocationsListViewModel: ObservableObject {
	
	// the items on our list
	@Published var locations = [Location]()
	
	// quick access to count
	var locationCount: Int { locations.count }
	
	// call this loadItems once the object has been created, to populate the locations
	func loadLocations() {
		locations = Location.allLocations(userLocationsOnly: false)
		locations.sort(by: <)
		print("locations list loaded. \(locations.count) location.")
	}

	func delete(location: Location) {
		let index = locations.firstIndex(of: location)!
		locations.remove(at: index)
		// the Location class takes care of moving items in this location
		// over to the unknown location.
		Location.delete(location: location, saveChanges: true)
	}
	
	func updateDataFor(location: Location?, using editableData: EditableLocationData) {
		// if the incoming item is not nil, then this is just a straight update.
		// otherwise, we must create the new Location here and add it to
		// our list of locations
		
		// if we already have an editableItem, use it, else create it now and add to locations
		var itemForCommit: Location
		if let itemBeingEdited = location {
			itemForCommit = itemBeingEdited
		} else {
			itemForCommit = Location.addNewLocation()
			locations.append(itemForCommit)
		}

		// apply the update
		itemForCommit.updateValues(from: editableData) // an extension on Location
		
		// the order of items is likely affected, either because of a new object
		// being added, or a name/location change affects the sort order.
		// this will trigger the @Published notification
		locations.sort(by: <)
	}

}
