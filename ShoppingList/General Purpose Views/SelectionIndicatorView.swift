//
//  SelectionIndicatorView.swift
//  ShoppingList
//
//  Created by Jerry on 10/7/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// this is the most recent addition to the project.  it could use some cleaning to make this a more
// general kind of thing, but at this point in the project, that's not my goal

struct SelectionIndicatorView: View {
	var selected: Bool
	var animationDuration: Double = 0.5
	var uiColor: UIColor
	var sfSymbolName = "purchased"
	var body: some View {
		ZStack {
			if selected {
				Image(systemName: "circle.fill")
					.foregroundColor(.blue)
					.font(.title)
			}
			Image(systemName: "circle")
				.foregroundColor(Color(uiColor))
				.font(.title)
			if selected {
				Image(systemName: sfSymbolName)
					.foregroundColor(.white)
					.font(.subheadline)
			}
		}
		.animation(Animation.easeInOut(duration: animationDuration))
		.frame(width: 24, height: 24)
	}
}

struct SelectionIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
			SelectionIndicatorView(selected: true, uiColor: UIColor.black)
    }
}
