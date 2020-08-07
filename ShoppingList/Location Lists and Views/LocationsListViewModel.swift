//
//  LocationsListViewModel.swift
//  ShoppingList
//
//  Created by Jerry on 7/30/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// a LocationsListViewModel object provides a window into the Code Data store that
// can be used by LocationsTabView.  it provides both data out for the view to consume,
// and handles user intents from the View
// back to Core Data (with notification to the View that the viewModel has changed).

class LocationsListViewModel: ObservableObject {
	
	// the items on our list
	@Published var locations = [Location]()
	
	// quick access to count
	var locationCount: Int { locations.count }
	
	// have we ever been loaded or not
	private var dataHasNotBeenLoaded = true

	
	init() {
		// sign us up for Location change operations
		NotificationCenter.default.addObserver(self, selector: #selector(locationAdded),
																					 name: .locationAdded, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationEdited),
																					 name: .locationEdited, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationWillBeDeleted),
																					 name: .locationWillBeDeleted, object: nil)
	}

	// MARK: - Responses to changes in Location objects
	

	@objc func locationAdded(_ notification: Notification) {
		// the notification has a reference to the location that will be added.
		// if we don't have it, now's the time to add it to the locations array.
		guard let location = notification.object as? Location else { return }
		if !locations.contains(location) {
			locations.append(location)
			locations.sort(by: <)
		}
	}
	
	@objc func locationEdited(_ notification: Notification) {
		// the notification has a reference to the location that was edited.
		// if we're holding on to it, a sort may be necessary.
		guard let location = notification.object as? Location else { return }
		if locations.contains(location) {
			locations.sort(by: <)
		}
	}
	
	@objc func locationWillBeDeleted(_ notification: Notification) {
		// the notification has a reference to the location that will be deleted.
		// if we're holding on to it, now's the time to remove it from the locations array.
		guard let location = notification.object as? Location else { return }
		if locations.contains(location) {
			let index = locations.firstIndex(of: location)!
			locations.remove(at: index)
		}
	}

	// call this loadItems once the object has been created, to populate the locations
	func loadLocations() {
		if dataHasNotBeenLoaded {
			locations = Location.allLocations(userLocationsOnly: false)
			locations.sort(by: <)
			print("locations list loaded. \(locations.count) location.")
			dataHasNotBeenLoaded = false
		}
	}

	func delete(location: Location) {
		NotificationCenter.default.post(name: .locationWillBeDeleted, object: location)
		Location.delete(location: location, saveChanges: true)
	}
	
	func updateDataFor(location: Location?, using editableData: EditableLocationData) {
		// if the incoming item is not nil, then this is just a straight update.
		// otherwise, we must create the new Location here and add it to
		// our list of locations
		
		// if location is nil, it's a signal to add a new item with the packaged data
		guard let location = location else {
			let newLocation = Location.addNewLocation()
			newLocation.updateValues(from: editableData)
			NotificationCenter.default.post(name: .locationAdded, object: newLocation)
			return
		}
		
		// the location is not nil, so it's a normal update
		location.updateValues(from: editableData)
		Location.saveChanges()
		NotificationCenter.default.post(name: .locationEdited, object: location)
	}

}
