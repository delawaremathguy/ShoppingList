//
//  ContentView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

// DEVELOPMENT NOTE: the section coding almost works: can change names and
// quantities, even move to Purchased list, without a problem.  but if you
// changed a location, then big boom.  even though .onAppear kicks in, the
// section recomputation does not happen soon enough, apparently?  besides,
// it's not clear i liked the sectioning anyway -- colors work for now.

struct ShoppingListTabView: View {
	// Core Data access for items on shopping list
//	@Environment(\.managedObjectContext) var moc
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.visitationOrder, ascending: true),
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == true")
	) var shoppingItems: FetchedResults<ShoppingItem>
	
	@State private var performInitialDataLoad = kPerformInitialDataLoad
	
	
	// this for experimenting with sheet
	@State private var addModifyShoppingItemSheetIsShowing = false
	@State private var editableItem: ShoppingItem?
	
	// sections
	//	@State private var sections = [[ShoppingItem]]()
	
	var body: some View {
		VStack {
			// add new item "button" is at top
			NavigationLink(destination: AddorModifyShoppingItemView(addItemToShoppingList: true)) {
				HStack {
					Spacer()
					Text("Add New Item")
						.foregroundColor(Color.blue)
					Spacer()
				}
				.padding(.bottom, 10)
			}
			
//			Button("Add New Item") {
//				self.editableItem = nil
//				self.addModifyShoppingItemSheetIsShowing.toggle()
//			}
//			.sheet(isPresented: $addModifyShoppingItemSheetIsShowing) {
//				AddorModifyShoppingItemView()
//					.environment(\.managedObjectContext, self.moc)
//			}
			
		List {
			
			// one main section, showing all items
			Section(header: Text("Items Listed: \(shoppingItems.count)")) {
				ForEach(shoppingItems) { item in // , id:\.self
					NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
						ShoppingItemView(item: item)
					}
					.listRowBackground(self.textColor(for: item))
				} // end of ForEach
					.onDelete(perform: moveToPurchased)
				
				// here's some working code for separate sections
				//				ForEach(sections, id:\.self) { sectionItems in
				//					Section(header: self.sectionTitle(for: sectionItems)) {
				//
				//						ForEach(sectionItems, id:\.self) { item in
				//							NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
				//								ShoppingItemView(item: item)
				//							}
				//							.listRowBackground(self.textColor(for: item))
				//						} // end of ForEach
				//							.onDelete(perform: { offsets in
				//								self.moveToPurchased2(at: offsets, in: sectionItems)
				//								})
				//
				//					} // end of Section
				//				} // end of ForEach
				
				
				// clear shopping list
				if !shoppingItems.isEmpty {
					HStack {
						Spacer()
						Button("Move All Items off-list") {
							self.clearShoppingList()
						}
						.foregroundColor(Color.blue)
						Spacer()
					}
				}
				
			} // end of Section
			
		}  // end of List
			.listStyle(GroupedListStyle())
		} // end of VStack
	}
	
	func sectionTitle(for items: [ShoppingItem]) -> Text {
		if let firstItem = items.first {
			return Text(firstItem.location!.name!)
		}
		return Text("Title")
	}
	
	func clearShoppingList() {
		for item in shoppingItems {
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}
	
	func moveToPurchased2(at indexSet: IndexSet, in items: [ShoppingItem]) {
		for index in indexSet {
			let item = items[index]
			item.onList = false
		}
		ShoppingItem.saveChanges()
		//		buildSections()
	}
	
	func moveToPurchased(indexSet: IndexSet) {
		for index in indexSet {
			let item = shoppingItems[index]
			item.onList = false
		}
		ShoppingItem.saveChanges()
	}
	
	//	func buildSections() {
	//		sections.removeAll()
	//		let d = Dictionary(grouping: shoppingItems, by: { $0.visitationOrder })
	//		let sortedKeys = d.keys.sorted()
	//		for key in sortedKeys {
	//			sections.append(d[key]!)
	//		}
	//	}
		
	
	func textColor(for item: ShoppingItem) -> Color {
		if let location = item.location {
			return Color(.sRGB, red: location.red, green: location.green, blue: location.blue, opacity: location.opacity)
		}
		return Color.red
	}
}

