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
	@State private var red: Double = 0.5
	@State private var green: Double = 0.5
	@State private var blue: Double = 0.5
	@State private var opacity: Double = 0.5

	var body: some View {
		Form {
			// 1: Name and Quantity
			Section {
				TextField("Location name", text: $locationName)
				Stepper(value: $visitationOrder, in: 1...100) {
					Text("Visitation Order: \(visitationOrder)")
				}

				HStack {
					Text("Red: \(red)")
					Spacer()
					Slider(value: $red, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Text("Green: \(green)")
					Spacer()
					Slider(value: $green, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Text("Blue: \(blue)")
					Spacer()
					Slider(value: $blue, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Text("Opacity: \(opacity)")
					Spacer()
					Slider(value: $opacity, in: 0 ... 1)
						.frame(width: 200)
				}
				Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)

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
		let newLocation = Location.addNewLocation()
		newLocation.red = red
		newLocation.green = green
		newLocation.blue = blue
		newLocation.opacity = opacity
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
