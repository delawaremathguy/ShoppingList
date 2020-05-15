//
//  Bundle+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 5/15/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

extension Bundle {
	
	// code courtesy of Paul Hudson -- greatly simplifies loading json files from
	// the app bundle.  note that this code throws a fatal error if it there's a problem,
	// under the thinking that the file we're reading must be there and this cannot fail.
	// if it does fail, we want to know about it
	
	func decode<T: Decodable>(from filename: String) -> T {
		
		guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
			fatalError("Failed to locate \(filename) in app bundle.")
		}
		
		guard let data = try? Data(contentsOf: url) else {
			fatalError("Failed to load \(filename) in app bundle.")
		}
		
		let decoder = JSONDecoder()
		
		guard let loadedData = try? decoder.decode(T.self, from: data) else {
			fatalError("Failed to decode \(filename) from app bundle.")
		}
		
		return loadedData
	}
}
