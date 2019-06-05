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

//MARK: - String Extension

// The following methods are used to produce an attributed string by a plain string.
public extension String {
	
	//MARK: RENDERING FUNCTIONS
	
	/// Apply style with given name defines in global `StylesManager` to the receiver string.
	/// If required style is not available this function return `nil`.
	///
	/// - Parameters:
	///   - style: name of style registered in `StylesManager` singleton.
	///   - range: range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: rendered attributed string, `nil` if style is not registered.
	func set(style: String, range: NSRange? = nil) -> AttributedString? {
		return StylesManager.shared[style]?.set(to: self, range: range)
	}
	
	/// Apply a sequence of styles defied in global `StylesManager` to the receiver string.
	/// Unregistered styles are ignored.
	/// Sequence produces a single merge style where the each n+1 element of the sequence may
	/// override existing key set by previous applied style.
	/// Resulting attributes dictionary is threfore applied to the string.
	///
	/// - Parameters:
	///   - styles: ordered list of styles name to apply. Styles must be registed in `StylesManager`.
	///   - range: range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: attributed string, `nil` if all specified styles required are not registered.
	func set(styles: [String], range: NSRange? = nil) -> AttributedString? {
		return StylesManager.shared[styles]?.mergeStyle().set(to: self, range: range)
	}
	
	/// Apply passed style to the receiver string.
	///
	/// - Parameters:
	///   - style: style to apply.
	///   - range: range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: rendered attributed string.
	func set(style: StyleProtocol, range: NSRange? = nil) -> AttributedString {
		return style.set(to: self, range: range)
	}
	
	/// Apply passed sequence of `StyleProtocol` instances to the receiver.
	/// Sequence produces a single merge style where the each n+1 element of the sequence may
	/// override existing key set by previous applied style.
	/// Resulting attributes dictionary is threfore applied to the string.
	///
	/// - Parameters:
	///   - styles: ordered list of styles to apply. Styles must be registed in `StylesManager`.
	///   - range: range of substring where style is applied, `nil` to use the entire string.
	/// - Returns: attributed string.
	func set(styles: [StyleProtocol], range: NSRange? = nil) -> AttributedString {
		return styles.mergeStyle().set(to: self, range: range)
	}
	
}

//MARK: - Operations

/// Create a new attributed string using + where the left operand is a plain string and left is a style.
///
/// - Parameters:
///   - lhs: plain string.
///   - rhs: style to apply.
/// - Returns: rendered attributed string instance
public func + (lhs: String, rhs: StyleProtocol) -> AttributedString {
	return rhs.set(to: lhs, range: nil)
}

