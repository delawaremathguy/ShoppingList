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
// tabs, all inside a NavigationView.  not much going on here, other
// than to track the selected tab (1, 2, 3, or 4) so that we can set
// the navigation title appropriately.

// one programming note: the .onAppear() modifier is used here to see
// if the database is empty (determined by whether there's a special "Unknown Location"
// already in the database), and if not, then we create that location.

struct MainView: View {
	@State private var selectedTab = 1

	var body: some View {
		NavigationView {
			
			// the first tabView is the shopping list.  change ShoppingListTabView1 to ShoppingListTabView2
			// to see what happens with my current investigation into sectioning the list of shopping items.
			
			TabView(selection: $selectedTab) {
				
				ShoppingListTabView2() // <--- see note above about changing the 2 to a 1
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

				if kShowDemoToolsTab {
					DevToolsTabView()
						.tabItem {
							Image(systemName: "wrench")
							Text("Dev Tools")
					}.tag(4)
				}

				
			} // end of TabView
				.navigationBarTitle(tabTitle(selectedTab: selectedTab))

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
			return "Demo Tools"
		}
	}
	
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
