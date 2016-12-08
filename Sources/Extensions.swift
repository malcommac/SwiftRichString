//
//  Extensions.swift
//  SwiftStyler
//
//  Created by Daniele Margutti on 07/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import Foundation

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

public extension String {

	/// Enclose string between passed tag. Tag should not include open/end/close sign, so basically
	/// you need to pass only the name.
	///
	/// - Parameter tag: name of the tag
	/// - Returns: self enclosed between given open/close tag name
	public func add(tag: String) -> String {
		return "<\(tag)>self</\(tag)>"
	}
	
	/// Enclose string between passed tag defined by given Style. Each style is defined with its own name
	/// This name represent the tag itself, so this is a shortcut.
	///
	/// - Parameter style: style to apply
	/// - Returns: self enclosed between given open/close tag name defined in Style
	public func add(tag style: Style) -> String {
		return "<\(style.type.value)>self</\(style.type.value)>"
	}
	
}

//MARK: String Extensions

public extension String {
	
	/// Shortcut to apply attributes to a string and return an NSMutableAttributedString
	///
	/// - Parameters:
	///   - style: style to apply
	///   - range: range to apply (nil means entire string's range)
	/// - Returns: an NSMutableAttributedString instance
	public func apply(_ style: Style, range: Range<Int>? = nil) -> NSMutableAttributedString {
		guard let range = range else { // apply to entire string
			return NSMutableAttributedString(string: self, attributes: style.attributes)
		}
		// create a new attributed string and apply attributes to given range mantaining
		// full unicode support
		let str = NSMutableAttributedString(string: self)
		str.addAttributes(style.attributes, range: self.toNSRange(from: range))
		return str
	}
	
}

//MARK: String Extensions for Ranges

public extension String {
	
	public func styled(_ styles: Style...) -> RichString {
		return RichString(self, styles)
	}
	
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
