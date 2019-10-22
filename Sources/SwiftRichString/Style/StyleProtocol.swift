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

public typealias AttributedString = NSMutableAttributedString

public protocol StyleProtocol: class {
	
	/// Return the attributes of the style in form of dictionary `NSAttributedStringKey`/`Any`.
	var attributes: [NSAttributedString.Key : Any] { get }
	
	/// Font unique attributes dictionary.
	var fontData: FontData? { get }
	
	func set(to source: String, range: NSRange?) throws -> AttributedString
	
	func add(to source: AttributedString, range: NSRange?) throws -> AttributedString
	
	@discardableResult
	func set(to source: AttributedString, range: NSRange?) throws -> AttributedString
	
	@discardableResult
	func remove(from source: AttributedString, range: NSRange?) throws -> AttributedString
}

public extension StyleProtocol {
	
	func set(to source: String, range: NSRange?) throws -> AttributedString {
		let attributedText = NSMutableAttributedString(string: source)
		self.fontData?.addAttributes(to: attributedText, range: nil)
		attributedText.addAttributes(self.attributes, range: (range ?? NSMakeRange(0, attributedText.length)))
		return attributedText
	}
	
	func add(to source: AttributedString, range: NSRange?) throws -> AttributedString {
		self.fontData?.addAttributes(to: source, range: range)
		source.addAttributes(self.attributes, range: (range ?? NSMakeRange(0, source.length)))
		return source
	}
	
	@discardableResult
	func set(to source: AttributedString, range: NSRange?) throws -> AttributedString {
		self.fontData?.addAttributes(to: source, range: range)
		source.addAttributes(self.attributes, range: (range ?? NSMakeRange(0, source.length)))
		return source
	}
	
	@discardableResult
	func remove(from source: AttributedString, range: NSRange?) throws -> AttributedString {
		self.attributes.keys.forEach({
			source.removeAttribute($0, range: (range ?? NSMakeRange(0, source.length)))
		})
		return source
	}
	
}
