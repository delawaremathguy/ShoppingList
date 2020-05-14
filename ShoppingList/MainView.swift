//
//  MainView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData


struct MainView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	var body: some View {
		TabView {
			ShoppingListView()
				.tabItem {
					Image(systemName: "cart")
					Text("Shopping List")
			}
			
			PurchasedItemView()
				.tabItem {
					Image(systemName: "purchased")
					Text("Purchased")
			}
			
			LocationsView()
				.tabItem {
					Image(systemName: "map")
					Text("Locations")
			}
		}
		.onAppear(perform: onAppearanceCode)
	}
	
	func onAppearanceCode() {
		//print(".onAppear in MainView")
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
