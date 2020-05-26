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
	@State private var selectedTab = 1
	
	var body: some View {
		NavigationView {
			TabView(selection: $selectedTab) {
				ShoppingListTabView()
					.tabItem {
						Image(systemName: "cart")
						Text("Shopping List")
				}.tag(1)
				
				PurchasedTabView()
					.tabItem {
						Image(systemName: "purchased")
						Text("Purchased")
				}.tag(2)
				
				LocationsTabView()
					.tabItem {
						Image(systemName: "map")
						Text("Locations")
				}.tag(3)
			}
			.navigationBarTitle(tabTitle(selectedTab: selectedTab))
			.onAppear(perform: doAppearanceCode)

		} // end of NavigationView
	}
		
		func tabTitle(selectedTab: Int) -> String {
			if selectedTab == 1 {
				return "Shopping List"
			} else if selectedTab == 2 {
				return "Purchased"
			} else {
				return "Locations"
			}
		}
	
	func doAppearanceCode() {
		if kPerformInitialDataLoad {
			populateDatabaseFromJSON()
		}
		if kPerformJSONOutputDumpOnAppear {
			writeAsJSON(items: ShoppingItem.allShoppingItems(), to: kShoppingItemsFilename)
			writeAsJSON(items: Location.allLocations(), to: kLocationsFilename)
		}
	}
	

}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
