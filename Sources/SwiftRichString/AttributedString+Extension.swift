//
//  StringManipulation.swift
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
#if os(iOS) || os(tvOS) || os(watchOS)
	import UIKit
#elseif os(OSX)
	import AppKit
#endif

/// Sum between two NSMutableAttributedStrings
///
/// - Parameters:
///   - lhs: left attributed string
///   - rhs: right attributed stirng
/// - Returns: a new instance sum of left and side instances
public func + (lhs: NSMutableAttributedString, rhs: NSMutableAttributedString) -> NSMutableAttributedString {
	let final = NSMutableAttributedString(attributedString: lhs)
	final.append(rhs)
	return final
}


/// Concatenate String and NSMutableAttributedString
///
/// - Parameters:
///   - lhs: simple string
///   - rhs: attributed string to append
/// - Returns: create a new NSMutableAttributedString sum of the two instances
public func + (lhs: String, rhs: NSMutableAttributedString) -> NSMutableAttributedString {
	let final = NSMutableAttributedString(string: lhs)
	final.append(rhs)
	return final
}


/// Concatenate NSMutableAttributedString and String
///
/// - Parameters:
///   - lhs: source attributed string
///   - rhs: simple string to append
/// - Returns: a new instance of NSMutableAttributedString, sum of the two instances
public func + (lhs: NSMutableAttributedString, rhs: String) -> NSMutableAttributedString {
	let final = NSMutableAttributedString(attributedString: lhs)
	final.append(NSMutableAttributedString(string: rhs))
	return final
}

public extension NSMutableAttributedString {
	
	/// Append a plain string with given attributes to an existing NSMutableAttributedString (self)
	///
	/// - Parameters:
	///   - string: string to append
	///   - style: style to apply to the entire string before appending it to self
	public func append(string: String, style: Style) {
		self.append(string.set(style: style))
	}
	
	/// Append a MarkupString instance to an exesting NSMutableAttributedString (self)
	///
	/// - Parameter string: string to append
	public func append(markup string: MarkupString, styles: Style...) {
		self.append(string.render(withStyles: styles))
	}
	
	/// Add a style to an existing instance of attributed string
	///
	/// - Parameters:
	///   - style: style to add
	///   - range: range of characters where add passed style
	/// - Returns: self to allow any chain
	public func add(style: Style, range: Range<String.Index>? = nil) -> NSMutableAttributedString {
		self.addAttributes(style.attributes, range: self.string.nsRange(from: range))
		return self
	}
	
	
	/// Add styles to given attributed string
	/// Note: .default Style is always applied in first place if defined
	///
	/// - Parameter styles: styles to apply
	/// - Returns: self to allow any chain
	public func add(styles: Style...) -> NSMutableAttributedString {
		self.addAttributes(styles.attributesDictionary, range: NSMakeRange(0, self.string.count))
		return self
	}
	
	
	/// Replace any existing attribute at given range with the one passed as input
	///
	/// - Parameters:
	///   - style: style to apply
	///   - range: range to apply
	/// - Returns: self to allow any chain
	public func set(style: Style, range: Range<String.Index>? = nil) -> NSMutableAttributedString {
		self.setAttributes(style.attributes, range: self.string.nsRange(from: range))
		return self
	}
	
	
	/// Replace any existing attribute into string with the list passed as input.
	/// Note: .default Style is always applied in first place if defined
	///
	/// - Parameter styles: styles to apply
	/// - Returns: self to allow any chain
	public func set(styles: Style...) -> NSMutableAttributedString {
		self.setAttributes(styles.attributesDictionary, range: NSMakeRange(0, self.string.count))
		return self
	}
	
	
	/// Remove any existing attribute defined inside given style from passed range
	///
	/// - Parameters:
	///   - style: style to remove
	///   - range: range to remove
	/// - Returns: self to allow any chain
	public func remove(style: Style, range: Range<String.Index>? = nil) -> NSMutableAttributedString {
		style.attributes.keys.forEach({
			self.removeAttribute($0, range: self.string.nsRange(from: range))
		})
		return self
	}

}
