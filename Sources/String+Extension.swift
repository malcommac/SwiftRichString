//
//  String+Extension.swift
//  SwiftRichString
//
//  Created by Daniele Margutti on 12/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import Foundation


//MARK: String Extensions

public extension String {
	
	/// Create a new NSMutableAttributedString instance from given String by applying passed attribute at given range.
	///
	/// - Parameters:
	///   - style: style to apply
	///   - range: range to apply (nil means entire string's range)
	/// - Returns: an NSMutableAttributedString instance
	public func add(style: Style, range: Range<Int>? = nil) -> NSMutableAttributedString {
		guard let range = range else { // apply to entire string
			return NSMutableAttributedString(string: self, attributes: style.attributes)
		}
		// create a new attributed string and apply attributes to given range mantaining
		// full unicode support
		let attributedText = NSMutableAttributedString(string: self)
		attributedText.addAttributes(style.attributes, range: self.toNSRange(from: range))
		return attributedText
	}
	
	
	/// Apply attributes in order, as passed. The only exception is .default Style; it will be applied always as first style
	///
	/// - Parameter styles: styles to apply
	/// - Returns: a new attributed string
	public func add(styles: Style...) -> NSMutableAttributedString {
		let attributedString = NSMutableAttributedString(string: self)
		let range = Range<String.Index>(uncheckedBounds: (self.startIndex,self.endIndex))
		attributedString.addAttributes(styles.attributesDictionary, range: self.toNSRange(from: range))
		return attributedString
	}
	
	/// Apply style's attributes to given string with pattern matching specified
	///
	/// - Parameters:
	///   - styles: styles to apply
	///   - pattern: pattern to search via regexp
	///   - options: options of pattern matching
	/// - Returns: a new attributed string instance
	public func add(styles: Style..., pattern: String, options: NSRegularExpression.Options = .caseInsensitive) -> NSAttributedString {
		do {
			let attributedString = NSMutableAttributedString(string: self)
			let regex = try NSRegularExpression(pattern: pattern, options: options)
			let allRange = Range<String.Index>(uncheckedBounds: (self.startIndex,self.endIndex))
			regex.enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: self.toNSRange(from: allRange)) {
				(result : NSTextCheckingResult?, _, _) in
				if let r = result {
					attributedString.addAttributes(styles.attributesDictionary, range: r.range)
				}
			}
			return attributedString
		} catch {
			return NSMutableAttributedString(string: self)
		}
	}
	
}

//MARK: String Extensions for MarkupString

public extension String {
	
	/// Create a new MarkupString by parsing the content of self string and apply given styles
	///
	/// - Parameter styles: styles to apply
	/// - Returns: a new MarkupString instances
	public func parse(_ styles: Style...) -> MarkupString {
		return MarkupString(self, styles)
	}
	
	public func parse() -> MarkupString {
		return MarkupString(self)
	}
	
}


//MARK: String Extension

public extension String {
	
	/// Enclose string between passed tag. Tag should not include open/end/close sign, so basically
	/// you need to pass only the name.
	///
	/// - Parameter tag: name of the tag
	/// - Returns: self enclosed between given open/close tag name
	public func `in`(tag: String) -> String {
		return "<\(tag)>\(self)</\(tag)>"
	}
	
	/// Enclose string between passed tag defined by given Style. Each style is defined with its own name
	/// This name represent the tag itself, so this is a shortcut.
	///
	/// - Parameter style: style to apply
	/// - Returns: self enclosed between given open/close tag name defined in Style
	public func `in`(tag style: Style) -> String {
		return "<\(style.name.value)>\(self)</\(style.name.value)>"
	}
	
	
	/// Enclose pattern matched strings in self with specified tag and return tagged string.
	///
	/// - Parameters:
	///   - style: style to apply
	///   - pattern: pattern to search for content to enclose in tag
	///   - options: options for pattern mathing
	/// - Returns: enclosed string
	public func add(tag style: Style, pattern: String, options: NSRegularExpression.Options = .caseInsensitive) -> String {
		do {
			var taggedString = self
			let regex = try NSRegularExpression(pattern: pattern, options: options)
			let allRange = Range<String.Index>(uncheckedBounds: (self.startIndex,self.endIndex))
			let matches = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: self.toNSRange(from: allRange))
			matches.reversed().forEach({ r in
				let cRg = self.toStringRange(from: r.range)!
				let substringToEnclose = taggedString.substring(with: cRg).in(tag: style)
				taggedString = taggedString.replacingCharacters(in: cRg, with: substringToEnclose)
			})
			return taggedString
		} catch {
			return self
		}
	}
}
