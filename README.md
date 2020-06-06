#  About "ShoppingList"

My Last Update of note was **June 6, 2020**, when I started releasing some snippets of code for dynamically sectioning a list with GroupedListStyle().

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

Swiping an item in either the shopping list or the already-purchased list moves it to the other list (exposing an issue in SwiftUI: the swipe UI calls the motion a "Delete," and the view modifier is .onDelete, but nothing is being deleted in this case.  i know about a contextMenu as an option, but i'd rather swipe now and wait for SwiftUI 2.0 to let me do this with a swipe with the right name.).  Tapping on any item in either list lets you edit it for name, quantity, and assign/edit the store location in which it is found.

* by the way, how do you really delete a ShoppingItem?  go to the Edit/Modify View and tap the Delete button. (same for deleting Locations ...)  However, there is a latent bug I'm still working on: deleting the only, remaining item in either list of shopping items will almost always crash the program.

The third tab shows a list of all locations, listed in visitationOrder (an integer from 1...100).  One special Location is the "Unknown Location" which, in programming terms, has the highest of all visitationOrder values, so that it comes last in the list of Locations, and shopping items with an unassigned/unknown location will come at the bottom of the shopping list.  Tapping on a Location in the list lets you edit location information, including reassigning the visitation order. 

* Why not let the user drag the Locations around to reset the order -- well, it's partly a SwiftUI thing, but persisting the order the way I'd like to do (using visitationOrder markers) has a few wrinkles that seem to conflict with SwiftUI's @FetchRequest.

The shopping list is sorted by the visitation order of the location in which it is found (and alphabetically within each Location).  Items in the shopping list cannot be otherwise re-ordered, although all items in the same Location have the same color as a form of grouping.

* Why don't you let me drag these items to reorder them, you ask?  Well, I did the reordering thing one time, and dicovered that moving items around in a list in SwiftUI is an absolutely horrific user-experience when you have 30 or 40 items on the list -- so I don't so that anymore.  
* Why can't you section this list out, you ask?  i tried the sectioning thing (you'll see some commented-out code that "almost" does this right), but you cannot drag an item from one section to another; i cannot control the section header appearance (it takes way too much space in groupedListStyle and i'd like to customize it); and when items are moved from one section to another (by editing the shopping item), the shopping list sectioning code i'm trying out goes nuts if a section becomes empty.
* About color: using color to distinguish different Locations is not a good UI, since a significant portion of users cannot distinguish color very well.  At some point, I'll go to a true sectioning of items, but I need more help from SwiftUI to do it.


## Some Things I'm Working On

* With this update, i provide two options for the ShoppingListTabView, named, suprisingly, ShoppingListTabView1 and ShoppingListTabView2.  Just change the MainView code to use one or the other.  The latter is what I am working on, so that's what I have coded in MainView, but if you're poking around in the code, try each one of them.
* **ShoppingListTabView1** is a single list of items as described above, with items listed by their location's visitationOrder (and then alphabetically for each location).  Since Locations have different colors, the list is manageable, but not ideal.  Be forewarned: THERE IS A BUG IN THIS CODE: IT CRASHES IF YOU (truly) DELETE THE LAST REMAINING ITEM ON THE LIST (see comments in code about this).
**NEW: ShoppingListTabView2** is an alternative view with the list of items parceled out into **sections** with listStyle = GroupedListStyle.  After about 3,000 attempts and coding and recoding, this version seems to be working almost pretty well so far. Be forewarned: THERE IS A BUG IN THIS CODE: THIS VIEW ALSO CRASHES IF YOU (truly) DELETE THE LAST REMAINING ITEM ON THE LIST (see comments in code about this).
* I still get a few console messages at runtime about tables laying out outside the view hierarchy and so forth; I'm ignoring them for now, until the next iteration of SwiftUI. Several internet comments out there seem to be saying that's the right thing to do for now.
* Moving items around in a list in SwiftUI by dragging (using .onMove()) is a real, visual nightmare.  If you've tried .onMove(), you'll see that dragged items resize, the item you press on may move underneath you as does the list itself, sometimes the last item will just not move, etc.
* I have been constantly struggling with visual updates in putting this together.  For example, this is the classic update problem: say List A has an array of (CoreData) objects.  Tap on an item in List A, navigate to View B in which you can edit the fields of the object, save the changes to CoreData, then return to List A -- only to find that data for the object has not been updated.  I know about @ObservedObject and such, and i have mostly everything working correctly right now.  But I seem to havevisual updated just about all working properly now. You may see a comment or two in the code about this.
* If you've got a List with a ForEach, and if you collect the visual code inside the ForEach into another, smaller View  (like a RowView(for: item) to keep the code readable), beware the updating issue mentioned above.  You really want to pass along an ObservableObject or Binding to be sure that visual updates are made in the RowView.
* Getting a viewpoint on SwifUI.  It seems to be a combination of a future direction of iOS et. al. programming, a decent prototyping tool for now, and beta software with many limitations.  Paul Hudson and other top devs he's interviewed recently all seem to think of SwiftUI as the future, so this project is my getting ready for what's next.
* Bugs have come and gone in SwiftUI (and come back again) since WWDC2019.  Perhaps WWDC2020 will give us SwiftUI 2.0 or something, and then maybe things will look better.  and in comparison with the introduction of Swift itself -- i doubt there were few apps that were pure Swift1.0; but these days, almost every new project will be done in Swift.

## Where Do Things Go From Here?

The project is what it is -- it's an on-going, out-in-public offering of code that may be of use to some; it might be something you'd like to play with or even develop on your own (fixing some things that are currently broken, or adding better design elements); or it might be something you'll look at and realize you've done something similar and run into similar problems.

By the way: what you see today may not look anything like what it looks like tomorrow.  I've already had cases of getting something to work, then found it didn't work after the next change, and I've gone back and re-architected.  The CoreData model has changed 3 or four times -- but I do not rely on data migrations (yes, they were working correctly and I've done them in other projects), but at this stage, it's easier to just dump the database as JSON; delete the app; change the data model; and reload the data in code at startup (which may require some coding changes to the code that loads it).  you'll find the code to do this in Development.swift, along with two booleans to control whether to load at startup if the database is empty, and whether data should be dumped at startup. (note: "dump" means to write out all the JSON to a file on my Mac's desktop if i am running in the simulator, or to print to the console if i'm running on a device.)

Feel free to contact me about questions and comments.
