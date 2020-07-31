#  About "ShoppingList"

This is a simple, in-progress, "fail-in-public" iOS app development project using SwiftUI to process a shopping list that you can take to the grocery store with you, and swipe off the items as you pick them up.  It persists data in CoreData.

I'm making this repo publicly available.  I am interested in asking some questions about what I am doing (e.g., in the Apple Developer forums, on the HackingWithSwift forums), and possibly getting some feedback, and it's easier to do that if I expose all the source for inspection.  There was also a recent question on the Apple Developer's forum, *[Example using Core Data between views](https://forums.developer.apple.com/thread/133370)* that expressed some frustration in not being able to find enough examples of working with CoreData and getting list updates done correctly (that whole thing about Identifiable, id:\.self, @ObservedObject, etc).  My hope is this project will fill some of that need, even if it's not yet demonstrated to be 100% bullet-proof.

However, be warned: 

* the project source is likely to change often -- this is an ongoing project for me to get more familiar with certain details of SwiftUI; 
* there may be errors in the code, or some areas of the code might need help with regard to best practices; and
* nevertheless, this is reasonably stable and does pretty much work as I suggest as of today (I really do use it myself when I go shopping).

Feel free to use this as is, to develop further,  to completely ignore, or even just to inspect and then send me a note to tell me I am doing this all wrong.  

## Last Update of Note

My Last Update of note was **July 31, 2020**, when these were some of the recent changes I made.

* I fixed some thing that were broken by implementing code the last two days (see what follows), and after seeing a spectacular crash, I discovered yet one more thing about how SwiftUI works with Views.  *That's why I have this project, right?*  So I have started doing the dirty work of using Combine (which turns out not to be so dirty) in the shopping list view models so that they now watch for changes to any of the items they track by creating a Cancellable for every item in the array, with each objectWillChange message from a shoppingItem then relayed into an objectWillChange message for the view model. So, be forewarned, the changes that follow from yesterday are still being worked on ...

* I did a major rewrite of the code involving the shopping list (both the single- and multi-section versions) and the purchased items list to **not use @FetchRequest**.  Rather, there's now a proper "view model," at least as i understand what a view model is, so that these views don't do much of anything with shopping items themselves, but send everything back to their view model to do for them.  This allows me to manage a list of items in each view (loaded in onAppear()) and be sure that changes to items are properly coordinated and signaled back to the view using objectWillChange.send().

* A similar rewrite of the Locations has happened as well, eliminating all use of @FetchRequest in the program. 

* Additionally, I really do now believe that while @FetchRequest is a convenience for many simple cases, it breaks the MVVM architecture.  Perhaps I'll say more on this later.

* With this rewrite, the deletion bug issue seems to have disappeared, *I think* (XCode 11.6/iOS 13.6), and the reason is that I am not letting SwiftUI use its @FetchRequest to manage a list of items for me.  The crash I kept getting was always the same: a Core Data object was deleted, but the @FetchRequest seemed to be still be using a phantom reference to it where .isDeleted is false, but .isFault is true.  Everytime you tried to access the optional fields of the object, we go BOOM because it's not a real object. There's an issue of timing and coordination here that just was not working right (*or I was not understanding correctly*).

* I also am using a little bit of a new technique with the new code to do some deletions. If an item listed in View1 is marked for deletion in a detail-like View2, View2 dismisses and queues the actual deletion with the right viewModel on the main queue with a short delay (about 1/2 second).  That way, we return to View1 and we see a nice transition as the item is deleted; and it avoids all the ugly messages about a tableview being laid out outside the view hierarchy.

I'm also now starting to test out this code with XCode 12beta 3, and here are some observations so far:

* Core Data now automatically generates an extension of a Core Data class to be Identifiable, if the data model has an id field (mine has type UUID, but maybe other Hashable types apply as well).  So adding my own conformance of Shopping Item and Location to Identifiable is no longer needed.  (XCode will generate a duplicate conformance error, not on my adding conformance, but *on its own generated file*, which was a little confusing at first.)
* GroupedListStyle now puts a section header in .uppercase by default, but you can override that by using .textcase(.none) so the header displays the title exactly as you want.
* Unfortunately, there is a **new crash**, even with (and possibly independent of) my rewrite. I think the problem now is that the .onAppear() and .onDisappear() modifiers are not doing the right thing in XCode 12beta3 when switching between tabs.  For example, see [iOS 14 .onAppear() is called on DISappear instead of appear](https://developer.apple.com/forums/thread/655338) in the Apple Developer's Forum. I rely on these working as advertised to initialize a viewModel in each tab.


## License

* The SearchBarView in the Purchased items view was created by Simon Ng.  It appeared in [an article in AppCoda](https://www.appcoda.com/swiftui-search-bar/) and is copyright © 2020 by AppCoda. You can find it on GitHub under AppCoda/SwiftUISearchBar. 
* The app icon was created by Wes Breazell from [the Noun Project](https://thenounproject.com). 
* The extension I use on Bundle to load JSON files is due to Paul Hudson (@twostraws, [hackingwithswift.com](https://hackingwithswift.com)) 

Otherwise, almost all of the code is original,  and it's yours if you want it -- please see LICENSE for the usual details and disclaimers.

## General App Structure

The main screen is a TabView, to show 
* a current shopping list, 
* a list of previously purchased items, and
* a list of "locations" in a store, such as "Dairy," "Fruits & Vegetables," "Deli," and so forth, and
* an in-store timer, to track how long it takes you to complete shopping, and
* optionally, for purposes of demonstration, a "Dev Tools" tab to make wholesale adjustments to the data and the shopping list display (this can be hidden for real usage).

The CoreData model has only two entities named "ShoppingItem" and "Location," with every ShoppingItem having a to-one relationship to a Location (the inverse is to-many).

**ShoppingItems** have an id (UUID), a name, a quantity, a boolean "onList" that indicates whether the item is on the list for today's shopping exercise, or not on the list (and so available in the purchased list for future promotion to the shopping list), and also an "isAvailable" boolean that provides a strike-through appearance for the item when false (sometimes an item is on the list, but not available today, and I want to remember that when planning the future shopping list).    ShoppingItems currently also have a visitationOrder, that mirrors the visitationOrder of the Location to which they are assigned -- you'll see a comment in the code about why this is done.

**Locations** have an id (UUID), a name, a visitationOrder (an integer, as in, go to the dairy first, then the deli, then the canned vegetables, etc), and then values red, green, blue, opacity to define a color that is used to color every item listed in the shopping list.

* A note on color.  There is now a ColorPicker in SwiftUI (*as of WWDC2020*), and "sometime soon" I will start using that as I begin testing out XCode 12.  In the meantime, individually adjusting RGB and Alpha may not the best UI, but it will have to do.  Also, using color to distinguish different Locations may not even be a good UI, since a significant portion of users either cannot distinguish color or cannot choose visually compatible colors very well. 

For the first two tabs, swiping an item (from trailing to leading)  moves a shopping item from one list to the other list (from "on the list" to "purchased" and vice-versa).  

* This is an issue with SwiftUI, even after WWDC2020: the only swipe supported is a swipe-to-delete and it shows "Delete" in white on a red background for the action.  I like to swipe as I shop to move items off the shopping list (not delete them from Core Data), so I have co-opted the swipe to mean "move to the other list," despite the destructive "Delete  showing. This behaviour can be adjusted in code to mean "delete, really" if you prefer.  

Tapping on any item in either list lets you edit it for name, quantity, assign/edit the store location in which it is found, or even delete the item.  Long pressing on an item gives you a contextMenu to let you move items between lists,  toggle between the item being available and not available, or directly delete the item (if a swipe does not already mean "delete").

The shopping list is sorted by the visitation order of the location in which it is found (and then alphabetically within each Location).  Items in the shopping list cannot be otherwise re-ordered, although all items in the same Location have the same color as a form of grouping.

* Why don't you let me drag these items to reorder them, you ask?  Well, I did the reordering thing one time with .onMove(), and discovered that moving items around in a list in SwiftUI is an absolutely horrific user-experience when you have 30 or 40 items on the list -- so I don't so that anymore.  And I also don't see that you can drag between Sections of a list.
* The current code offers you the choice to see the shopping list either as one big list where the coloring helps distinguish between different location (use ShoppingListTabView1 when you compile it) or a sectioned-list with GroupedListStyle (use ShoppingListTabView2, the default view).  Both seem to work fine for now; and the DevTools tab lets you flip between these on the fly.


The third tab shows a list of all locations, listed in visitationOrder (an integer from 1...100).  One special Location is the "Unknown Location," which serves as the default location for all new items.  I use this special location to mean that "I don't really know where this item is yet, but I'll figure it out at the store." In programming terms, this location has the highest of all visitationOrder values, so that it comes last in the list of Locations, and shopping items with an unassigned/unknown location will come at the bottom of the shopping list. 

Tapping on a Location in the list lets you edit location information, including reassigning the visitation order, as well as delete it.  You will also see a list of the ShoppingItems that are associated with this Location. A long press on a location (other than the "unknown location") will allow you to delete the location.

* Why not let the user drag the Locations around to reset the order? Well, it's partly the SwiftUI visual problem with .onMove() mentioned below, but persisting the order the way I'd like to do (using visitationOrder markers) has a few wrinkles that seem to conflict with SwiftUI's @FetchRequest.
* What happens to ShoppingItems in a Location when a Location is deleted?  The items are not deleted, but simply moved to the Unknown Location.

* The fourth tab is an in-store timer, with three simple button controls: "Start," "Stop," and "Reset."  This timer will be (optionally) paused when the app goes inactive (e.g., if you get a phone call while you're shopping), although the default is to not pause it when going inactive. (See Development.swift to change this default.)

* Finally, there is a  tab for "development-only" purposes, that allows wholesale loading of sample data, removal of all data, offloading data for later use, and changing the sectioned-display of the shopping list. It's easier to make changes and see them here, rather than hunt through the source code to make these changes (although there is plenty of commentary in the source code).

So, if you plan to play with or use this app, the app will start with an empty shopping list and an almost-empty location list (it will contain the sacred "Unknown Location"); from there you can create your own shopping items and locations associated with those items.  Alternatively,  go straight  to the Dev Tools tab and tap the "Load Sample Data" button, play with the app, then delete the data when you're finished with it.


## Some Things I'm Working On


*  I have made the "Add New Shopping Item" button present as a Sheet, although if you later want to edit it, you'll transition using a NavigationLink.  (The same happens for "Add a New Location.")  You might be interested in seeing how to do this -- it turns out to be pretty simple.

* I am puzzled by how to handle rotation.  Rotate from a compact-width orientation into a regular-width orientation  (e.g., iPhone 11) and, yes, you get something surprising (I understand that part and think I can handle that later).  But then rotate back into a compact-width orientation and the display goes a little strange.


*  I still get console messages at runtime about tables laying out outside the view hierarchy, and one that's come up recently of "Trying to pop to a missing destination." (current set-up is XCode 11.5, simulator & myiPhone on iOS13.5, and MacOS 10.15.5). Since I added contextMenus, I get a plenty of "Unable to simultaneously satisfy constraints" messages.  I'm ignoring them for now, and I have already seen fewer or none of these in testing out XCode 12. Several internet comments  seem to be saying ignoring most of these messages is the right thing to do for now.

*  I have been constantly struggling with visual updates in SwiftUI, although not so much anymore.  For example, this is the classic update problem: say List A has an array of (CoreData) objects.  Tap on an item in List A, navigate to View B in which you can edit the fields of the object, save the changes to CoreData, then return to List A -- only to find that data for the object has not been visually updated.  The current code is working quite fine on visual updating and you may see a comment or two in the code about this.

*  I'm looking at the new SwiftUI releases from WWDC right now and can definitely use quite a bit of it very easily (e.g., a ColorPicker).

However, please be aware that there will be a point  where I will stop working on this project in  public.  
**That time is coming soon**.  I'd like to look at CloudKit support for the database separately for my own use 
(this could return to public view if I run into trouble and have to ask for help); but after that, 
any future development is probably not going to happen.  

For example, expanding the app and database to support multiple "Stores," each of which has "Locations," 
and having "ShoppingItems" being many-to-many with Locations so one item can be available in many Stores would be a nice exercise. 
But I don't gain anything more in the way of learning about SwiftUI to support that.

I built this project in public only as an experiment, and as a reference in trying to offer some suggested code to the 
many developers who keep running into the generic problem of: an item appears in View A; it is edited in View B; 
but its appearance in View A does not get updated properly.  I was also hoping I might get a comment or two 
along the way about what I am doing right or doing wrong. But I am  not at all interested in creating the next great 
shopping list app or moving any of this to the App Store.  *The world really does not need a new list-making app*.





## Anything Else?

The project is what it is -- it's an on-going, out-in-public offering of code that may be of use to some; it might be something you'd like to play with or even develop on your own (fixing some things that are currently broken, or adding better design elements); or it might be something you'll look at and realize you've done something similar and run into similar problems.

By the way: what you see today may not look anything like what it looks like tomorrow.  I've already had cases of getting something to work, then found it didn't work after the next change, and I've gone back and re-architected.  The CoreData model has changed multiple times -- but I do not rely on data migrations. (Yes, migrations were working correctly and I've done them in other projects, but at this stage, it's easier to just dump the database as JSON; delete the app; change the data model; and reload the data in code at startup ... which may require some coding changes to the code that loads it.)  Please see the code and comments in Development.swift and look at the new "Dev Tools" tab view for some explanations about how to load sample data, or dump the CoreData database to JSON.

Finally, a story. I have another sizeable UIKit-based project, completely unrelated to this Shopping List project. I had every intention of moving it to the App Store. But it lacked a couple of features (mostly synching with the Cloud across devices). And curiously, I had originally used CoreData to persist data when i started building it, when there was some cloud integration.

But Apple deprecated its sort-of-support for the cloud with CoreData somewhere around iOS 10.  So I rearchitected the app to use a database singleton to abstract the persistence specifics from the app, and then changed the persistence back-end to use UIDocuments with autosaving, which seemed to be an easier, supported path to the cloud.  And I learned a lot about UIDocuments and autosaving in the process.

I was very close to having what I wanted, just waiting to flesh out the cloud integration, but then WWDC2019 happened.  I saw two things: CoreData and CloudKit working together (which I had really wanted a long time ago) and SwiftUI (that was a BIG WOW). 

I have since rebuilt that app in UIKit with CoreData (it was easier than you think -- I had done it before), as well as added a new capability, and I am now actively building the project in parallel in SwiftUI.  But I ran into a few roadblocks (e.g., where's CollectionView, etc.) and kept finding myself with the same basic visual updating issues that have been discussed above.  So I am glad I built Shopping List (again, I had a need since I was doing almost all of the shopping during the pandemic) and confronted these issues. 

So far,  WWDC2020 has given me more than enough so I can move forward and eventually take that other app to the App Store.

Feel free to contact me about questions and comments.
