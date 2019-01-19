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

/// `StyleGroup` is a container for named `Style` instances.
/// You need of it to render a text using html-style tags.
public class StyleGroup: StyleProtocol {
	
	/// Does not return anything for groups.
	public var fontData: FontData? = nil

	/// TagAttribute represent a single tag in a source string after the text is parsed.
	private class TagAttribute {
		let wholeTag: String
		var range: NSRange
		
		private(set) var isOpeningTag: Bool = false
		private(set) var name: String = ""
		private(set) var paramString: String?
		
		// Should only be set to opening tags
		var endingTagIndex: Int?
		
		private func processWholeTag() {
			isOpeningTag = !wholeTag.hasPrefix("</")
			
			let strippedTag = wholeTag.removing(prefix: isOpeningTag ? "<":"</").removing(suffix: ">").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
			name = strippedTag.components(separatedBy: CharacterSet.whitespacesAndNewlines).first ?? ""
			if isOpeningTag {
				paramString = strippedTag.removing(prefix: name).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
				if paramString?.count == 0 { paramString = nil }
			}
		}
		
		init(wholeTag: String, range: NSRange) {
			self.wholeTag = wholeTag
			self.range = range
			processWholeTag()
		}
	}
	
	//MARK: PROPERTIES
	
	/// Ordered dictionary of the styles inside the group
	public private(set) var styles = OrderedDictionary<String,StyleProtocol>()
	
	/// Style to apply as base. If set, before parsing the string style is applied (add/set)
	/// to the existing source.
	public var baseStyle: StyleProtocol?
	
	/// Return all attributes merge of each single `Style` of the group.
	/// Attributes are reported in order of the insertion regardeless the associated name.
	public var attributes: [NSAttributedString.Key : Any] {
		var composedAttributes: [NSAttributedString.Key: Any] = [:]
		self.styles.enumerated().forEach { (arg) in
			
			let (_, style) = arg
			composedAttributes.merge(style.attributes, uniquingKeysWith: { (_, new) in return new })
		}
		return composedAttributes
	}
	
	//MARK: INIT

	/// Initialize a new `StyleGroup` with a dictionary of style and names.
	/// Note: Ordered is not guarantee, use `init(_ styles:[(String, StyleProtocol)]` if you
	/// need to keep the order of the styles.
	///
	/// - Parameter styles: styles dictionary
	public init(base: StyleProtocol? = nil, _ styles: [String: StyleProtocol]) {
		styles.forEach { self.styles[$0.key] = $0.value }
		self.baseStyle = base
	}
	
	/// Initialize a new `StyleGroup` with an ordered list of styles with associated names.
	/// Order is preserved if you need to extract `attributes` dictionary which is a merge of all styles.
	///
	/// - Parameter styles: styles
	public init(base: StyleProtocol? = nil, _ styles: [(String, StyleProtocol)]) {
		styles.forEach { self.styles[$0.0] = $0.1 }
		self.baseStyle = base
	}
	
	//MARK: PUBLIC METHODS
	
	/// Append a new style with given name inside the list.
	/// Order is preserved.
	///
	/// - Parameters:
	///   - style: style you want to add.
	///   - name: unique name of the style.
	public func add(style: Style, as name: String) {
		return self.styles[name] = style
	}
	
	/// Remove the style with given name.
	///
	/// - Parameter name: name of the style to remove.
	/// - Returns: removed style instance.
	@discardableResult
	public func remove(style name: String) -> StyleProtocol? {
		return self.styles.remove(key: name)
	}
	
	//MARK: RENDERING FUNCTIONS
	
	/// Render given source with styles defined inside the receiver.
	/// Styles are added as sum to any existing
	///
	/// - Parameters:
	///   - source: source to render.
	///   - range: range of characters to render, `nil` to apply rendering to the entire content.
	/// - Returns: attributed string
	public func set(to source: String, range: NSRange?) -> AttributedString {
		let attributed = NSMutableAttributedString(string: source)
		return self.apply(to: attributed, adding: true, range: range)
	}
	
	/// Render given source string by appending parsed styles to the existing attributed string.
	///
	/// - Parameters:
	///   - source: source attributed string.
	///   - range: range of parse.
	/// - Returns: same istance of `source` with applied styles.
	public func add(to source: AttributedString, range: NSRange?) -> AttributedString {
		return self.apply(to: source, adding: true, range: range)
	}
	
	/// Render given source string by replacing existing styles to parsed tags.
	///
	/// - Parameters:
	///   - source: source attributed string.
	///   - range: range of parse.
	/// - Returns: same istance of `source` with applied styles.
	public func set(to source: AttributedString, range: NSRange?) -> AttributedString {
		return self.apply(to: source, adding: false, range: range)
	}
	
	/// Parse tags and render the attributed string with the styles defined into the receiver.
	///
	/// - Parameters:
	///   - attrStr: source attributed string
	///   - adding: `true` to add styles defined to existing styles, `false` to replace any existing style inside tags.
	///   - range: range of operation, `nil` for entire string.
	/// - Returns: modified attributed string, same instance of the `source`.
	public func apply(to attrStr: AttributedString, adding: Bool, range: NSRange?) -> AttributedString {
		let tagRegex = "</?[a-zA-Z][^<>]*>"
		var tagQueue:[TagAttribute] = []
		let str = attrStr.string
		
		// Apply default base style if specified
		self.baseStyle?.set(to: attrStr, range: nil)
		
		// Parse tags
		if let regex = try? NSRegularExpression(pattern: tagRegex, options: .dotMatchesLineSeparators) {
			let matches = regex.matches(in: str,
										options: NSRegularExpression.MatchingOptions.reportCompletion,
										range: (range ?? NSRange(location: 0, length: (str as NSString).length)))
			// Map all tags
			for match in matches {
				let wholeTag = (str as NSString).substring(with: match.range)
				let tag = TagAttribute(wholeTag: wholeTag, range: match.range)
				if tag.isOpeningTag {
					tagQueue.append(tag)
				} else {
					for index in (0..<tagQueue.count).reversed() {
						let openTag = tagQueue[index]
						if !openTag.isOpeningTag { continue }
						if openTag.endingTagIndex != nil { continue }
						if tag.name == openTag.name {
							openTag.endingTagIndex = tagQueue.count
							break
						}
					}
					tagQueue.append(tag)
				}
			}
			
			func removeTag(index: Int, with str: String = "") {
				let tag = tagQueue[index]
				attrStr.replaceCharacters(in: tag.range, with: NSAttributedString(string: str))
				let nextIndex = index+1
				if nextIndex < tagQueue.count {
					for tIndex in nextIndex..<tagQueue.count {
						tagQueue[tIndex].range.location -= tag.range.length
					}
				}
			}
			
			// Apply all tags starting from outside
			for index in 0..<tagQueue.count {
				let tag = tagQueue[index]
				if tag.isOpeningTag {
					guard tag.name != "br" else {
						removeTag(index: index, with: "\n")
						continue
					}
					guard let attribute = self.styles[tag.name] else { continue }
					
					removeTag(index: index)
					if let closeIndex = tag.endingTagIndex {
						guard closeIndex < tagQueue.count else { continue }
						let closingTag = tagQueue[closeIndex]
						removeTag(index: closeIndex)
						
						let location = tag.range.location
						let length = closingTag.range.location-location
						let range = NSRange(location: location, length: length)
						attribute.fontData?.addAttributes(to: attrStr, range: range)
						attrStr.addAttributes(attribute.attributes, range: range)
					}
				}
				
			}
		}
		
		return attrStr
	}
	
}

public extension Array where Array.Element == StyleProtocol {
	
	/// Merge styles from array of `StyleProtocol` elements.
	/// Merge is made in order where each n+1 elements may replace existing keys defined by n-1 elements.
	///
	/// - Returns: merged style
	public func mergeStyle() -> Style {
		var attributes: [NSAttributedString.Key:Any] = [:]
		self.forEach { attributes.merge($0.attributes, uniquingKeysWith: { (_, new) in return new }) }
		return Style(dictionary: attributes)
	}
	
}
