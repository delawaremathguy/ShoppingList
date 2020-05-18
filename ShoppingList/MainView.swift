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
	// @Environment(\.managedObjectContext) var managedObjectContext
	var body: some View {
		TabView {
			ShoppingListTabView()
				.tabItem {
					Image(systemName: "cart")
					Text("Shopping List")
			}
			
			PurchasedTabView()
				.tabItem {
					Image(systemName: "purchased")
					Text("Purchased")
			}
			
			LocationsTabView()
				.tabItem {
					Image(systemName: "map")
					Text("Locations")
			}
		}
		.onAppear(perform: doAppearanceCode)
	}
	
	func doAppearanceCode() {
		if kPerformInitialDataLoad {
			populateDatabaseFromJSON()
		}
		if kPerformJSONOutputDumpOnAppear {
			writeAsJSON(items: ShoppingItem.allShoppingItems())
			writeAsJSON(items: Location.allLocations())
		}
	}
	

}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
