//
//  MainView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

// the MainView is where the app begins.  it is a tab view with three
// tabs, all inside a NavigationView.  a fourth tab also appears if kShowDevToolsTab
// is true (this is set in code in Development.swift). not much happens here, other
// than to track the selected tab (1, 2, 3, or 4) so that we can set
// the navigation title appropriately.

struct MainView: View {
	@State private var selectedTab = 1

	var body: some View {
		NavigationView {
			
			// the first tabView is the shopping list.  change ShoppingListTabView1 to ShoppingListTabView2
			// to see what happens with my current investigation into sectioning the list of shopping items.
			
			TabView(selection: $selectedTab) {
				
				ShoppingListTabView1() // <--- see note above about whether this is 1 or 2
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

				if kShowDevToolsTab {
					DevToolsTabView()
						.tabItem {
							Image(systemName: "wrench")
							Text("Dev Tools")
					}.tag(4)
				}

				
			} // end of TabView
				.navigationBarTitle(tabTitle(selectedTab: selectedTab))
				.onAppear(perform: reportEntityCounts) // just for testing ...

		} // end of NavigationView
	}
	
	func tabTitle(selectedTab: Int) -> String {
		if selectedTab == 1 {
			return "Shopping List"
		} else if selectedTab == 2 {
			return "Purchased"
		} else if selectedTab == 3 {
			return "Locations"
		} else {
			return "Dev Tools"
		}
	}
	
	func reportEntityCounts() {
//		print("Number of shopping items is \(ShoppingItem.count())")
//		print("Number of locations is \(Location.count())")
	}
	
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
