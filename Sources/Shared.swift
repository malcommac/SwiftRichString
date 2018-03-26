//
//  Shared.swift
//  SwiftRichString
//  Elegant Strings & Attributed Strings Toolkit for Swift
//
//  Created by Daniele Margutti.
//  Copyright © 2018 Daniele Margutti. All rights reserved.
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
import UIKit

public typealias Font			= UIFont
public typealias Color 			= UIColor
public typealias FontTraits 	= UIFontDescriptorSymbolicTraits
public typealias RichString 	= NSMutableAttributedString
public typealias RichAttribute 	= NSAttributedStringKey

/// Sum of two `FontTraits` array.
///
/// - Parameters:
///   - lhs: left operand
///   - rhs: right operand
/// - Returns: union of the two traits with priority to right operand.
public func +(lhs: FontTraits, rhs: FontTraits) -> FontTraits {
	return lhs.union(rhs)
}

internal extension FontTraits {
	
	/// Merge two FontTrait
	///
	/// - Parameters:
	///   - lhs: left trait
	///   - rhs: right trait
	/// - Returns: merge with priority to the right operand.
	static func merge(_ lhs: FontTraits?, _ rhs: FontTraits?) -> FontTraits {
		var traits: FontTraits = FontTraits.init(rawValue: 0)
		if let l = lhs { traits.formUnion(l) }
		if let r = rhs { traits.formUnion(r) }
		return traits
	}
	
}


/// Merge two dictionaries.
///
/// - Parameters:
///   - lhs: left dictionary
///   - rhs: right dictionary
/// - Returns: merged values where right side may override values from left.
func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
	var result = lhs
	rhs.forEach{ result[$0] = $1 }
	return result
}

/// Writing direction enum.
///
/// - leftToRightEmbeeding: left -> right, text is embedded in text with another writing direction
/// - rightToLeftEmbeeding: right -> left, Text is embedded in text with another writing direction
/// - leftToRightOverride: left -> right, enables character types with inherent directionality to be overridden when required for special cases, such as for part numbers made of mixed English, digits, and Hebrew letters to be written from right to left.
/// - rightToLeftOverride: right -> left, enables character types with inherent directionality to be overridden when required for special cases, such as for part numbers made of mixed English, digits, and Hebrew letters to be written from right to left.
public enum WritingDirection: Int {
	case leftToRightEmbeeding = 0
	case rightToLeftEmbeeding = 1
	case leftToRightOverride = 2
	case rightToLeftOverride = 3
}

/// Kerning attribute.
///
/// - `default`: kerning disabled.
/// - custom: 	This value specifies the number of points by which to adjust kern-pair characters.
///				Kerning prevents unwanted space from occurring between specific characters and depends on the font.
public enum Kern: RawRepresentable {
	case `default`
	case custom(_: Float)
	
	public typealias RawValue = Float
	public init?(rawValue: Float) {
		switch rawValue {
		case 0:		self = .default
		default:	self = .custom(rawValue)
		}
	}
	
	public var rawValue: Float {
		switch self {
		case .default:			return 0
		case .custom(let v):	return v
		}
	}
	
}

/// Ligature attribute.
/// Ligatures cause specific character combinations to be rendered using a single
/// custom glyph that corresponds to those characters
///
/// - none: No ligatures
/// - `default`: use of the default ligatures
/// - all: use of all ligatures (not supported on iOS)
public enum Ligature: Int {
	case none 		= 0
	case `default` 	= 1
	case all 		= 2
}


/// Sum of two attributed strings
public func +(lhs: RichString, rhs: RichString) -> RichString {
	let newString = NSMutableAttributedString(attributedString: lhs)
	newString.append(rhs)
	return newString
}

/// Sum of an attributed string and a plain string
///
/// - Parameters:
///   - lhs: attributed string is maintained as it is.
///   - rhs: transformed to a rich string using global style attributes.
/// - Returns: concatenation of the strings.
public func +(lhs: RichString, rhs: String) -> RichString {
	return lhs + rhs.set(RichString.globalStyle)
}

/// Sum of a simple string with an attributed string.
///
/// - Parameters:
///   - lhs: lhs is transformed to a rich string using global style attributes.
///   - rhs: right attributed string is maintained as it is.
/// - Returns: concatenation of the strings.
public func +(lhs: String, rhs: RichString) -> RichString {
	return lhs.set(RichString.globalStyle) + rhs
}

/// Sum of a simple string with a `StyleProtocol`. Generate an attributed string with the content
/// of `lhs` and the attributes of the `rhs` style.
///
/// - Parameters:
///   - lhs: simple string
///   - rhs: attributes to apply.
/// - Returns: attributed string.
public func +<T: StyleProtocol>(lhs: String, rhs: T) -> RichString {
	return lhs.set(rhs)
}

/// Sum of two `Style`. Return a third style merge of the two operands.
///
/// - Parameters:
///   - lhs: first operand
///   - rhs: second operand
/// - Returns: merge of the two styles with priority to right operand.
public func +(lhs: Style, rhs: Style) -> Style {
	return lhs.merge(with: rhs)
}

/// Sum of two `StyleGroup`. Return a third style merge of the two operands merge of the attributes of each one.
///
/// - Parameters:
///   - lhs: first operand
///   - rhs: second operand
/// - Returns: merge of the two styles with priority to right operand.
public func +(lhs: StyleGroup, rhs: StyleGroup) -> Style {
	return lhs.merge(with: rhs.style)
}

