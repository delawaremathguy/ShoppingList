#  About "ShoppingList"

This is a simple, in-progress iOS app development project using SwiftUI to process a shopping list that you can take to the grocery store with you, and swipe off the items as you pick them up.  It persists data in CoreData.

I'm making this repo publicly available.  I may be interested in asking some questions about what I am doing (e.g., in the Apple Developer forums, on the HackingWithSwift forums), and it's easier to do that if I expose all the source for inspection.  There was also a recent question on the Apple Developer's forum, *[Example using Core Data between views](https://forums.developer.apple.com/thread/133370)* that expressed some frustration in not being able to find enough examples of working with CoreData and getting list updates done correctly (that whole thing about Identifiable, id:\.self, @ObservedObject, etc).  My hope is this project will fill some of that need, even if it's not yet demonstrated to be 100% bullet-proof.

However, be warned: 

* the project source is likely to change often -- this is an ongoing project for me to get more familiar with certain details of SwiftUI; 
* there may be errors in the code, or some areas of the code might need help with regard to best practices; and
* nevertheless, this is reasonably stable and does pretty much work as I suggest as of today (I really do use it myself when I go shopping).

Feel free to use this as is, to develop further,  to completely ignore, or even just to inspect and then send me a note to tell me I am doing this all wrong.  

## Last Update of Note

My Last Update of note was **July 12, 2020**, when these were some of the recent changes I made.

* Previous versions required that you change the source code to see the effect of viewing the shopping list as one section, or in multiple sections.  You can set the default in the source code, but also change during execution in the Dev Tools tab (if shown).
* I fixed a glaring, obvious *coding inaccuracy* in doing a "swipe to delete" action in the PurchasedItemView.  It's been there since forever -- I was "deleting" items using indices in the purchasedItems list, not the list of items as filtered by a (non-empty) searchtext.  *duh!*



## License

* The SearchBarView in the Purchased items view was created by Simon Ng.  It appeared in [an article in AppCoda](https://www.appcoda.com/swiftui-search-bar/) and is copyright © 2020 by AppCoda. You can find it on GitHub under AppCoda/SwiftUISearchBar. 
* The app icon was created by Wes Breazell from [the Noun Project](https://thenounproject.com). 
* The extension I use on Bundle to load JSON files is due to Paul Hudson (@twostraws, [hackingwithswift.com](https://hackingwithswift.com)) 

Otherwise, almost all of the code is original,  and it's yours if you want it -- please see LICENSE for the usual details and disclaimers.

## General App Structure

The main screen is a TabView, to show 
* a current shopping list, 
* a list of previously purchased items, and
* a list of "locations" in a store, such as "Dairy," "Fruits & Vegetables," "Deli," and so forth.  
* and, for purposes of demonstration, a "Dev Tools" tab to make wholesale adjustments to the data and the shopping list display (this can be hidden for usage).

The CoreData model has only two entities named "ShoppingItem" and "Location," with every ShoppingItem having a to-one relationship to a Location (the inverse is to-many).

**ShoppingItems** have an id (UUID), a name, a quantity, a boolean "onList" that indicates whether the item is on the list for today's shopping exercise, or not on the list (and so available in the purchased list for future promotion to the shopping list), and also an "isAvailable" boolean that provides a strike-through appearance for the item when false (sometimes an item is on the list, but not available today, and I want to remember that when planning the future shopping list).    ShoppingItems currently also have a visitationOrder, that mirrors the visitationOrder of the Location to which they are assigned -- you'll see a comment in the code about why this is done.

**Locations** have an id (UUID), a name, a visitationOrder (an integer, as in, go to the dairy first, then the deli, then the canned vegetables, etc), and then values red, green, blue, opacity to define a color that is used to color every item listed in the shopping list.

* A note on color.  There is now a ColorPicker in SwiftUI (*as of WWDC2020*), and "sometime soon" I will start using that as I begin testing out XCode 12.  In the meantime, individually adjusting RGB and Alpha may not the best UI, but it will have to do.  Also, using color to distinguish different Locations may not even be a good UI, since a significant portion of users either cannot distinguish color or cannot choose visually compatible colors very well. 

For the first two tabs, swiping an item (from trailing to leading)  moves a shopping item from one list to the other list (from "on the list" to "purchased" and vice-versa).  

* This is an issue with SwiftUI, even after WWDC2020: the only swipe supported is a swipe-to-delete and it shows "Delete" in white on a red background for the action.  I like to swipe as I shop to move items off the shopping list (not delete them from Core Data), so I have co-opted the swipe to mean "move to the other list," despite the destructive "Delete  showing. This behaviour can be adjusted in code to mean "delete, really" if you prefer.  

Tapping on any item in either list lets you edit it for name, quantity, assign/edit the store location in which it is found, or even delete the item.  Long pressing on an item gives you a contextMenu to let you move items between lists,  toggle between the item being available and not available, or directly delete the item (if a swipe does not already mean "delete").

The shopping list is sorted by the visitation order of the location in which it is found (and then alphabetically within each Location).  Items in the shopping list cannot be otherwise re-ordered, although all items in the same Location have the same color as a form of grouping.

* Why don't you let me drag these items to reorder them, you ask?  Well, I did the reordering thing one time with .onMove(), and discovered that moving items around in a list in SwiftUI is an absolutely horrific user-experience when you have 30 or 40 items on the list -- so I don't so that anymore.  And I also don't see that you can drag between Sections of a list.
* The current code offers you the choice to see the shopping list either as one big list where the coloring helps distinguish between different location (use ShoppingListTabView1 when you compile it) or a sectioned-list with GroupedListStyle (use ShoppingListTabView2, the default view).  Both seem to work fine for now.


The third tab shows a list of all locations, listed in visitationOrder (an integer from 1...100).  One special Location is the "Unknown Location," which serves as the default location for all new items.  I use this special location to mean that "I don't really know where this item is yet, but I'll figure it out at the store." In programming terms, this location has the highest of all visitationOrder values, so that it comes last in the list of Locations, and shopping items with an unassigned/unknown location will come at the bottom of the shopping list. 

Tapping on a Location in the list lets you edit location information, including reassigning the visitation order, as well as delete it.  You will also see a list of the ShoppingItems that are associated with this Location. A long press on a location (other than the "unknown location") will allow you to delete the location.

* Why not let the user drag the Locations around to reset the order? Well, it's partly the SwiftUI visual problem with .onMove() mentioned below, but persisting the order the way I'd like to do (using visitationOrder markers) has a few wrinkles that seem to conflict with SwiftUI's @FetchRequest.
* What happens to ShoppingItems in a Location when a Location is deleted?  The items are not deleted, but simply moved to the Unknown Location.

Finally, there is a fourth tab for "development-only" puroses, that allows wholesale loading of sample data, removal of all data, offloading data for later use, and changing the sectioned-display of the shopping list. It's easier to make changes and see here, rather than hunt through the source code to make these changes (although there is plenty of commentary in the source code).

So, if you plan to play with or use this app, the app will start with an empty shopping list; from there you can create your own shopping items and locations associated with those items.  Alternatively,  go straight  to the Dev Tools tab and tap the "Load Sample Data" button, play with the app, then delete the data when you're finished with it.


## Some Things I'm Working On

* There still remains an issue with the deletion of objects (ShoppingItems and Locations) and the use of @FetchRequest. 
Running in XCode 11.5 and iOS 13.5, the current code appears stable and does not blow up with deletions; however the iOS 14 beta situation looks worse. 
I am sure that the real issue concerns the exact connection between the magic of a @FetchRequest in ViewA and the deletion of one of its Core Data objects in View B (presented in a sheet above View A or pushed on the navigation stack from View A).  Even using a context menu in View A to delete a Core Data item in View A exhibits the problem.

* I have encountered this same deletion/@FetchRequest issue in another project, and am stuggling there, so I hope to have a resolution soon. Indeed, it's another example of a conundrum where   "an object must be an @Observed object for a view to update properly" and, at the same time, "not be an @Observed object because the program will crash if the item is deleted." 

* I discovered a crash with a simple, benign operation or two while running the app on my iPhone 11 with iOS 13.5.1 recently.  The crash logs showed the app very deep inside UITableVIew code when it crashed (virtually identical logs, by the way), so I am guessing **something changed in iOS 13.5.1** that wasn't there in 13.5.  It may also be related to use of a contextMenu, which I was using at the time.


* I have provided two options for the ShoppingListTabView. One is a single (section) list of items, and the other is a multi-section list, one section for each Location. Which is displayed by default is set in Development.swift, but if you're playing around in the code, try each one of them.  There's a "toggle" in the "Dev Tools" tab to see the difference in real time.

  - After a gazillion attempts and coding and recoding, the multi-section list seems to be working quite fine, so it you're having trouble getting lists sectioned out in SwiftUI, take a look at the code I use (what appears was about the gazillionth attempt to get the List/ForEach/Section/ForEach construct working right).  I have already seen some things from WWDC2020 that i will investigate further, to see if there's a more natural paradigm for sectioning a List.

*  I have made the "Add New Shopping Item" button present as a Sheet, although if you later want to edit it, you'll transition using a NavigationLink.  (The same happens for "Add a New Location.")  You might be interested in seeing how to do this -- it turns out to be pretty simple.

*  I'm puzzled for now on one thing. The MainView of this app is a TabView, embedded in a NavigationView, and therefore the MainView owns the navigation bar. The individual TabViews that appear in the MainView apparently cannot adjust the navigation bar themselves when they appear (e.g., add their own leading or trailing items or even change the title).  There might be a way for the MainView to work with this (I already control the title by the active TabView tag), but it seems counter-intuitive that the MainView needs to know how each individual TabView wants its navigation bar to be configured.  


*  I still get console messages at runtime about tables laying out outside the view hierarchy, and one that's come up recently of "Trying to pop to a missing destination." (current set-up is XCode 11.5, simulator & myiPhone on iOS13.5, and MacOS 10.15.5). I'm ignoring them for now, and I have already seen fewer or none of these in testing out XCode 12. Several internet comments  seem to be saying ignoring most of these messages is the right thing to do for now.

*  I have been constantly struggling with visual updates in SwiftUI, although not so much anymore.  For example, this is the classic update problem: say List A has an array of (CoreData) objects.  Tap on an item in List A, navigate to View B in which you can edit the fields of the object, save the changes to CoreData, then return to List A -- only to find that data for the object has not been visually updated.  The current code is working quite fine on visual updating and you may see a comment or two in the code about this.

*  I'm looking at the new SwiftUI releases from WWDC right now and can definitely use quite a bit of it very easily (e.g., a ColorPicker); i think you may see a ShoppingList14 (for iOS 14) from me sometime soon to play with.





## Anything Else?

The project is what it is -- it's an on-going, out-in-public offering of code that may be of use to some; it might be something you'd like to play with or even develop on your own (fixing some things that are currently broken, or adding better design elements); or it might be something you'll look at and realize you've done something similar and run into similar problems.

By the way: what you see today may not look anything like what it looks like tomorrow.  I've already had cases of getting something to work, then found it didn't work after the next change, and I've gone back and re-architected.  The CoreData model has changed multiple times -- but I do not rely on data migrations. (Yes, migrations were working correctly and I've done them in other projects, but at this stage, it's easier to just dump the database as JSON; delete the app; change the data model; and reload the data in code at startup ... which may require some coding changes to the code that loads it.)  Please see the code and comments in Development.swift and look at the new "Dev Tools" tab view for some explanations about how to load sample data, or dump the CoreData database to JSON.

Finally, a story. I have another sizeable UIKit-based project, completely unrelated to this Shopping List project. I had every intention of moving it to the App Store. But it lacked a couple of features (mostly synching with the Cloud across devices). And curiously, I had originally used CoreData to persist data when i started building it, when there was some cloud integration.

But Apple deprecated its sort-of-support for the cloud with CoreData somewhere around iOS 10.  So I rearchitected the app to use a database singleton to abstract the persistence specifics from the app, and then changed the persistence back-end to use UIDocuments with autosaving, which seemed to be an easier, supported path to the cloud.  And I learned a lot about UIDocuments and autosaving in the process.

I was very close to having what I wanted, just waiting to flesh out the cloud integration, but then WWDC2019 happened.  I saw two things: CoreData and CloudKit working together (which I had really wanted a long time ago) and SwiftUI (that was a BIG WOW). 

I have since rebuilt that app in UIKit with CoreData (it was easier than you think -- I had done it before), as well as added a new capability, and I am now actively building the project in parallel in SwiftUI.  But I ran into a few roadblocks (e.g., where's CollectionView, etc.) and kept finding myself with the same basic visual updating issues that have been discussed above.  So I am glad I built Shopping List (again, I had a need since I was doing almost all of the shopping during the pandemic) and confronted these issues. 

So far,  WWDC2020 has given me more than enough so I can move forward and eventually take that other app to the App Store.

Feel free to contact me about questions and comments.
