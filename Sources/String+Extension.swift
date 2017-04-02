//
//  String+Extension.swift
//  SwiftRichString
//
//  Created by Daniele Margutti on 12/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import Foundation


//MARK: String Extension (Style)

public extension String {
	
	/// Create a new NSMutableAttributedString instance from given String by applying passed attribute at given range.
	///
	/// - Parameters:
	///   - style: style to apply
	///   - range: range to apply (nil means entire string's range)
	/// - Returns: an NSMutableAttributedString instance
	public func set(style: Style, range: Range<Int>? = nil) -> NSMutableAttributedString {
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
	public func set(styles: Style...) -> NSMutableAttributedString {
		return self.set(stylesArray: Array(styles))
	}
	
	/// Apply attributes in order, as passed. The only exception is .default Style; it will be applied always as first style
	///
	/// - Parameter styles: styles to apply
	/// - Returns: a new attributed string
	public func set(stylesArray styles: [Style]) -> NSMutableAttributedString {
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
	public func set(styles: Style..., pattern: String, options: NSRegularExpression.Options = .caseInsensitive) -> NSAttributedString {
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

//MARK: String Extension (MarkupString)

public extension String {
	
	/// Create a new MarkupString by parsing the content of self string and apply given styles
	///
	/// - Parameter styles: styles to apply
	/// - Returns: a new MarkupString instances
	/// - Throws: throws if parse fail
	public func parse(andSet styles: Style...) throws -> MarkupString {
		return try MarkupString(source: self, styles: styles)
	}
	
	
	/// Parse content of tagged source string and store it in a MarkupString instance you can use to render
	/// the content using passed style via .render() functions.
	///
	/// - Returns: a new instance of MarkupString
	/// - Throws: throws if parse fail
	public func parse() throws -> MarkupString {
		return try MarkupString(source: self)
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
			let matches = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: self.toNSRange(from: allRange))
			matches.reversed().forEach({ r in
				let cRg = self.toStringRange(from: r.range)!
				let substringToEnclose = taggedString.substring(with: cRg).tagged(style)
				taggedString = taggedString.replacingCharacters(in: cRg, with: substringToEnclose)
			})
			return taggedString
		} catch {
			return self
		}
	}
}

//MARK: String Extensions (NSRange)

public extension String {
	
	/// Transform a Range<Int> to NSRange based upon the content of self
	///
	/// - Parameter range: range to convert
	/// - Returns: equivalent 
	public func toNSRange(from range: Range<Int>?) -> NSRange {
		guard let range = range else {
			return self.toNSRange(from: self.toStringRange(from: NSMakeRange(0, self.characters.count))!)
		}
		return self.toNSRange(from: self.toStringRange(range: range))
	}
	
	func toNSRange(from range: Range<String.Index>) -> NSRange {
		let from = range.lowerBound.samePosition(in: utf16)
		let to = range.upperBound.samePosition(in: utf16)
		return NSRange(location: utf16.distance(from: utf16.startIndex, to: from), length: utf16.distance(from: from, to: to))
	}
	
	public func toStringRange(range: Range<Int>) -> Range<String.Index> {
		let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
		let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)// - range.lowerBound)
		return Range<String.Index>(uncheckedBounds: (startIndex,endIndex))
	}
	
	func toStringRange(from nsRange: NSRange) -> Range<String.Index>? {
		guard
			let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
			let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
			let from = String.Index(from16, within: self),
			let to = String.Index(to16, within: self)
			else { return nil }
		return from ..< to
	}
}
