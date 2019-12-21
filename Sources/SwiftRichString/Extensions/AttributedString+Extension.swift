//
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
#if os(OSX)
import AppKit
#else
import UIKit
#endif

//MARK: - AttributedString Extension

// The following methods are used to alter an existing attributed string with attributes specified by styles.
public extension AttributedString {
	
	/// Append existing style's attributed, registered in `StyleManager`, to the receiver string (or substring).
	///
	/// - Parameters:
	///   - style: 	valid style name registered in `StyleManager`.
	///				If invalid, the same instance of the receiver is returned unaltered.
	///   - range: 	range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: 	same instance of the receiver with - eventually - modified attributes.
	@discardableResult
	func add(style: String, range: NSRange? = nil) -> AttributedString {
		guard let style = Styles[style] else { return self }
		return style.add(to: self, range: range)
	}
	
	/// Append ordered sequence of styles registered in `StyleManager` to the receiver.
	/// Styles are merged in order to produce a single attribute dictionary which is therefore applied to the string.
	///
	/// - Parameters:
	///   - styles: ordered list of styles to apply.
	///   - range: 	range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: 	same instance of the receiver with - eventually - modified attributes.
	@discardableResult
	func add(styles: [String], range: NSRange? = nil) -> AttributedString {
		guard let styles = Styles[styles] else { return self }
		return styles.mergeStyle().set(to: self, range: range)
	}
	
	/// Replace any existing attributed string's style into the receiver/substring of the receiver
	/// with the style which has the specified name and is registered into `StyleManager`.
	///
	/// - Parameters:
	///   - style: style name to apply. Style instance must be registered in `StyleManager` to be applied.
	///   - range: 	range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: 	same instance of the receiver with - eventually - modified attributes.
	@discardableResult
	func set(style: String, range: NSRange? = nil) -> AttributedString {
		guard let style = Styles[style] else { return self }
		return style.set(to: self, range: range)
	}
	
	/// Replace any existing attributed string's style into the receiver/substring of the receiver
	/// with a style which is an ordered merge of styles passed.
	/// Styles are passed as name and you must register them into `StyleManager` before using this function.
	///
	/// - Parameters:
	///   - styles: styles name to apply. Instances must be registered into `StyleManager`.
	///   - range: 	range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: 	same instance of the receiver with - eventually - modified attributes.
	@discardableResult
	func set(styles: [String], range: NSRange? = nil) -> AttributedString {
		guard let styles = Styles[styles] else { return self }
		return styles.mergeStyle().set(to: self, range: range)
	}
	
	/// Append passed style to the receiver.
	///
	/// - Parameters:
	///   - style: style to apply.
	///   - range: 	range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: 	same instance of the receiver with - eventually - modified attributes.
	@discardableResult
	func add(style: StyleProtocol, range: NSRange? = nil) -> AttributedString {
		return style.add(to: self, range: range)
	}
	
	/// Append passed sequences of styles to the receiver.
	/// Sequences are merged in order in a single style's attribute which is therefore applied to the string.
	///
	/// - Parameters:
	///   - styles: styles to apply, in order.
	///   - range: 	range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: 	same instance of the receiver with - eventually - modified attributes.
	@discardableResult
	func add(styles: [StyleProtocol], range: NSRange? = nil) -> AttributedString {
		return styles.mergeStyle().add(to: self, range: range)
	}
	
	/// Replace the attributes of the string with passed style.
	///
	/// - Parameters:
	///   - style: style to apply.
	///   - range: 	range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: 	same instance of the receiver with - eventually - modified attributes.
	@discardableResult
	func set(style: StyleProtocol, range: NSRange? = nil) -> AttributedString {
		return style.set(to: self, range: range)
	}
	
	/// Replace the attributes of the string with a style which is an ordered merge of passed
	/// styles sequence.
	///
	/// - Parameters:
	///   - styles: ordered list of styles to apply.
	///   - range: 	range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: 	same instance of the receiver with - eventually - modified attributes.
	@discardableResult
	func set(styles: [StyleProtocol], range: NSRange? = nil) -> AttributedString {
		return styles.mergeStyle().set(to: self, range: range)
	}
	
	/// Remove passed attribute's keys from the receiver.
	///
	/// - Parameters:
	///   - keys: attribute's keys to remove.
	///   - range: 	range of substring where style will be removed, `nil` to use the entire string.
	/// - Returns: 	same instance of the receiver with - eventually - modified attributes.
	@discardableResult
	func removeAttributes(_ keys: [NSAttributedString.Key], range: NSRange) -> Self {
		keys.forEach { self.removeAttribute($0, range: range) }
		return self
	}
	
	/// Remove all keys defined into passed style from the receiver.
	///
	/// - Parameter style: style to use.
	/// - Returns: 	same instance of the receiver with - eventually - modified attributes.
	func remove(_ style: StyleProtocol) -> Self {
		self.removeAttributes(Array(style.attributes.keys), range: NSMakeRange(0, self.length))
		return self
	}
	
}

//MARK: - Operations

/// Merge two attributed string in a single new attributed string.
///
/// - Parameters:
///   - lhs: attributed string.
///   - rhs: attributed string.
/// - Returns: new attributed string concatenation of two strings.
public func + (lhs: AttributedString, rhs: AttributedString) -> AttributedString {
	let final = NSMutableAttributedString(attributedString: lhs)
	final.append(rhs)
	return final
}

/// Merge a plain string with an attributed string to produce a new attributed string.
///
/// - Parameters:
///   - lhs: plain string.
///   - rhs: attributed string.
/// - Returns: new attributed string.
public func + (lhs: String, rhs: AttributedString) -> AttributedString {
	let final = NSMutableAttributedString(string: lhs)
	final.append(rhs)
	return final
}

/// Merge an attributed string with a plain string to produce a new attributed string.
///
/// - Parameters:
///   - lhs: attributed string.
///   - rhs: plain string.
/// - Returns: new attributed string.
public func + (lhs: AttributedString, rhs: String) -> AttributedString {
	let final = NSMutableAttributedString(attributedString: lhs)
	final.append(NSMutableAttributedString(string: rhs))
	return final
}
