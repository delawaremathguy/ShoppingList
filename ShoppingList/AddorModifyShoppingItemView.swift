//
//  ModifyShoppingItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/3/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct AddorModifyShoppingItemView: View {
	@Environment(\.presentationMode) var presentationMode


	// editableItem is either a ShoppingItem to edit, or nil to signify
	// that we're creating a new ShoppingItem in this View.
	var editableItem: ShoppingItem? = nil
	// addItemToShoppingList just means that if we are adding a new item
	// (editableItem == nil), this tells us whether to put it on the shopping
	// list or not.  the default is true: a new item goes on the shopping list.
	// however, if inserting a new item from the Purchased list,
	// this will be set to false at entry to mean "put the new item on
	// the Purchased list," which the user can override if they wish.  so
	var addItemToShoppingList: Bool = true
	
	// all of these @State values are suitable defaults for a new ShoppingItem
	// so if editableItem is nil, the values below are the right default values
	// but note, loadData() will tweak the onList default value to false if called from
	// the purchased list for adding a new item
	//
	// but if editableItem is not nil, all of these will be updated in loadData()
	@State private var itemName: String = "" // these are suitable defaults for a new shopping item
	@State private var itemQuantity: Int = 1
	@State private var selectedLocationIndex: Int = 0 // but this one's not right; we'll fix in loadData()
	@State private var onList: Bool = true
	@State private var isAvailable = true
	
	// this indicates dataHasBeenLoaded from an incoming editableItem
	// it will be flipped to true once .onAppear() has been called
	@State private var dataLoaded = false
	
	// showDeleteConfirmation controls whether an Alert will appear
	// to confirm deletion of a ShoppingItem
	@State private var showDeleteConfirmation: Bool = false


	// we need access to the complete list of Locations to populate the picker
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>

	var body: some View {
		Form {
			// 1
			Section(header: MySectionHeaderView(title: "Basic Information")) {
				HStack(alignment: .firstTextBaseline) {
					MyFormLabelText(labelText: "Name: ")
					TextField("Item name", text: $itemName, onCommit: { self.commitDataEntry() })
				}
				Stepper(value: $itemQuantity, in: 1...10) {
					HStack {
						MyFormLabelText(labelText: "Quantity: ")
						Text("\(itemQuantity)")
					}
				}
				Picker(selection: $selectedLocationIndex,
							 label: MyFormLabelText(labelText: "Location: ")) {
					ForEach(0 ..< locations.count, id:\.self) { index in
						Text(self.locations[index].name!)
					}
				}
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $onList) {
						MyFormLabelText(labelText: "On Shopping List: ")
					}
				}
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $isAvailable) {
						MyFormLabelText(labelText: "Is Available: ")
					}
				}
			} // end of Section
			
			// 2 -- operational buttons
			Section(header: MySectionHeaderView(title: "Shopping Item Management")) {
				HStack {
					Spacer()
					Button("Save") {
						self.commitDataEntry()
					}
					.disabled(itemName.isEmpty)
					Spacer()
				}

				if editableItem != nil {
					HStack {
						Spacer()
						Button("Delete This Shopping Item") {
							self.showDeleteConfirmation = true
						}
						.foregroundColor(Color.red)
						Spacer()
					}
				}
				
			} // end of Section
			.alert(isPresented: $showDeleteConfirmation) {
				Alert(title: Text("Delete \'\(editableItem!.name!)\'?"),
							message: Text("Are you sure you want to delete this item?"),
							primaryButton: .cancel(Text("No")),
							secondaryButton: .destructive(Text("Yes"), action: self.deleteItem)
				)}
	
		
		} // end of Form
			.navigationBarTitle(barTitle(), displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading: Button(action : {
				self.presentationMode.wrappedValue.dismiss()
			}){
				Text("Cancel")
			})
			.onAppear(perform: loadData)


	}
		
	func barTitle() -> Text {
		return editableItem == nil ? Text("Add New Item") : Text("Modify Item")
	}
	
	func loadData() {
		// called on every .onAppear().  if dataLoaded is true, then we have
		// already taken care of setting up the local state variables.
		if dataLoaded {
			return
		}
		// if there is an incoming editable shopping item, offload its
		// values to the state variables
		if let item = editableItem {
			itemName = item.name!
			itemQuantity = Int(item.quantity)
			let locationNames = locations.map() { $0.name! }
			if let index = locationNames.firstIndex(of: item.location!.name!) {
				selectedLocationIndex = index
			} else {
				selectedLocationIndex = locations.count - 1 // index of Unknown Location
			}
			onList = item.onList
			isAvailable = item.isAvailable
		} else {
			// set up to be true if adding a new item to shoppinglist,
			// but false if adding to purchased list. (user can override on screen)
			onList = addItemToShoppingList
			selectedLocationIndex = locations.count - 1 // index of Unknown Location
		}
		// and be sure we don't do this again (!)
		dataLoaded = true
	}
	
	func commitDataEntry() {
		// if we already have an editableItem, use it,
		// else create it now
		var itemForCommit: ShoppingItem
		if let item = editableItem {
			itemForCommit = item
		} else {
			itemForCommit = ShoppingItem.addNewItem()
		}

		// fill in basic info fields
		itemForCommit.name = itemName
		itemForCommit.quantity = Int32(itemQuantity)
		itemForCommit.onList = onList
		itemForCommit.isAvailable = isAvailable
		// if existing object, remove its reference from its locations (notice ?.?.!)
		editableItem?.location?.removeFromItems(editableItem!)
		// then update location info
		itemForCommit.setLocation(locations[selectedLocationIndex])
		ShoppingItem.saveChanges()
		presentationMode.wrappedValue.dismiss()
	}
	
	func deleteItem() {
		if let item = editableItem {
			ShoppingItem.delete(item: item, saveChanges: true)
			presentationMode.wrappedValue.dismiss()
		}
	}
}
