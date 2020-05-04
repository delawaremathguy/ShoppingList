//
//  ContentView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	
	// the list of shoppingItems is loaded in .onAppear so we can control
	// when it gets loaded and then own it ourself
	@State private var shoppingItems = [ShoppingItem]()
	@State private var isHistorySectionShowing: Bool = true
	
// the purchasedItems are just handled directly through @FetchRequest
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "purchased == true")
	) var historyItems: FetchedResults<ShoppingItem>

	@State private var showingAddScreen: Bool = false
	
	var body: some View {
		NavigationView {
			List {
				Section(header: Text("On List (\(shoppingItems.count) items)")) {
					ForEach(shoppingItems) { item in
						NavigationLink(destination: ModifyShoppingItemView(editableItem: item, shoppingItems: self.$shoppingItems)) {
							Text(item.name!) // (item as! ShoppingItem).name!)
						}
					}
					.onMove(perform: moveItems)
					.onDelete(perform: moveToHistory)
					
					HStack {
						Spacer()
						Button(isHistorySectionShowing ? "Hide History Section" : "Show History Section") {
							self.isHistorySectionShowing.toggle()
						}
						Spacer()
					}
				} // end of Section
				
				
				if isHistorySectionShowing {
					Section(header: Text("History (\(historyItems.count) items)")) {
						ForEach(historyItems) { (item) in
							Text(item.name!) // (item as! ShoppingItem).name!)
						}
						.onDelete(perform: moveToShoppingList)
						
					}
				}
				
			}  // end of List
			.listStyle(GroupedListStyle())
				.navigationBarTitle(Text("Shopping List"))
				.navigationBarItems(leading: EditButton(),
														trailing: Button(action: {
															self.showingAddScreen.toggle()
														}) {
															Text("Add")
				})
				.sheet(isPresented: $showingAddScreen) {
					AddShoppingItemView(shoppingItems: self.$shoppingItems)
			}
			.onAppear(perform: loadData)
			
		}  // end of NavigationView
	}
	
	func moveItems(indexSet: IndexSet, index: Int) {
		shoppingItems.move(fromOffsets: indexSet, toOffset: index)
		saveItemOrder()
	}
	
	func moveToShoppingList(indexSet: IndexSet) {
		for index in indexSet {
			let item = historyItems[index]
			item.purchased = false
			shoppingItems.append(item)
			saveItemOrder()
		}
		// saveItemOrder()
		try? managedObjectContext.save()
	}

	func moveToHistory( indexSet: IndexSet) {
		for index in indexSet.reversed() {
			let item = shoppingItems[index]
			shoppingItems.remove(at: index)
			item.purchased = true
			saveItemOrder()
		}
		try? managedObjectContext.save()
	}
	
	func loadData() {
		// get the ShoppingItems that are saved in Core Data
		let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "purchased == false")
		let savedItems: [ShoppingItem]
		do {
			let items = try managedObjectContext.fetch(fetchRequest)
			savedItems = items
		}
		catch {
			savedItems = []
		}
		shoppingItems = savedItems
//		for item in shoppingItems {
//			print(item.id!)
//		}
		
		// if shoppingItems is empty, we're done
		if shoppingItems.count == 0 {
			return
		}
		
		// get saved order by UUID and then restore order in shopping list
		let fetchRequest2: NSFetchRequest<ListOrder> = ListOrder.fetchRequest()
		if let arrayOfOrder = try? managedObjectContext.fetch(fetchRequest2), arrayOfOrder.count > 0 {
			let shoppingListByUUID = arrayOfOrder[0].uuidOrder!
			// these should be the same length ...
			guard shoppingListByUUID.count == shoppingItems.count else { return }
			// split up shopping items by id, a UUID
			let uuid2ShoppingItem = Dictionary(grouping: shoppingItems, by: { $0.id! })
			shoppingItems = shoppingListByUUID.map({ uuid2ShoppingItem[$0]!.first! })
		}
		
	}
	
	func saveItemOrder() {
		// find existing order of items (it should be there, unless we never
		// added anything to the shopping list
		let newUUIDOrder = shoppingItems.compactMap({ $0.id })
		
		let fetchRequest: NSFetchRequest<ListOrder> = ListOrder.fetchRequest()
		let currentUUIDOrder: ListOrder
		do {
			let arrayOfOrder = try managedObjectContext.fetch(fetchRequest)
			if arrayOfOrder.count > 0 {
				currentUUIDOrder = arrayOfOrder[0]
				currentUUIDOrder.uuidOrder = newUUIDOrder
				try? managedObjectContext.save()
				return
			}
		} catch {
			NSLog("error fetching saveditem order")
		}
		
		// add new ListOrder entity to Core Data and we're done
		let newListOrder = ListOrder(context: managedObjectContext)
		newListOrder.uuidOrder = newUUIDOrder
		try? managedObjectContext.save()
	}
}

//struct ContentView_Previews: PreviewProvider {
//	static var previews: some View {
//		ContentView()
//	}
//}
