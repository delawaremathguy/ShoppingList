//
//  Bundle+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 5/15/20.
//

import Foundation

extension Bundle {
	
	// code courtesy of/copyright Paul Hudson (hackingwithswift.com, github.com/twostraws, @twostraws)
	// -- greatly simplifies loading json files from
	// the app bundle.  note that this code throws a fatal error if there's a problem,
	// under the thinking that the file we're reading must be there and this cannot fail.
	// if it does fail, we want to know about it.  additionally, Paul recently added a number of
	// catch handlers which might be helpful in diagnosing possible failures.
	
	func decode<T: Decodable>(from filename: String) -> T {
		
		guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
			fatalError("Failed to locate \(filename) in app bundle.")
		}
		
		guard let data = try? Data(contentsOf: url) else {
			fatalError("Failed to load \(filename) in app bundle.")
		}
		
		let decoder = JSONDecoder()
		
		do {
			return try decoder.decode(T.self, from: data)
		} catch DecodingError.keyNotFound(let key, let context) {
			fatalError("Failed to decode \(filename) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
		} catch DecodingError.typeMismatch(_, let context) {
			fatalError("Failed to decode \(filename) from bundle due to type mismatch – \(context.debugDescription)")
		} catch DecodingError.valueNotFound(let type, let context) {
			fatalError("Failed to decode \(filename) from bundle due to missing \(type) value – \(context.debugDescription)")
		} catch DecodingError.dataCorrupted(_) {
			fatalError("Failed to decode \(filename) from bundle because it appears to be invalid JSON")
		} catch {
			fatalError("Failed to decode \(filename) from bundle: \(error.localizedDescription)")
		}
	}

}
