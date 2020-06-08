#  About "ShoppingList"

My Last Update of note was **June 8, 2020**, when 
* I started releasing some snippets of code for dynamically sectioning the shopping list with GroupedListStyle(), 
* I fixed a bug related to moving items from the *filtered* purchased item list to the shopping list, 
* I fixed a startup bug where the program would crash in some cases, so you really can use this without having to load sample data from json, and 
* ~~I put in a work-around for a subtle edge-case bug.~~ This bug has been fixed, finally.

* * * * * *

This is a simple, in-progress iOS app development project using SwiftUI to process a shopping list that you can take to the grocery store with you, and swipe off the items as you pick them up.  It persists data in CoreData.

I'm making this repo publicly available.  I may be interested in asking some questions about what I am doing (e.g., in the Apple Developer forums, on the HackingWithSwift forums), and it's easier to do that if I expose all the source for inspection.  There was also a recent question on the Apple Developer's forum, *[Example using Core Data between views](https://forums.developer.apple.com/thread/133370)* that expressed some frustration in not being able to find enough examples of working with CoreData and getting list updates done correctly (that whole thing about Identifiable, id:\.self, @ObservedObject, etc).  My hope is this project will fill some of that need, even if it's not yet demonstrated to be 100% bullet-proof.

However, be warned: 

* the project source is likely to change often -- this is an ongoing project for me get more familiar with SwiftUI; 
* there may be errors in the code, or some areas of the code might need help with regard to best practices; yet
* this is reasonably stable and does pretty much work as I suggest as of today (I really do use it myself when I go shopping).

Note. The SearchBarView that I added today in the Purchased items view was created by Simon Ng.  It appeared in an article in AppCoda and is copyright © 2020 by AppCoda. You can find it on GitHub under AppCoda/SwiftUISearchBar.  Otherwise, all of the code is original,  and It's yours if you want it -- please see LICENSE for the usual details and disclaimers.

That said ...

## General App Structure

The main screen is a TabView, to show either a current shopping list, a list of previously purchased items, or a list of "locations" in a store, such as "Dairy," "Fruits & Vegetables," "Deli," and so forth.  The CoreData model has only two entities named "ShoppingItem" and "Location," with every ShoppingItem having a to-one relationship to a location (the inverse is to-many).

ShoppingItems have an id (UUID), a name, a quantity, and a boolean "onList" that indicates whether the item is on the list for today's shopping exercise, or not on the list (and so available in the purchased list for future promotion to the shopping list).    They currently also have a visitationOrder, that mirrors the visitationOrder of the Location to which they are assigned -- you'll see a comment in the code about why this is done.

Locations have an id (UUID), a name, a visitationOrder (an integer, as in, go to the dairy first, then the deli, then the canned vegetables, etc), and then values red, green, blue, opacity to define a color that is used to color every item listed in the shopping list.

* A note on color.  There are some ColorPickers out there that could be used and i have tried one, but i'm hoping this arrives in SwiftUI 2.0.  Individually adjusting RGB and opacity is not the best UI.  

Swiping an item in either the shopping list or the already-purchased list moves it to the other list.  This exposes an issue in SwiftUI: the swipe UI calls the motion a "Delete," and the view modifier is .onDelete, but nothing is being deleted in this case.  i know about a contextMenu as an option, but i'd rather swipe now and wait for SwiftUI 2.0 to let me do this with a swipe with the right name.  Tapping on any item in either list lets you edit it for name, quantity, and assign/edit the store location in which it is found.

* by the way, how do you really delete a ShoppingItem?  go to the Edit/Modify View and tap the Delete button. (same for deleting Locations ...)  ~~However, there is a latent bug I'm still trying to work out, although I have put together a work-around for it in the code so that I don't think you'll see its effect.~~

The third tab shows a list of all locations, listed in visitationOrder (an integer from 1...100).  One special Location is the "Unknown Location" which serves as the default location for all new items, which means "I don't really know where this item is yet, but I'll figure it out at the store." In programming terms, this location has the highest of all visitationOrder values, so that it comes last in the list of Locations, and shopping items with an unassigned/unknown location will come at the bottom of the shopping list.  

Tapping on a Location in the list lets you edit location information, including reassigning the visitation order. 

* Why not let the user drag the Locations around to reset the order -- well, it's partly a SwiftUI thing with .onMove(), but persisting the order the way I'd like to do (using visitationOrder markers) has a few wrinkles that seem to conflict with SwiftUI's @FetchRequest.

The shopping list is sorted by the visitation order of the location in which it is found (and alphabetically within each Location).  Items in the shopping list cannot be otherwise re-ordered, although all items in the same Location have the same color as a form of grouping.

* Why don't you let me drag these items to reorder them, you ask?  Well, I did the reordering thing one time, and discovered that moving items around in a list in SwiftUI is an absolutely horrific user-experience when you have 30 or 40 items on the list -- so I don't so that anymore.  
* The current code offers you the choice to see the shopping list either as one big list (use ShoppingListTabView1) or a sectioned-list with GroupedListStyle (use ShoppingListTabView2).  both seem to work fine, ~~but with one edge-case bug still unresolved, but the code does have a work-around (see below and in the code)~~.
* About color: using color to distinguish different Locations is not a good UI, since a significant portion of users either cannot distinguish color or choose visually compatible colors very well. 

If you plan to play with or use this app, the app will start with an empty shopping list; from there you can create your own shopping items and locations associated with those items.  That's always a problem: to get the sense of the app, you really want some data to work with.  There's a boolean defined in Development.swift that, if set to true, will load up a sample shopping list with store locations at startup.


## Some Things I'm Working On

* With this update, i provide two options for the ShoppingListTabView, named, suprisingly, ShoppingListTabView1 and ShoppingListTabView2.  Just change the MainView code to use one or the other.  The latter is what I am working on, so that's what I have coded in MainView, but if you're poking around in the code, try each one of them.
* **ShoppingListTabView1** is a single list of items as described above, with items listed by their location's visitationOrder (and then alphabetically for each location).  Since Locations have different colors, the list is manageable, but not ideal.  
**NEW: ShoppingListTabView2** is an alternative view with the list of items parceled out into **sections** with listStyle = GroupedListStyle.  After about 3,000 attempts and coding and recoding, this version seems to be working almost pretty well so far. 
* I still get a few console messages at runtime about tables laying out outside the view hierarchy, and one that's come up recently of "Trying to pop to a missing destination." (current set-up is XCode 11.5, simulator & myiPhone on iOS13.5, and MacOS 10.15.5). I'm ignoring them for now, until the next iteration of SwiftUI. Several internet comments out there seem to be saying that's the right thing to do for now.
* Moving items around in a list in SwiftUI by dragging (using .onMove() is a real, visual nightmare).  If you've tried .onMove(), you'll see that dragged items resize, the item you press on may move underneath you as does the list itself, sometimes the last item will just not move, etc.
* I have been constantly struggling with visual updates in putting this together.  For example, this is the classic update problem: say List A has an array of (CoreData) objects.  Tap on an item in List A, navigate to View B in which you can edit the fields of the object, save the changes to CoreData, then return to List A -- only to find that data for the object has not been visually updated.  The current code is working quite fine on visual updating -- I finally seem to have found the right mix of when @ObservedObect is necessary and when it isn't. You may see a comment or two in the code about this.
* If you've got a List with a ForEach, and if you collect the visual code inside the ForEach into another, smaller View  (like a RowView(for: item) to keep the code readable), beware the updating issue mentioned above.  You really want to pass along an ObservableObject or Binding to be sure that visual updates are made in the RowView.
* I'm trying to get the right viewpoint on what is SwifUI.  It seems to be a combination of a future direction of iOS et. al. programming, a decent prototyping tool for now, and beta software with  limitations.  Paul Hudson (@twostraws, hackingwithswift.com) and other top devs he's interviewed recently all seem to think of SwiftUI as the future, so this project is my getting me ready for what's next.  
* Bugs have come and gone in SwiftUI (and come back again) since WWDC2019.  Perhaps WWDC2020 will give us SwiftUI 2.0 or something, and then maybe things will look better.  and in comparison with the introduction of Swift itself -- i doubt there were few apps that were pure Swift1.0; but these days, almost every new project will be done in Swift.

## Anything Else?

The project is what it is -- it's an on-going, out-in-public offering of code that may be of use to some; it might be something you'd like to play with or even develop on your own (fixing some things that are currently broken, or adding better design elements); or it might be something you'll look at and realize you've done something similar and run into similar problems.

By the way: what you see today may not look anything like what it looks like tomorrow.  I've already had cases of getting something to work, then found it didn't work after the next change, and I've gone back and re-architected.  The CoreData model has changed 3 or four times -- but I do not rely on data migrations (yes, they were working correctly and I've done them in other projects), but at this stage, it's easier to just dump the database as JSON; delete the app; change the data model; and reload the data in code at startup (which may require some coding changes to the code that loads it).  you'll find the code to do this in Development.swift, along with two booleans to control whether to load at startup if the database is empty, and whether data should be dumped at startup. (note: "dump" means to write out all the JSON to a file on my Mac's desktop if i am running in the simulator, or to print to the console if i'm running on a device.)

Finally, a story. I have another sizeable UIKit-based project, completely unrelated to this Shopping List project, that I had every intention of moving to the App Store. But it lacked a couple of features (mostly synching with the Cloud across devices). And curiously, I had originally used CoreData to persist data when i started building it, when there was some cloud integration; but Apple pulled the rug out on it's sort-of-support for the cloud with CoreData somewhere around iOS 10.  So I rearchitected the app to use a database singleton to abstract the persistence specifics from the app, and then changed the persistence back-end to use UIDocuments with autosaving, which seemed to be an easier, supported path to the cloud.

I was very close to having what I wanted, but then WWDC2019 happened.  I saw two things: CoreData and CloudKit working together (which I had really wanted a long time ago) and SwiftUI (that was a BIG WOW). I have since rebuilt that app with CoreData (it was easier than you think -- I had done it before), and I am now actively building the project in parallel in SwiftUI.  But I ran into a few roadblocks (e.g., where's CollectionView, etc.) and kept finding myself with the same basic visual updating issues that have been discussed above.  So I am glad I built Shopping List (again, I had a need since I was doing almost all of the shopping during the pandemic) and confronted these same issues. I am waiting for WWDC2020 and Swift 2.0 that I can move forward and eventually take that app to the App Store.

Feel free to contact me about questions and comments.
