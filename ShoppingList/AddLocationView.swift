//
//  AddLocationView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct AddLocationView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.presentationMode) var presentationMode

	@State private var locationName: String = ""
	@State private var visitationOrder: Int = 0
	
	var body: some View {
		Form {
			// 1: Name and Quantity
			Section {
				TextField("Location name", text: $locationName)
				Stepper(value: $visitationOrder, in: 1...100) {
					Text("Visitation Order: \(visitationOrder)")
				}


			// 2
			Section {
				Button("Save") {
					self.commitData()
				}
				}
			} // end of Section
		} // end of Form
			.navigationBarTitle("Add New Location", displayMode: .inline)
			.onAppear(perform: loadData)
	}
	
	func commitData() {
		let _ = Location.addNewLocation(name: locationName, visitationOrder: visitationOrder)
		presentationMode.wrappedValue.dismiss()
	}
	
	func loadData() {
		
	}
	
}

struct AddLocationView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationView()
    }
}
