#  About "ShoppingList"

My Last Update of note was **June 28, 2020**, when these were some of the changes I made.


* The one crash I have been experiencing and have worked around is one I now almost fully understand.  I have a work-around in-place to avoid crashing or improper data actions; but it is intimately tied to the interaction of @ObservedObject, @FetchRequest, and my use (versus SwiftUI's use) of .onDelete().  Since WWDC2020 did not add more general swipe actions, I think i'll leave things in place as is, although at some point I might provide hooks in the code so you can choose what you want to do about what a trailing swipe action means.
* I have added a delete action to the context menus in any list of ShoppingItems or Locations; and, you'll see the problem manifest itself if you choose Delete from the menu.  (That's what helped me understand the problem: Since ContextMenus seem to work better in iOS 13.5 (you'll get lots of layout messages in the console), I was able to put a delete in a contextMenu and see the problem in real time.
* I eliminated a hard-to-find crash that occurred only in an extreme situation (and is related to the ongoing problem mentioned above).  I have a guard in place so the situation never happens.  See comments in the code.
* Adding a new ShoppingItem now comes up as a Sheet (although later editing remains using a NavigationLink), so you can see how to do either one in code, depending on your preference.  
*  The meat of the AddorModifyShoppingItemView has been moved into its own View, separating a shopping item from the struct of the data for the item to be edited in the subview.  This makes for simpler code, especially given the nunmber of fields to edit and the number of view modifiers that are attached to this (Form) view.

* * * * * *

This is a simple, in-progress iOS app development project using SwiftUI to process a shopping list that you can take to the grocery store with you, and swipe off the items as you pick them up.  It persists data in CoreData.

I'm making this repo publicly available.  I may be interested in asking some questions about what I am doing (e.g., in the Apple Developer forums, on the HackingWithSwift forums), and it's easier to do that if I expose all the source for inspection.  There was also a recent question on the Apple Developer's forum, *[Example using Core Data between views](https://forums.developer.apple.com/thread/133370)* that expressed some frustration in not being able to find enough examples of working with CoreData and getting list updates done correctly (that whole thing about Identifiable, id:\.self, @ObservedObject, etc).  My hope is this project will fill some of that need, even if it's not yet demonstrated to be 100% bullet-proof.

However, be warned: 

* the project source is likely to change often -- this is an ongoing project for me to get more familiar with SwiftUI; 
* there may be errors in the code, or some areas of the code might need help with regard to best practices; yet
* nevertheless, this is reasonably stable and does pretty much work as I suggest as of today (I really do use it myself when I go shopping).

Nevertheless, feel free to use this as is, to develop further,  to completely ignore, or even just to inspect and then send me a note to tell me I am doing this all wrong.  

## License

The SearchBarView in the Purchased items view was created by Simon Ng.  It appeared in [an article in AppCoda](https://www.appcoda.com/swiftui-search-bar/) and is copyright © 2020 by AppCoda. You can find it on GitHub under AppCoda/SwiftUISearchBar.  The extension I use on Bundle to load JSON files is due to Paul Hudson (@twostraws, [hackingwithswift.com](https://hackingwithswift.com)) Otherwise, almost all of the code is original,  and it's yours if you want it -- please see LICENSE for the usual details and disclaimers.

## General App Structure

The main screen is a TabView, to show 
* a current shopping list, 
* a list of previously purchased items, and
* a list of "locations" in a store, such as "Dairy," "Fruits & Vegetables," "Deli," and so forth.  

The CoreData model has only two entities named "ShoppingItem" and "Location," with every ShoppingItem having a to-one relationship to a Location (the inverse is to-many).

**ShoppingItems** have an id (UUID), a name, a quantity, a boolean "onList" that indicates whether the item is on the list for today's shopping exercise, or not on the list (and so available in the purchased list for future promotion to the shopping list), and also an "isAvailable" boolean that provides a strike-through appearance for the item when false (sometimes an item is on the list, but not available today, and I want to remember that when planning the future shopping list).    ShoppingItems currently also have a visitationOrder, that mirrors the visitationOrder of the Location to which they are assigned -- you'll see a comment in the code about why this is done.

**Locations** have an id (UUID), a name, a visitationOrder (an integer, as in, go to the dairy first, then the deli, then the canned vegetables, etc), and then values red, green, blue, opacity to define a color that is used to color every item listed in the shopping list.

* A note on color.  There is now a ColorPicker in SwiftUI 2.0, and "sometime soon" I will start using that.  In the meantime, individually adjusting RGB and Alpha may not the best UI, but it will have to do. 

Swiping an item (from trailing to leading) in either the shopping list or the already-purchased list moves it to the other list.  This exposes an issue in SwiftUI: the swipe UI calls the motion a "Delete," and the view modifier is .onDelete, but nothing is being deleted in this case.  Tapping on any item in either list lets you edit it for name, quantity, assign/edit the store location in which it is found, or even delete the item.  Long pressing on an item gives you a contextMenu to let you move items between lists, and also to toggle between the item being available and not available.

* A reminder:  to truly delete a ShoppingItem from the database, go to its Modify View and tap the Delete button. (same for deleting Locations below ...)  ~~However, there is a latent bug I'm still trying to work out, perhaps because of my misunderstanding of a SwiftUI internal, although I have put together a work-around for it in the code so that I don't think you'll see its effect.~~
*  At some point, you will also be able to Delete an item from the contextMenu, but the attempted placement of a third button in the contextMenu is not showing and the layout system goes nuts ... some comments on SO seem to suggest this is a bug.
* I haven't seen anything yet from WWDC about handling general swiping actions.

The third tab shows a list of all locations, listed in visitationOrder (an integer from 1...100).  One special Location is the "Unknown Location" which serves as the default location for all new items, which means "I don't really know where this item is yet, but I'll figure it out at the store." In programming terms, this location has the highest of all visitationOrder values, so that it comes last in the list of Locations, and shopping items with an unassigned/unknown location will come at the bottom of the shopping list. 

Tapping on a Location in the list lets you edit location information, including reassigning the visitation order, as well as delete it.  You will also see a list of the ShoppingItems that are associated with this Location.

* Why not let the user drag the Locations around to reset the order? Well, it's partly the SwiftUI visual problem with .onMove() mentioned below, but persisting the order the way I'd like to do (using visitationOrder markers) has a few wrinkles that seem to conflict with SwiftUI's @FetchRequest.

The shopping list is sorted by the visitation order of the location in which it is found (and then alphabetically within each Location).  Items in the shopping list cannot be otherwise re-ordered, although all items in the same Location have the same color as a form of grouping.

* Why don't you let me drag these items to reorder them, you ask?  Well, I did the reordering thing one time, and discovered that moving items around in a list in SwiftUI is an absolutely horrific user-experience when you have 30 or 40 items on the list -- so I don't so that anymore.  And I also don't see that you can drag between Sections of a list.
* The current code offers you the choice to see the shopping list either as one big list where the coloring helps distinguish between different location (use ShoppingListTabView1 when you compile it) or a sectioned-list with GroupedListStyle (use ShoppingListTabView2, the default view).  Both seem to work fine for now.

* About color: Using color to distinguish different Locations is not a good UI, since a significant portion of users either cannot distinguish color or cannot choose visually compatible colors very well. 

If you plan to play with or use this app, the app will start with an empty shopping list; from there you can create your own shopping items and locations associated with those items.  To get the sense of the app, however, you really want some data to work with.  So go to the Dev Tools tab and tap the "Load Sample Data" button, play with the app, then delete the data when you're finished with it.


## Some Things I'm Working On

* I have provided two options for the ShoppingListTabView, named, suprisingly, *ShoppingListTabView1* and *ShoppingListTabView2*.  Just change the MainView code to use one or the other.  The latter is what I am working with myself, so that's what I have coded in MainView.  But if you're poking around in the code, try each one of them.

  - **ShoppingListTabView1** is a single list of items as described above, with items listed by their location's visitationOrder (and then alphabetically for each location).  Since Locations have different colors, the list is manageable, but not ideal.  

- **ShoppingListTabView2** is an alternative view with the list of items parceled out into **sections** with listStyle = GroupedListStyle.  After a gazillion attempts and coding and recoding, this version seems to be working almost pretty well so far.  I already seen some things from WWDC this week that i will investigate further, to see if there's a more natural paradigm for sectioning a List.

*  I have made the "Add New Shopping Item" button present a Sheet, although if you later want to edit it, you'll trnasition using a NavigationLink.  (The same will happen sometime soon for "Add a New Location.")  you might be interested in seeing how to do this -- it turns out to be pretty simple.

*  I'm puzzled for now on one thing. The MainView of this app is a TabView, embedded in a NavigationView, and therefore the MainView owns the navigation bar. The individual TabViews that appear in the MainView apparently cannot adjust the navigation bar themselves when they appear (e.g., add their own leading or trailing items or even change the title).  There might be a way for the MainView to work with this (I already control the title by the active TabView tag), but it seems counter-intuitive that the MainView needs to know how each individual TabView wants its navigation bar to be configured.  


*  I still get console messages at runtime about tables laying out outside the view hierarchy, and one that's come up recently of "Trying to pop to a missing destination." (current set-up is XCode 11.5, simulator & myiPhone on iOS13.5, and MacOS 10.15.5). I'm ignoring them for now, until the next iteration of SwiftUI. Several internet comments out there seem to be saying that's the right thing to do for now.

*  I have been constantly struggling with visual updates in this project.  For example, this is the classic update problem: say List A has an array of (CoreData) objects.  Tap on an item in List A, navigate to View B in which you can edit the fields of the object, save the changes to CoreData, then return to List A -- only to find that data for the object has not been visually updated.  The current code is working quite fine on visual updating -- I finally seem to have found the right mix of when @ObservedObect is necessary and when it isn't. You may see a comment or two in the code about this.

*  I'm looking at the new SwiftUI releases from WWDC right now and can definitely use quite a bit of it very easily (e.g., a ColorPicker); i think you may see a ShoppingList14 (for iOS 14) from me sometime soon.



## Anything Else?

The project is what it is -- it's an on-going, out-in-public offering of code that may be of use to some; it might be something you'd like to play with or even develop on your own (fixing some things that are currently broken, or adding better design elements); or it might be something you'll look at and realize you've done something similar and run into similar problems.

By the way: what you see today may not look anything like what it looks like tomorrow.  I've already had cases of getting something to work, then found it didn't work after the next change, and I've gone back and re-architected.  The CoreData model has changed multiple times -- but I do not rely on data migrations. (Yes, migrations were working correctly and I've done them in other projects, but at this stage, it's easier to just dump the database as JSON; delete the app; change the data model; and reload the data in code at startup ... which may require some coding changes to the code that loads it.)  Please see the code and comments in Development.swift and look at the new "Dev Tools" tab view for some explanations about how to load sample data, or dump the CoreData database to JSON.

Finally, a story. I have another sizeable UIKit-based project, completely unrelated to this Shopping List project. I had every intention of moving to the App Store. But it lacked a couple of features (mostly synching with the Cloud across devices). And curiously, I had originally used CoreData to persist data when i started building it, when there was some cloud integration.

But Apple deprecated its sort-of-support for the cloud with CoreData somewhere around iOS 10.  So I rearchitected the app to use a database singleton to abstract the persistence specifics from the app, and then changed the persistence back-end to use UIDocuments with autosaving, which seemed to be an easier, supported path to the cloud.  And I learned a lot about UIDocuments and autosaving in the process.

I was very close to having what I wanted, just waiting to flesh out the cloud integration, but then WWDC2019 happened.  I saw two things: CoreData and CloudKit working together (which I had really wanted a long time ago) and SwiftUI (that was a BIG WOW). 

I have since rebuilt that app with CoreData (it was easier than you think -- I had done it before), and I am now actively building the project in parallel in SwiftUI.  But I ran into a few roadblocks (e.g., where's CollectionView, etc.) and kept finding myself with the same basic visual updating issues that have been discussed above.  So I am glad I built Shopping List (again, I had a need since I was doing almost all of the shopping during the pandemic) and confronted these issues. 

So far, this week's WWDC has given me more than enough so I can move forward and eventually take that other app to the App Store.

Feel free to contact me about questions and comments.
