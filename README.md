#  About "ShoppingList"

My Last Update was **May 24, 2020**.

This is a simple, in-progress iOS app development project using SwiftUI to process a shopping list that you can take to the grocery store with you, and swipe off the items as you pick them up.  It persists data in CoreData.

I'm making this repo publicly available, mostly because I think i'll want to ask some questions (e.g., in the Apple Developer forums, on the HackingWithSwift forums) -- and it's easier to do that if I expose all the source for inspection.  However, be warned: 

* the project source is likely to change often, sometimes even more than once a day; and 
* this is reasonably stable and does pretty much work as I suggest as of today (I really do use it myself when I go shopping) - but I have run into a number of either errors of my own in learning/using SwiftUI, or when I find what I see as shortcomings of SwiftUI.  I really am hoping things improve at WWDC20.

That said ...

## General App Structure

The main screen is a TabView, to show either a current shopping list, a list of previously purchased items, or a list of "locations" in a store, such as "Dairy," "Fruits & Vegetables," "Deli," and so forth.  The CoreData model has only two entities named "ShoppingItem" and "Location," with every ShoppingItem having a to-one relationship to a location (the inverse is to-many).

ShoppingItems have an id (UUID), a name, a quantity, and a boolean "onList" that indicates whether the item is on the list for today's shopping exercise, or not on the list (and so available in the purchased list for future promotion to the shopping list).  

Locations have an id (UUID), a name, a visitationOrder (an integer, as in, go to the dairy first, then the deli, then the canned vegetables, etc), and then values red, green, blue, opacity to define a color that is used to color every item listed in the shopping list.

The opening tab view shows the current shopping items; the second tab shows a list of items that have previously been purchased and are not on today's list.  Swiping an item in either list moves it to the other list (exposing an issue in SwiftUI: the swipe UI calls the motion a "Delete," and the view modifier is .onDelete, but nothing is being deleted in this code).  Tapping on any item in either list lets you edit it for name, quantity, and assign/edit the store location in which it is found.

The third tab shows a list of all locations, listed in visitationOrder (an integer from 1...100).  One special Location is the "Unknown Location" which, in programming terms, has the highest of all visitationOrder values, so that it comes last in the list of Locations, and shopping items with an unassigned/unknown location will come at the bottom of the shopping list.  Tapping on a Location in the list lets you edit location information, including reassigning the visitation order. QUESTION: Why not let the user drag the Locations around to reset the order -- well, it's partly a SwiftUI thing, but persisting the order the way I'd like to do (using visitationOrder markers) has a few wrinkles that seem to conflict with SwiftUI's @FetchRequest.

The shopping list is sorted by the visitation order of the location in which it is found (and alphabetically within each Location).  Items in the shopping list cannot be otherwise re-ordered.  QUESTION: Why don't you let me drag these items to reorder them, you ask?  Why can't you section this list out? Well, I did the reordering thing one time, and dicovered that moving items around in a list in SwiftUI is an absolutely horrific user-experience when you have 30 or 40 items on the list -- so I don't so that anymore.  And i tried the sectioning thing (you'll see some commented-out code that "almost" does this right), but you cannot drag an item from one section to another; i cannot control the section header appearance (it takes way too much space in groupedListStyle and i'd like to customize it); and when items are moved from one section to another (by editing the shopping item), the shopping list sectioning goes nuts if a section becomes empty.



## Some Things I'm Fighting With

* Moving items around in a list in SwiftUI is a real, visual nightmare.  Items resize, the item you press on may move underneath you as does the list itself, sometimes the last item will just not move, etc.
* Constantly struggling with visual updates.  For example, this is the classic update problem: say List A has an array of (CoreData) objects.  Tap on an item in List A, navigate to ViewB in which you can edit the fields of the object, save the changes to CoreData, then return to ListA -- only to find that data for the object has not been updated.  Now I know about @ObservedObject and such, and i have mostly everything working correctly right now.  But I've had to come up with a few  strategies to make things work, yet none seems in the spirit of SwiftUI. You may see a comment or two in the code about this.
* Viewing the ShoppingList in Sections by Location.  Yes, I know how to do this, generally, and have tried it in this project and elsewhere with SwiftUI.  But this involves some fancy rewriting to support the List/ForEach/Section/ForEach structures needed; and besides, you can't drag from one section to another in a SwiftUI list.  (It would be so much easier to handle this in UIKit.)  So my current working idea: sort the shopping list by the visitationOrder of each item's location and provide different coloring for the sections -- it's not ideal (but I am learning more about SwiftUI in the process).
* Tempering my view that SwifUI is, as of right now, some combination of a future direction of programming, a decent prototyping tool, and beta software.  Bugs have come and gone (and come back again) since WWDC2019.  Perhaps WWDC2020 will give us SwiftUI 2.0 or something, and then maybe things will look better.

## Where Do Things Go From Here?

The project is what it is -- it's an on-going, out-in-public offering of code that may be of use to some; it might be something you'd like to play with or even develop on your own (fixing some things that are currently broken, or adding better design elements); or it might be something you'll look at and realize you've done something similar and run into similar problems.

I place no claim to copyright on this material (all of the code is original, it did not come from someone else, and It's yours if you want it).

By the way: what you see today may not look anything like what it looks like tomorrow.  I've already gotten something to work, then found it didn't work from there, and I've gone back and re-architected.  The CoreData model has changed 3 or four times -- but I do not rely on data migrations (yes, they were working correctly), but at this stage, it's easier to just dump the database as JSON; delete the app; change the data model; and reload the data in code at startup.  you'll find the code to do this in Global.swift, along with two booleans to control whether to load at startup if the database is empty, and whether data should be dumped at startup. (note: "dump" means to write out all the JSON to a file on my Mac's desktop if i am running in the simulator, or to print to the console if i'm running on a device.)

Feel free to contact me about questions and comments.
