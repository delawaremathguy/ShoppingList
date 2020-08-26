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
	private var dataHasBeenLoaded = false

	
	init() {
		// sign us up for Location change operations
		NotificationCenter.default.addObserver(self, selector: #selector(locationAdded),
																					 name: .locationAdded, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationEdited),
																					 name: .locationEdited, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationWillBeDeleted),
																					 name: .locationWillBeDeleted, object: nil)
		
		// we also have to watch for deletions of ShoppingItems (see explanation below)
		NotificationCenter.default.addObserver(self, selector: #selector(shoppingItemWillBeDeleted),
																					 name: .shoppingItemWillBeDeleted, object: nil)
		// however, we do not need to watch for shopping items being added or edited here because
		// (1) an addition cannot take place while we are "in the LocationsTabView," and
		// (2) an edit of a shopping item does not affect the display of the LocationsTabView
		
		// THIS BRINGS UP AN INTERESTING SUBTLETY ABOUT A VIEWMODEL. it needs to be aware of any
		// change in the model that affects the view.  it's not just about the array of objects
		// represented, but about ANY aspect of the model that's displayed, even if an object
		// itself has not change.  Core Data clearly illustrates this point: when the Locations tab
		// is chosen, a shopping item can still be edited (tap location -> tap item in list of
		// items at the location -> edit the item), but the LocationsTabView shows no information
		// about specific shopping item data.
		// the situation for deleting an item is different because the LocationsTabView displays
		// the number of items at a location.  that's not an attribute of a Core Data entity; but
		// we are changing the NSSet of shopping items for the location, and so this is, effectively,
		// an edit of the Location because we display the count of the NSSet, and this does change
		// and the View needs to know that.

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

	@objc func shoppingItemWillBeDeleted(_ notification: Notification) {
		// the notification has a reference to a shopping item that will be deleted.
		// the display of this Location indicates the number of items at that Location.  if
		// one of the shopping items at this Location is to be deleted (tap on Location ->
		// tap on item displayed in the list of items -> tap on Delete this Shopping Item),
		// we need the display of all locations in the LocationsTabView
		// to update for the proper number of items at this location.
		
		// note that it's only this special case that's a concern.  if a shopping item
		// is deleted somewhere other than from a View that the LocationsTabView
		// presents, things will get redrawn anyway when we later "tab into" the Locations tab.
		guard let shoppingItem = notification.object as? ShoppingItem else { return }
		if locations.contains(shoppingItem.location!) {
			objectWillChange.send()
		}
	}

	// call this loadItems once the object has been created, to populate the locations
	func loadLocations() {
		if !dataHasBeenLoaded {
			locations = Location.allLocations(userLocationsOnly: false)
			locations.sort(by: <)
			print("locations list loaded. \(locations.count) location.")
			dataHasBeenLoaded = true
		}
	}

	func delete(location: Location) {
		Location.delete(location: location, saveChanges: true)
	}
	
	func updateData(for location: Location?, using editableData: EditableLocationData) {
		// if the incoming item is not nil, then this is just a straight update.
		// otherwise, we must create the new Location here and add it to
		// our list of locations
		
		// if location is nil, it's a signal to add a new item with the packaged data
		if let location = location {
			location.updateValues(from: editableData)
			NotificationCenter.default.post(name: .locationEdited, object: location)
		} else {
			let newLocation = Location.addNewLocation()
			newLocation.updateValues(from: editableData)
			NotificationCenter.default.post(name: .locationAdded, object: newLocation)
		}
		
		Location.saveChanges()
	}

}
