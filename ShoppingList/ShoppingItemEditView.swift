//
//  ShoppingItemEditView.swift
//  ShoppingList
//
//  Created by Jerry on 6/28/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct ShoppingItemEditView: View {
	
	// we need access to the complete list of Locations to populate the picker
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	private var locations: FetchedResults<Location>

	@Binding var editableData: EditableShoppingItemData
	@Binding var showDeleteConfirmation: Bool
	var allowsDeletion: Bool
	
    var body: some View {
			Form {
				// 1. Basic Information Fields
				Section(header: SLSectionHeaderView(title: "Basic Information")) {
					
					HStack(alignment: .firstTextBaseline) {
						SLFormLabelText(labelText: "Name: ")
						TextField("Item name", text: $editableData.itemName)
					}
					
					Stepper(value: $editableData.itemQuantity, in: 1...10) {
						HStack {
							SLFormLabelText(labelText: "Quantity: ")
							Text("\(editableData.itemQuantity)")
						}
					}
					
					Picker(selection: $editableData.location, label: SLFormLabelText(labelText: "Location: ")) {
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
				
				// 2. Item Management (Delete), if present
				if allowsDeletion {
					Section(header: SLSectionHeaderView(title: "Shopping Item Management")) {
						SLCenteredButton(title: "Delete This Shopping Item",
														 action: { self.showDeleteConfirmation = true })
							.foregroundColor(Color.red)
					}
				} // end of Section
				
			} // end of Form
	}
}

