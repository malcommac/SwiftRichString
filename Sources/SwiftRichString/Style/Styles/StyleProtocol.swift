//
//  SwiftRichString
//  https://github.com/malcommac/SwiftRichString
//  Copyright (c) 2020 Daniele Margutti (hello@danielemargutti.com).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public typealias AttributedString = NSMutableAttributedString

public protocol StyleProtocol {
	
	/// Return the attributes of the style in form of dictionary `NSAttributedStringKey`/`Any`.
	var attributes: [NSAttributedString.Key : Any] { get }
	
	/// Font unique attributes dictionary.
	var fontStyle: FontStyle? { get }
    
    /// Text transform.
    var textTransforms: [TextTransform]? { get }
    
    @discardableResult
    mutating func set(to source: String, range: NSRange?) -> AttributedString
	
    @discardableResult
    mutating func add(to source: AttributedString, range: NSRange?) -> AttributedString
	
	@discardableResult
    mutating func set(to source: AttributedString, range: NSRange?) -> AttributedString
	
	@discardableResult
    mutating func remove(from source: AttributedString, range: NSRange?) -> AttributedString
}

// MARK: - StyleProtocol Implementation

public extension StyleProtocol {
    
    func set(to source: String, range: NSRange?) -> AttributedString {
        StyleDecorator.set(style: self, to: source, range: range)
    }
    
    func add(to source: AttributedString, range: NSRange?) -> AttributedString {
        StyleDecorator.add(style: self, to: source, range: range)
    }
    
    @discardableResult
    func set(to source: AttributedString, range: NSRange?) -> AttributedString {
        StyleDecorator.set(style: self, to: source, range: range)
    }
    
    @discardableResult
    func remove(from source: AttributedString, range: NSRange?) -> AttributedString {
        StyleDecorator.remove(style: self, from: source, range: range)
    }
    
}
