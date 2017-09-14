//
//  String+Extension.swift
//  SwiftRichString
//
//  Created by Daniele Margutti on 12/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
	import UIKit
#elseif os(OSX)
	import AppKit
#endif

//MARK: String Extension (Style)

public extension String {
	
	/// Create a new NSMutableAttributedString instance from given String by applying passed attribute at given range.
	///
	/// - Parameters:
	///   - style: style to apply
	///   - range: range to apply (nil means entire string's range)
	/// - Returns: an NSMutableAttributedString instance
	public func set(style: Style, range: NSRange? = nil) -> NSMutableAttributedString {
		guard let range = range else { // apply to entire string
			return NSMutableAttributedString(string: self, attributes: style.attributes)
		}
		// create a new attributed string and apply attributes to given range mantaining
		// full unicode support
		let attributedText = NSMutableAttributedString(string: self)
		attributedText.addAttributes(style.attributes, range: range)
		return attributedText
	}	
	
	/// Apply attributes in order, as passed. The only exception is .default Style; it will be applied always as first style
	///
	/// - Parameter styles: styles to apply
	/// - Returns: a new attributed string
	public func set(styles: Style...) -> NSMutableAttributedString {
		return self.set(stylesArray: Array(styles))
	}
	
	/// Apply attributes in order, as passed. The only exception is .default Style; it will be applied always as first style
	///
	/// - Parameter styles: styles to apply
	/// - Returns: a new attributed string
	public func set(stylesArray styles: [Style]) -> NSMutableAttributedString {
		let attributedString = NSMutableAttributedString(string: self)
		let range = NSMakeRange(0, attributedString.length)
		attributedString.addAttributes(styles.attributesDictionary, range: range)
		return attributedString
	}
	
	/// Apply style's attributes to given string with pattern matching specified
	///
	/// - Parameters:
	///   - styles: styles to apply
	///   - pattern: pattern to search via regexp
	///   - options: options of pattern matching
	/// - Returns: a new attributed string instance
	public func set(styles: Style..., pattern: String, options: NSRegularExpression.Options = .caseInsensitive) -> NSMutableAttributedString {
		guard let regexp = RegExpPatternStyles(pattern: pattern, opts: options, styles: styles) else {
			return NSMutableAttributedString(string: self)
		}
		return self.set(regExpStyles: [regexp])
	}
	
	/// Defines a set of styles to apply to a plain String by matching a set of regular expressions.
	/// Expressions are evaluated in order, then applied to the string
	///
	/// - Parameters:
	///   - regExpStyles: regular expression array to apply in order
	///   - default: optional default style to apply in first place before evaluating all expressions
	/// - Returns: a parsed attributed string
	public func set(regExpStyles: [RegExpPatternStyles], default dStyle: Style? = nil) -> NSMutableAttributedString {
		let attr_str = (dStyle != nil ? self.set(style: dStyle!) : NSMutableAttributedString(string: self))
		let allRange = Range<String.Index>(uncheckedBounds: (self.startIndex,self.endIndex))
		
		regExpStyles.forEach { regExp in
			regExp.regularExpression.enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: self.nsRange(from: allRange)) {
				(result : NSTextCheckingResult?, _, _) in
				if let r = result {
					attr_str.addAttributes(regExp.styles.attributesDictionary, range: r.range)
				}
			}
		}
		return attr_str
	}
}

//MARK: String Extension (MarkupString)

public extension String {
	
	/// Parse an tagged style string and apply passed style by returning an attributed string
	///
	/// - Parameter styles: styles to apply
	/// - Returns: attributed string, nil if parse fails
	public func renderTags(withStyles styles: [Style]) -> NSMutableAttributedString? {
		return MarkupString(source: self)?.render(withStyles: styles)
	}
	
	/// Create a new MarkupString by parsing the content of self string and apply given styles
	///
	/// - Parameter styles: styles to apply
	/// - Returns: a new MarkupString instances, nil if parsing fails
	public func parse(andSet styles: Style...) -> MarkupString? {
		return MarkupString(source: self, styles: styles)
	}
	
	
	/// Parse content of tagged source string and store it in a MarkupString instance you can use to render
	/// the content using passed style via .render() functions.
	///
	/// - Returns: a new instance of MarkupString
	/// - Throws: throws if parse fail
	public func parse() -> MarkupString? {
		return MarkupString(source: self)
	}
	
	/// Enclose string between passed tag. Tag should not include open/end/close sign, so basically
	/// you need to pass only the name.
	///
	/// - Parameter tag: name of the tag
	/// - Returns: self enclosed between given open/close tag name
	public func tagged(_ tag: String) -> String {
		return "<\(tag)>\(self)</\(tag)>"
	}
	
	/// Enclose string between passed tag defined by given Style. Each style is defined with its own name
	/// This name represent the tag itself, so this is a shortcut.
	///
	/// - Parameter style: style to apply
	/// - Returns: self enclosed between given open/close tag name defined in Style
	public func tagged(_ style: Style) -> String {
		return "<\(style.name.value)>\(self)</\(style.name.value)>"
	}
	
	
	/// Enclose pattern matched strings in self with specified tag and return tagged string.
	///
	/// - Parameters:
	///   - style: style to apply
	///   - pattern: pattern to search for content to enclose in tag
	///   - options: options for pattern mathing
	/// - Returns: enclosed string
	public func tagged(_ style: Style, pattern: String, options: NSRegularExpression.Options = .caseInsensitive) -> String {
		do {
			var taggedString = self
			let regex = try NSRegularExpression(pattern: pattern, options: options)
			let allRange = Range<String.Index>(uncheckedBounds: (self.startIndex,self.endIndex))
			let matches = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0),
			                            range: self.nsRange(from: allRange))
			matches.reversed().forEach({ r in
				let cRg = Range(r.range, in: self)!
				let substringToEnclose = String(taggedString[cRg.upperBound..<cRg.lowerBound])
			//	let substringToEnclose = taggedString.substring(with: cRg).tagged(style)
				taggedString = taggedString.replacingCharacters(in: cRg, with: substringToEnclose)
			})
			return taggedString
		} catch {
			return self
		}
	}
}

public extension String {
	
	/// Convert a `Range<Index>?` to a valid `NSRange` for the self string instance
	///
	/// - Parameter range: input range
	/// - Returns: NSRange
	func nsRange(from range: Range<Index>?) -> NSRange {
		guard let r = range else {
			return NSRange(0..<utf16.count)
		}
        let lower = UTF16View.Index(r.lowerBound, within: utf16)!
        let upper = UTF16View.Index(r.upperBound, within: utf16)!
		return NSRange(location: utf16.distance(from: utf16.startIndex, to: lower), length: utf16.distance(from: lower, to: upper))
    }

}
