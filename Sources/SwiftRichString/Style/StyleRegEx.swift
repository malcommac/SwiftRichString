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

/// StyleRegEx allows you to define a style which is applied when one or more regular expressions
/// matches are found in source string or attributed string.
public class StyleRegEx: StyleProtocol {
	
	//MARK: - PROPERTIES
	
	/// Regular expression
	public private(set) var regex: NSRegularExpression
	
	/// Base style. If set it will be applied in set before any match.
	public private(set) var baseStyle: StyleProtocol?
	
	/// Applied style
	private var style: StyleProtocol
	
	/// Style attributes
	public var attributes: [NSAttributedString.Key : Any] {
		return self.style.attributes
	}
	
    public var textTransforms: [TextTransform]?
    
	/// Font attributes
	public var fontData: FontData? {
		return self.style.fontData
	}
	
	//MARK: - INIT
	
	/// Initialize a new regular expression style matcher.
	///
	/// - Parameters:
	///   - base: base style. it will be applied (in set or add) to the entire string before any other operation.
	///   - pattern: pattern of regular expression.
	///   - options: matching options of the regular expression; if not specified `caseInsensitive` is used.
	///   - handler: configuration handler for style.
	public init?(base: StyleProtocol? = nil,
				 pattern: String, options: NSRegularExpression.Options = .caseInsensitive,
				 handler: @escaping Style.StyleInitHandler) {
		do {
			self.regex = try NSRegularExpression(pattern: pattern, options: options)
			self.baseStyle = base
			self.style = Style(handler)
		} catch {
			return nil
		}
	}
	
	//MARK: - METHOD OVERRIDES
	
	public func set(to source: String, range: NSRange?) -> AttributedString {
		let attributed = NSMutableAttributedString(string: source, attributes: (self.baseStyle?.attributes ?? [:]))
		return self.applyStyle(to: attributed, add: false, range: range)
	}
	
	public func add(to source: AttributedString, range: NSRange?) -> AttributedString {
		if let base = self.baseStyle {
			source.addAttributes(base.attributes, range: (range ?? NSMakeRange(0, source.length)))
		}
		return self.applyStyle(to: source, add: true, range: range)
	}
	
	public func set(to source: AttributedString, range: NSRange?) -> AttributedString {
		if let base = self.baseStyle {
			source.setAttributes(base.attributes, range: (range ?? NSMakeRange(0, source.length)))
		}
		return self.applyStyle(to: source, add: false, range: range)
	}
	
	//MARK: - INTERNAL FUNCTIONS
	
	/// Regular expression matcher.
	///
	/// - Parameters:
	///   - str: attributed string.
	///   - add: `true` to append styles, `false` to replace existing styles.
	///   - range: range, `nil` to apply the style to entire string.
	/// - Returns: modified attributed string
	private func applyStyle(to str: AttributedString, add: Bool, range: NSRange?) -> AttributedString {
		let rangeValue = (range ?? NSMakeRange(0, str.length))
		
		let matchOpts = NSRegularExpression.MatchingOptions(rawValue: 0)
		self.regex.enumerateMatches(in: str.string, options: matchOpts, range: rangeValue) {
			(result : NSTextCheckingResult?, _, _) in
			if let r = result {
				if add {
					str.addAttributes(self.attributes, range: r.range)
				} else {
					str.setAttributes(self.attributes, range: r.range)
				}
			}
		}
		
		return str
	}
	
}
