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
	var attributes: [NSAttributedStringKey : Any] { get }
	
	func set(to source: String, range: NSRange?) -> AttributedString
	func add(to source: AttributedString, range: NSRange?) -> AttributedString
	func set(to source: AttributedString, range: NSRange?) -> AttributedString
	func remove(from source: AttributedString, range: NSRange?) -> AttributedString
}

public extension StyleProtocol {
	
	func set(to source: String, range: NSRange?) -> AttributedString {
		guard let range = range else { // apply to entire string
			return NSMutableAttributedString(string: source, attributes: self.attributes)
		}
		let attributedText = NSMutableAttributedString(string: source)
		attributedText.setAttributes(self.attributes, range: range)
		return attributedText
	}
	
	func add(to source: AttributedString, range: NSRange?) -> AttributedString {
		source.addAttributes(self.attributes, range: (range ?? NSMakeRange(0, source.length)))
		return source
	}
	
	func set(to source: AttributedString, range: NSRange?) -> AttributedString {
		source.setAttributes(self.attributes, range: (range ?? NSMakeRange(0, source.length)))
		return source
	}
	
	func remove(from source: AttributedString, range: NSRange?) -> AttributedString {
		self.attributes.keys.forEach({
			source.removeAttribute($0, range: (range ?? NSMakeRange(0, source.length)))
		})
		return source
	}
	
}
