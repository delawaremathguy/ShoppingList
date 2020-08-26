//
//  MainView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

// the MainView is where the app begins.  it is a tab view with four tabs.
// a fifth tab also appears if kShowDevToolsTab is true (this is set in code
// in Development.swift). not much happens here, other
// than to track the selected tab (1, 2, 3, or 4), although we don't actually
// use this value for anything right now.

struct MainView: View {
	@State private var selectedTab = 1
	
	var body: some View {
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
			
			TimerTabView()
				.tabItem {
					Image(systemName: "stopwatch")
					Text("Stopwatch")
			}.tag(4)
			
			if kShowDevToolsTab { // this setting is in Development.swift
				DevToolsTabView()
					.tabItem {
						Image(systemName: "wrench")
						Text("Dev Tools")
				}.tag(5)
			}
			
			
		} // end of TabView
	} // end of var body: some View
	
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
