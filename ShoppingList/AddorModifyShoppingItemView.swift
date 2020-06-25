//
//  ModifyShoppingItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/3/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// this is a transitional struct in the sense that on the way in, all the data for
// a shoppingItem that i want to edit is copied into one of these; and on the way
// out, whatever data is here is copied to the shoppingItem.  so we don't do
// live editing -- we can edit away, but none of those changes is saved until
// you really click the Save button.

struct EditableShoppingItemData {
	 // all of the values here provide suitable defaults for a new shopping item
	var itemName: String = ""
	var itemQuantity: Int = 1
	var selectedLocation = Location.unknownLocation()!
	var onList: Bool = true
	var isAvailable = true
	
	// this copies all the editable data from an incoming ShoppingItem
	init(shoppingItem: ShoppingItem) {
		itemName = shoppingItem.name!
		itemQuantity = Int(shoppingItem.quantity)
		selectedLocation = shoppingItem.location!
		onList = shoppingItem.onList
		isAvailable = shoppingItem.onList
	}
	
	// provides simple, default init with values specified above
	init() { }
	
	// provides special case init when we adding a new shopping item
	// to provide default for being on the list or not (all other values
	// are defaulted properly)
	init(onList: Bool) {
		self.onList = onList
	}
}

// MARK: - View Definition

struct AddorModifyShoppingItemView: View {
	@Environment(\.presentationMode) var presentationMode

	// editableItem is either a ShoppingItem to edit, or nil to signify
	// that we're creating a new ShoppingItem in this View.
	var editableItem: ShoppingItem? = nil
	
	// addItemToShoppingList just means that if we are adding a new item
	// (editableItem == nil), this tells us whether to put it on the shopping
	// list initially or not.  the default is true: a new item goes on the shopping list.
	// however, if inserting a new item from the Purchased list,
	// this will be set to false. the user can override here if they wish.
	var addItemToShoppingList: Bool = true
	
	// this editableData stuct contains all of the fields of a ShoppingItem that
	// can be edited here, so that we're not doing a "live edit" on the ShoppingItem.
	// this will be defaulted properly in .onAppear()
	@State private var editableData = EditableShoppingItemData()
	
	// this indicates dataHasBeenLoaded from an incoming editableItem
	// it will be flipped to true once .onAppear() has been called
	@State private var editableDataInitialized = false
	
	// showDeleteConfirmation controls whether an Alert will appear
	// to confirm deletion of a ShoppingItem
	@State private var showDeleteConfirmation: Bool = false
	
	// this itemToDelete... variable is a place to stash an item to be deleted, if any,
	// after the view has disappeared.  seems like a kludgy way to do this, but also seems
	// to work without incident (instead of deleting first then popping this view back
	// to its navigation parent, which seemed to want to crash)
	@State private var itemToDeleteAfterDisappear: ShoppingItem?

	// we need access to the complete list of Locations to populate the picker
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>

	var body: some View {
		Form {
			// 1. Basic Information Fields
			Section(header: MySectionHeaderView(title: "Basic Information")) {
				
				HStack(alignment: .firstTextBaseline) {
					SLFormLabelText(labelText: "Name: ")
					TextField("Item name", text: $editableData.itemName, onCommit: { self.commitDataEntry() })
				}
				
				Stepper(value: $editableData.itemQuantity, in: 1...10) {
					HStack {
						SLFormLabelText(labelText: "Quantity: ")
						Text("\(editableData.itemQuantity)")
					}
				}
				
				Picker(selection: $editableData.selectedLocation,
							 label: SLFormLabelText(labelText: "Location: ")) {
								ForEach(locations) { location in
									Text(location.name!).tag(location)
								}
				}
				
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $editableData.onList) {
						SLFormLabelText(labelText: "On Shopping List: ")
					}
				}
				
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $editableData.isAvailable) {
						SLFormLabelText(labelText: "Is Available: ")
					}
				}
				
			} // end of Section
			
			// 2. Item Management (Save/Delete)
			Section(header: MySectionHeaderView(title: "Shopping Item Management")) {
				
				SLCenteredButton(title: "Save", action: self.commitDataEntry)
				
				if editableItem != nil {
					SLCenteredButton(title: "Delete This Shopping Item", action: { self.showDeleteConfirmation = true })
						.foregroundColor(Color.red)
						.alert(isPresented: $showDeleteConfirmation) {
							Alert(title: Text("Delete \'\(editableItem!.name!)\'?"),
										message: Text("Are you sure you want to delete this item?"),
										primaryButton: .cancel(Text("No")),
										secondaryButton: .destructive(Text("Yes"), action: self.deleteItem)
							)}
				}
				
			} // end of Section
		
		} // end of Form
			.navigationBarTitle(barTitle(), displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading: Button(action : {
				self.presentationMode.wrappedValue.dismiss()
			}){
				Text("Cancel")
			})
			.onAppear(perform: loadData)
			.onDisappear(perform: deleteItemIfRequested)


	}
	
	// called when view disappears, which is when the parent view has fully returned
	// to the screen.  this way, we don't delete out from under the parent, which seems
	// to have been the underlying bug i struggled with earlier
	func deleteItemIfRequested() {
		if let item = itemToDeleteAfterDisappear {
			ShoppingItem.delete(item: item)
		}
	}
		
	func barTitle() -> Text {
		return editableItem == nil ? Text("Add New Item") : Text("Modify Item")
	}
	
	func loadData() {
		// called on every .onAppear().  if dataLoaded is true, then we have
		// already taken care of setting up the local state editable data.  otherwise,
		// we offload all the data from the editableItem (if there is one) to the
		// local state editable data that control this view
		if !editableDataInitialized {
			if let item = editableItem {
				editableData = EditableShoppingItemData(shoppingItem: item)
			} else {
				// just be sure the default data is tweaked to place a new item on
				// the right list by default, depending on how this view was created
				editableData = EditableShoppingItemData(onList: addItemToShoppingList)
			}
			// and be sure we don't do this again (!)
			editableDataInitialized = true
		}
	}
	
	func commitDataEntry() {
		// if we already have an editableItem, use it, else create it now
		var itemForCommit: ShoppingItem
		if let item = editableItem {
			itemForCommit = item
		} else {
			itemForCommit = ShoppingItem.addNewItem()
		}

		// update for all edits made and we're done.  i created an extension
		// on ShoppingItem below to do thi update
		itemForCommit.updateValues(from: editableData)
		ShoppingItem.saveChanges()
		presentationMode.wrappedValue.dismiss()
	}
	
	// called after confirmation to delete an item.  we only place this
	// item to delete "on hold" and it will be deleted after this view disappears --
	// which means that you'll see the deletion then take place in the parent view
	func deleteItem() {
		if let item = editableItem {
			itemToDeleteAfterDisappear = item
			// ShoppingItem.delete(item: item, saveChanges: true)
			presentationMode.wrappedValue.dismiss()
		}
	}
}

// MARK: - ShoppingItem Convenience Extension

extension ShoppingItem {
	
	func updateValues(from editableData: EditableShoppingItemData) {
		name = editableData.itemName
		quantity = Int32(editableData.itemQuantity)
		setLocation(editableData.selectedLocation)
		onList = editableData.onList
		isAvailable = editableData.isAvailable
	}
}
