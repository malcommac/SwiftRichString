//
//  SwiftStyler.swift
//  SwiftStyler
//
//  Created by Daniele Margutti on 01/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import Foundation

//MARK: RichString

public struct RichString {
	fileprivate(set) var content: String
	internal var styles: [String : Style] = [:]
	
	public init(_ content: String, _ styles: [Style]?) {
		self.content = content
		if let styles = styles {
			styles.forEach { self.styles[$0.type.value] = $0 }
		}
	}
	
	public var string: NSMutableAttributedString {
		do {
			let (plainText,tags) = try parseContentAndExtractData()
			let renderedString = NSMutableAttributedString(string: plainText)
			
			// Apply default style if any
			if let defaultStyle = styles[StyleType.default.value] {
				renderedString.addAttributes(defaultStyle.attributes, range: NSRange(location: 0, length: renderedString.length))
			}
			
			// Apply any other defined style
			tags.forEach { tag in
				if let tagAttributes = styles[tag.name] {
					renderedString.addAttributes(tagAttributes.attributes, range: NSRange(tag.range!))
				}
			}
			
			return renderedString
		} catch {
			return NSMutableAttributedString()
		}
	}
	
	fileprivate let htmlEntities = ["quot":"\"","amp":"&","apos":"'","lt":"<","gt":">"]
	
	/// This function parse the text content of a string and extract tags entities and plain text
	///
	/// - Returns: plain text and list of tags found
	private func parseContentAndExtractData() throws -> (text: String, tags: [Tag]) {
		let scanner = StringScanner(self.content)
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
