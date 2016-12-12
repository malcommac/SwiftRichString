//
//  Extensions.swift
//  SwiftRichString
//  Elegant & Painless Attributed Strings Management Library in Swift
//
//  Created by Daniele Margutti.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//
//	Web: http://www.danielemargutti.com
//	Email: hello@danielemargutti.com
//	Twitter: @danielemargutti
//
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import Foundation

//MARK: Style Array Extension

public extension Array where Element: Style {
	
	internal func defaultStyle() -> (index: Int?, item: Style?) {
		let defaultIndex = self.index(where: {
			if case .default = $0.name { return true }
			return false
		})
		return (defaultIndex != nil ? (defaultIndex!,self[defaultIndex!]) : (nil,nil))
	}
	
	internal var attributesDictionary: [String: Any] {
		guard self.count > 1 else {
			return (self.first?.attributes ?? [:])
		}
		let (_,defStyle) = self.defaultStyle()
		var dictionaries: [String: Any] = defStyle?.attributes ?? [:]
		self.forEach {
			if defStyle != $0 {
				dictionaries.unionInPlace(dictionary: $0.attributes)
			}
		}
		return dictionaries
	}
	
}

//MARK: Dictionary Extension

extension Dictionary {
	mutating func unionInPlace(
		dictionary: Dictionary<Key, Value>) {
		for (key, value) in dictionary {
			self[key] = value
		}
	}
}

/// Merge two arrays by replacing existing lhs values with rhs values when keys collides
///
/// - Parameters:
///   - lhs: lhs dictionary
///   - rhs: rhs dictionary
/// - Returns: merged dictionary
func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
	var result = lhs
	rhs.forEach{ result[$0] = $1 }
	return result
}

//MARK: String Extensions for Ranges

public extension String {
	
	public func toNSRange(from range: Range<Int>) -> NSRange {
		return self.toNSRange(from: self.toStringRange(range: range))
	}
	
	func toNSRange(from range: Range<String.Index>) -> NSRange {
		let from = range.lowerBound.samePosition(in: utf16)
		let to = range.upperBound.samePosition(in: utf16)
		return NSRange(location: utf16.distance(from: utf16.startIndex, to: from), length: utf16.distance(from: from, to: to))
	}
	
	public func toStringRange(range: Range<Int>) -> Range<String.Index> {
		let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
		let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)// - range.lowerBound)
		return Range<String.Index>(uncheckedBounds: (startIndex,endIndex))
	}

	func toStringRange(from nsRange: NSRange) -> Range<String.Index>? {
		guard
			let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
			let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
			let from = String.Index(from16, within: self),
			let to = String.Index(to16, within: self)
			else { return nil }
		return from ..< to
	}
}
