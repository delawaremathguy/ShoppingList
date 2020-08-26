//
//  LocationRowView.swift
//  ShoppingList
//
//  Created by Jerry on 6/1/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// DEVELOPMENT COMMENT
// see the discussion in ShoppingItemRowView.

// this is a struct to transport all the incoming data about a Location that we will display
struct LocationRowData {
	var name: String = ""
	var itemCount: Int = 0
	var visitationOrder: Int32 = 0
	var uiColor = UIColor()
	
	init(location: Location) {
		name = location.name!
		itemCount = location.items!.count
		visitationOrder = location.visitationOrder
		uiColor = location.uiColor()
	}
}

struct LocationRowView: View {
	 var rowData: LocationRowData
	
	var body: some View {
		HStack {
			// color bar at left (new in this code)
			Color(rowData.uiColor)
				.frame(width: 10, height: 36)
			
			VStack(alignment: .leading) {
				Text(rowData.name)
					.font(.headline)
				Text(subtitle())
					.font(.caption)
			}
			if rowData.visitationOrder != kUnknownLocationVisitationOrder {
				Spacer()
				Text(String(rowData.visitationOrder))
			}
		} // end of HStack
	} // end of body: some View
	
	func subtitle() -> String {
		if rowData.itemCount == 1 {
			return "1 item"
		} else {
			return "\(rowData.itemCount) items"
		}
	}
	
}
