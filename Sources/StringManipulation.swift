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

/// Sum two MarkupString and produce a new string sum of both passed.
/// Remember: [Style] associated with lhs will be merged with [Style] associated with rhs string and
/// may be replaced when name is the same between two Styles.
///
/// - Parameters:
///   - lhs: left MarkupString
///   - rhs: right MarkupString
/// - Returns: a new MarkupString with the content of both lhs and rhs strings and with merged styles
public func + (lhs: MarkupString, rhs: MarkupString) -> MarkupString {
	let concatenate = MarkupString(lhs.content + rhs.content, nil) // concatenate the content
	concatenate.styles = lhs.styles + rhs.styles // sum styles between lhs and rhs (rhs may replace existing lhs's styles)
	return concatenate
}

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

public func + (lhs: String, rhs: NSMutableAttributedString) -> NSMutableAttributedString {
	let final = NSMutableAttributedString(string: lhs)
	final.append(rhs)
	return final
}

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
		self.append(string.with(style: style))
	}	
	
	/// Append a MarkupString instance to an exesting NSMutableAttributedString (self)
	///
	/// - Parameter string: string to append
	public func append(markup string: MarkupString) {
		self.append(string.text)
	}
	
}
