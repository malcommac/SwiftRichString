//
//  SwiftStyler.swift
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

//MARK: MarkupString

public class MarkupString {
	
	/// Raw content include plain text and given tags
	fileprivate(set) var content: String?

	/// Styles applied to MarkupString
	public internal(set) var styles: [String : Style] = [:]

	/// Cached attributed string, parsed one time and keep until MarkupString object still alive
	private var cachedAttributedString: NSMutableAttributedString?
	
	/// Initialize a new MarkupString with given string content and applicable styles
	///
	/// - Parameters:
	///   - content: plain text with tags
	///   - styles: styles to apply. Styles are applied based upon tags added to the content variabile.
	public init(_ content: String, _ styles: [Style]? = nil) {
		self.content = content
		if let styles = styles {
			// styles are transformed to dictionary in order to optimize our code
			styles.forEach { self.styles[$0.name.value] = $0 }
		}
	}
	
	/// Create MarkupString from file at specified path
	///
	/// - Parameters:
	///   - path: URL to load
	///	  - encoding: encoding to use
	///   - styles: styles to apply. Styles are applied based upon tags added to the content variabile.
	public init?(_ path: URL, encoding: String.Encoding = .utf8, _ styles: [Style]? = nil) {
		do {
			self.content = try String(contentsOf: path, encoding: encoding)
			if let styles = styles {
				// styles are transformed to dictionary in order to optimize our code
				styles.forEach { self.styles[$0.name.value] = $0 }
			}
		} catch {
			return nil
		}
	}

	/// Return plain string without tags
	public var plain: String {
		get {
			guard let attributedString = self.cachedAttributedString else {
				return content!
			}
			return attributedString.string
		}
	}
	
	/// Return NSMutableAttributed string rendered upon given tags and styles
	public var text: NSMutableAttributedString {
		if let cachedAttributedString = self.cachedAttributedString {
			return cachedAttributedString
		}
		
		do {
			let (plainText,tags) = try MarkupString.parse(self.content!)
			let renderedString = NSMutableAttributedString(string: plainText)
			self.content = nil
			
			// Apply default style if specified
			// Default style is applied to the entire string before any other style will replace or integrate it based upon tags
			if let defaultStyle = styles[StyleName.default.value] {
				renderedString.addAttributes(defaultStyle.attributes, range: NSRange(location: 0, length: renderedString.length))
			}
			
			// Apply any other defined style
			tags.forEach { tag in
				if let tagAttributes = styles[tag.name] {
					renderedString.addAttributes(tagAttributes.attributes, range: NSRange(tag.range!))
				}
			}
			
			self.cachedAttributedString = renderedString
		} catch {
			self.cachedAttributedString = NSMutableAttributedString()
		}
		return cachedAttributedString!
	}
	
	/// Custom html entities
	fileprivate static let htmlEntities = ["quot":"\"","amp":"&","apos":"'","lt":"<","gt":">"]
	
	/// This function parse the text content of a string and extract tags entities and plain text
	///
	/// - Returns: plain text and list of tags found
	private static func parse(_ content: String) throws -> (text: String, tags: [Tag]) {
		let scanner = StringScanner(content)
		var tagStacks: [Tag] = [] // temporary stack
		var tagsList: [Tag] = [] // final stack with all found tags
		
		var plainText = String()
		while !scanner.isAtEnd {
			// scan text and accumulate it until we found a special entity (starting with &) or an open tag character (<)
			if let textString = try scanner.scan(upTo: CharacterSet(charactersIn: "<&")) {
				plainText += textString
			} else {
				// We have encountered a special entity or an open/close tag
				if scanner.match("&") == true {
					// It's a special entity so get it until the end (; character) and replace it with encoded char
					if let entityValue = try scanner.scan(upTo: ";") {
						if let spec = htmlEntities[entityValue] {
							plainText += spec
						}
						try scanner.skip()
					}
					continue
				} else if scanner.match("<") == true {
					let rawTag = try scanner.scan(upTo: ">")
					if var tag = Tag(raw: rawTag) {
						if tag.name == "br" { // it's a return carriage, we want to translate it directly
							plainText += "\n"
							continue
						}
						let endIndex = plainText.characters.count
						if tag.isOpenTag == true {
							// it's an open tag, store the start index
							// (the upperbund is temporary the same of the lower bound, we will update it
							// at the end, before adding it to the list of the tags)
							tag.range = endIndex..<endIndex
							tagStacks.append(tag)
						} else {
							let enumerator = tagStacks.enumerated().reversed()
							for (index, var currentTag) in enumerator {
								// Search back to the first opening closure for this tag, update the upper bound
								// with the end position of the closing tag and put on the list
								if currentTag.name == tag.name {
									currentTag.range = currentTag.range!.lowerBound..<endIndex
									tagsList.append(currentTag)
									tagStacks.remove(at: index)
									break
								}
							}
						}
					}
					try scanner.skip()
				}
			}
		}
		return (plainText,tagsList)
	}

}

//MARK: Tag

/// This represent a single parsed tag entity
/// You should never use it externally but it's an internal struct used when we need to apply data
internal struct Tag {
	
	/// The name of the tag
	public let name: String
	
	/// Range of tag
	public var range: Range<Int>?
	
	/// true if tag represent an open tag
	fileprivate(set) var isOpenTag: Bool
	
	public init?(raw content: String?) {
		guard let content = content else {
			return nil
		}
		// Read tag name
		let tagScanner = StringScanner(content)
		do {
			self.isOpenTag = (tagScanner.match("/") == false)
			guard let name = try tagScanner.scan(untilIn: CharacterSet.alphanumerics) else {
				return nil
			}
			self.name = name
		} catch {
			return nil
		}
	}
}
