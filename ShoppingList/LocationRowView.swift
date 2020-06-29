//
//  LocationRowView.swift
//  ShoppingList
//
//  Created by Jerry on 6/1/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// ONCE AGAIN: i pulled this code out of the List/Section/ForEach/NavigationLink
// hierarchy in LocationTabView to simply the code, initially without @ObservedObject.
// then updates in the LocationTabView were not reflected.  when i came
// back and added @ObservedObject, all visual updates work fine.
// identifying the variable as an @Observed object causes SwiftUI to update this view properly.

// see comments in ShoppingItemRowView about the use of "isDeleted" here.

struct LocationRowView: View {
	@ObservedObject var location: Location
	
	var body: some View {
		HStack {
			if location.isDeleted {
				Text("Being Deleted")
					.font(.body)
				
			} else {
				
				VStack(alignment: .leading) {
					Text(location.name ?? "Being Deleted")
						.font(.headline)
					Text("\(location.items?.count ?? 0) items")
						.font(.caption)
				}
				if location.visitationOrder != kUnknownLocationVisitationOrder {
					Spacer()
					Text(String(location.visitationOrder))
				}
			} // end of if-then-else
		} // end of HStack
	} // end of body: some View
}
