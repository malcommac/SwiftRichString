//
//  RichString+RichExtensions.swift
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
import UIKit

public extension RichString {
	
	/// Return a `Style` which represent the attributes present into the receiver attributed string.
	public var style: Style {
		return Style.init(attributesFrom: self)
	}
	
	/// Return a `Style` which represent the attributes present into the receiver string and allows
	/// to add/replace these attributes via callback configuration.
	///
	/// - Parameter configuration: callback configuration.
	/// - Returns: a new `Style`.
	public func derivatedStyle(_ configuration: @escaping ((Style) -> (Void))) -> Style {
		return Style.init(attributesFrom: self, configuration)
	}
	
	//MARK: Remove Attributes

	/// Remove passed attributes keys from the receiver.
	///
	/// - Parameters:
	///   - keys: attributes to remove.
	///   - range: range of the removal operation.
	/// - Returns: receiver modified.
	@discardableResult
	public func removeAttributes(_ keys: [NSAttributedStringKey], range: NSRange) -> Self {
		keys.forEach { self.removeAttribute($0, range: range) }
		return self
	}
	
	/// Remve all attributes available into the list of passed style merged in a single style.
	///
	/// - Parameter styles: styles with attributes keys to remove (will be merged in a single style).
	/// - Returns: receiver modified.
	public func remove(_ styles: [Style]) -> Self {
		self.removeAttributes(styles.mergedStyle().attributeKeys, range: NSMakeRange(0, self.string.count))
		return self
	}
	
	/// Remve all attributes available into passed style from the string.
	///
	/// - Parameter style: style with attributes keys to remove.
	/// - Returns: receiver modified.
	public func remove(_ style: Style) -> Self {
		self.removeAttributes(style.attributeKeys, range: NSMakeRange(0, self.string.count))
		return self
	}
	
	/// Same of `remove()` with array.
	///
	/// - Parameter styles: array of styles
	/// - Returns: receiver modified.
	public func remove<T: Sequence>(_ styles: T) -> Self {
		return self.remove(Array(styles))
	}
	
	//MARK: Append Attributes
	
	/// Append attributes defined into the callback to the receiver string.
	/// NOTE: Duplicate attributes are replaced, other attributes still part of the list.
	///
	/// - Parameter attributes: callback to define the list of attributes you can set.
	/// - Returns: receiver modified.
	public func add(_ attributes: ((Style) -> (Void))) -> Self  {
		return self.add(Style.init(empty: attributes))
	}
	
	/// Append attributes defined into passed `Style` instance.
	/// NOTE: Duplicate attributes are replaced, other attributes still part of the list.
	///
	/// - Parameter style: style to append.
	/// - Returns: receiver modified.
	public func add(_ style: Style) -> Self {
		self.addAttributes(style.attributes, range: NSMakeRange(0, self.string.count))
		return self
	}
	
	/// Append attributes defined into the array of `Style` instances. Attributes are merged in order
	/// (with first `default` on top) and applied.
	/// NOTE: Duplicate attributes are replaced, other attributes still part of the list.
	///
	/// - Parameter styles: styles to apply.
	/// - Returns: receiver modified.
	public func add(_ styles: [Style]) -> Self {
		self.addAttributes(styles.mergedStyle().attributes, range: NSMakeRange(0, self.string.count))
		return self
	}
	
	/// Same of `add()` with array.
	/// NOTE: Duplicate attributes are replaced, other attributes still part of the list.
	///
	/// - Parameter styles: styles to apply
	/// - Returns: receiver modified.
	public func add<T: Sequence>(_ styles: T) -> Self {
		return self.set(Array(styles))
	}
	
	//MARK: Set Attributes
	
	/// Set the attributes specified into the configuration callback.
	/// Callback already have the attributes read from the receiver, so you are able to
	/// change or remove it as you need.
	/// NOTE: These new attributes replace any attributes previously associated with the string.
	///
	/// - Parameter configuration: configuration callback.
	/// - Returns: receiver modified
	private func set(derivated configuration: @escaping ((Style) -> (Void))) -> RichString {
		return self.set(self.derivatedStyle(configuration))
	}
	
	/// Set the attributes specified into the configuration callback.
	/// Callback has an empty `Style` filled with global style.
	/// NOTE: These new attributes replace any attributes previously associated with the string.
	///
	/// - Parameter style: callback to apply.
	/// - Returns: receiver modified
	public func set(_ style: ((Style) -> (Void))) -> Self {
		return self.set(Style(id: nil, style))
	}
	
	/// Set the attributes specified into the configuration callback.
	/// NOTE: These new attributes replace any attributes previously associated with the string.
	///
	/// - Parameter style: style to set.
	/// - Returns: receiver modified
	public func set(_ style: Style) -> Self {
		self.setAttributes(style.attributes, range: NSMakeRange(0, self.string.count))
		return self
	}
	
	/// Set the attributes specified into the style merge of the styles passed into `styles` parameter
	/// (as usual first `default` style is placed on top).
	/// NOTE: These new attributes replace any attributes previously associated with the string.
	///
	/// - Parameter styles: styles array to apply.
	/// - Returns: receiver modified
	public func set(_ styles: [Style]) -> Self {
		self.setAttributes(styles.mergedStyle().attributes, range: NSMakeRange(0, self.string.count))
		return self
	}
	
	/// Same of `set()` for array.
	///
	/// - Parameter styles: styles to apply.
	/// - Returns: receiver modified
	public func set<T: Sequence>(_ styles: T) -> Self {
		return self.set(Array(styles))
	}
	
}

public extension RichString {
	
	/// Append bold trait to the current attributes of the receiver string.
	///
	/// - Returns: receiver modified.
	public func bold() -> RichString {
		return self.set(derivated: {
			$0.fontTraits = FontTraits.merge($0.fontTraits, .traitBold)
		})
	}
	
	/// Append italic trait to the current attributes of the receiver string.
	///
	/// - Returns: receiver modified.
	public func italic() -> RichString {
		return self.set(derivated: {
			$0.fontTraits = FontTraits.merge($0.fontTraits, .traitItalic)
		})
	}
	
	/// Append condensed trait to the current attributes of the receiver string.
	///
	/// - Returns: receiver modified.
	public func condensed() -> RichString {
		return self.set(derivated: {
			$0.fontTraits = FontTraits.merge($0.fontTraits, .traitCondensed)
		})
	}
	
	/// Append expanded trait to the current attributes of the receiver string.
	///
	/// - Returns: receiver modified.
	public func expanded() -> RichString {
		return self.set(derivated: {
			$0.fontTraits = FontTraits.merge($0.fontTraits, .traitExpanded)
		})
	}
	
	/// Append monospace trait to the current attributes of the receiver string.
	///
	/// - Returns: receiver modified.
	public func monospace() -> RichString {
		return self.set(derivated: {
			$0.fontTraits = FontTraits.merge($0.fontTraits, .traitMonoSpace)
		})
	}
	
	/// Append specified font to the current attributes of the receiver string.
	///
	/// - Parameter font: font to set, `nil` is ignored.
	/// - Returns: receiver modified.
	public func font(_ font: FontConvertible?) -> RichString {
		return self.set(derivated: {
			$0.font = font
		})
	}
	
	/// Append specified font size to the current attributes of the receiver string.
	///
	/// - Parameter size: new size to set.
	/// - Returns: receiver modified.
	public func fontSize(_ size: CGFloat) -> RichString {
		return self.set(derivated: {
			$0.fontSize = size
		})
	}
	
	/// Append specified text color to the current attributes of the receiver string.
	///
	/// - Parameter color: color to apply.
	/// - Returns: receiver modified
	public func color(_ color: ColorConvertible) -> RichString {
		return self.add({
			$0.color = color
		})
	}
	
	/// Append specified background color to the current attributes of the receiver string.
	///
	/// - Parameter color: background color to apply.
	/// - Returns: receiver modified
	public func backColor(_ color: ColorConvertible) -> RichString {
		return self.add({
			$0.backColor = color
		})
	}
	
	/// Append specified ligature to the current attributes of the receiver string.
	///
	/// - Parameter ligature: ligature value to appy.
	/// - Returns: receiver modified
	public func ligature(_ ligature: Ligature) -> RichString {
		return self.add({
			$0.ligature = ligature
		})
	}
	
	/// Append specified kern to the current attributes of the receiver string.
	///
	/// - Parameter kern: kern value to appy.
	/// - Returns: receiver modified
	public func kern(_ kern: Kern) -> RichString {
		return self.add({
			$0.kern = kern
		})
	}
	
	/// Append specified strikethrough to the current attributes of the receiver string.
	///
	/// - Parameters:
	/// - Parameter style: strikethrough style to apply.
	///   - color: strikethrough color to apply.
	/// - Returns: receiver modified
	public func strikeThrough(_ style: NSUnderlineStyle = .styleSingle, _ color: ColorConvertible) -> RichString {
		return self.add({
			$0.strikeThrough = style
			$0.strikeThroughColor = color
		})
	}
	
	/// Append specified underline to the current attributes of the receiver string.
	///
	/// - Parameters:
	///   - style: underline style to apply.
	///   - color: underline color to apply.
	/// - Returns: receiver modified
	public func underline(style : NSUnderlineStyle = .styleSingle, color: ColorConvertible) -> RichString {
		return self.add({
			$0.underline = style
			$0.underlineColor = color
		})
	}
	
	/// Append specified stroke to the current attributes of the receiver string.
	///
	/// - Parameters:
	///   - width: stroke width.
	///   - color: stroke color.
	/// - Returns: receiver modified
	public func stroke(width: CGFloat, color: ColorConvertible) -> RichString {
		return self.add({
			$0.strokeWidth = width
			$0.strokeColor = color
		})
	}
	
	/// Append specified text alignment to the current attributes of the receiver string.
	///
	/// - Parameter alignment: text alignment to set.
	/// - Returns: receiver modified
	public func alignment(_ alignment: NSTextAlignment) -> RichString {
		return self.set(derivated: {
			$0.alignment = alignment
		})
	}
	
	/// Append specified link to the current attributes of the receiver string.
	///
	/// - Parameter link: link to set.
	/// - Returns: receiver modified
	public func link(_ link: URL) -> RichString {
		return self.add({
			$0.link = link
		})
	}
	
	/// Append specified baseline offset to the current attributes of the receiver string.
	///
	/// - Parameter baselineOffset: baseline offset.
	/// - Returns: receiver modified
	public func baselineOffset(_ baselineOffset: CGFloat) -> RichString {
		return self.add({
			$0.baselineOffset = baselineOffset
		})
	}
	
	/// Append specified expansion factor to the current attributes of the receiver string.
	///
	/// - Parameter factor: expansion factor.
	/// - Returns: receiver modified
	public func expansionFactor(_ factor: CGFloat) -> RichString {
		return self.add({
			$0.expansionFactor = factor
		})
	}
	
	/// Append specified obliqueness factor to the current attributes of the receiver string.
	///
	/// - Parameter obliqueness: obliqueness value to set.
	/// - Returns: receiver modified.
	public func obliqueness(_ obliqueness: CGFloat) -> RichString {
		return self.add({
			$0.obliqueness = obliqueness
		})
	}
	
	/// Append specified shadow to the current attributes of the receiver string.
	///
	/// - Parameter shadow: shadow to apply
	/// - Returns: receiver modified.
	public func shadow(_ shadow: NSShadow) -> RichString {
		return self.add({
			$0.shadow = shadow
		})
	}
	
	/// Append specified text effect to the current attributes of the receiver string.
	///
	/// - Parameter textEffect: text effect to apply
	/// - Returns: receiver modified.
	public func textEffect(_ textEffect: RichString.TextEffectStyle?) -> RichString {
		return self.add({
			$0.textEffect = textEffect
		})
	}
	
	/// Append specified writing direction to the current attributes of the receiver string.
	///
	/// - Parameter writingDirection: writing direction to apply.
	/// - Returns: receiver modified.
	public func writingDirection(_ writingDirection: [WritingDirection]) -> RichString {
		return self.add({
			$0.writingDirection = writingDirection
		})
	}
	
	/// Append specified paragraph style to the current attributes of the receiver string.
	///
	/// - Parameter paragraph: paragraph style to apply.
	/// - Returns: receiver modified
	public func paragraph(_ paragraph: NSMutableParagraphStyle?) -> RichString {
		return self.add({
			$0.paragraph = paragraph
		})
	}
	
	/// Append specified line break mode to the current attributes of the receiver string.
	///
	/// - Parameter lineBreak: paragraph style to apply.
	/// - Returns: receiver modified
	public func lineBreak(_ mode: NSLineBreakMode) -> RichString {
		return self.set(derivated: {
			$0.lineBreak = mode
		})
	}
	
	/// Append specified paragraph spacing to the current attributes of the receiver string.
	///
	/// - Parameter spacing: paragraph spacing to apply.
	/// - Returns: receiver modified
	public func paragraphSpacing(_ spacing: CGFloat) -> RichString {
		return self.set(derivated: {
			$0.paragraphSpacing = spacing
		})
	}
	
	/// Append specified paragraph spacing before to the current attributes of the receiver string.
	///
	/// - Parameter spacing: paragraph spacing before to apply.
	/// - Returns: receiver modified
	public func paragraphSpacingBefore(_ spacing: CGFloat) -> RichString {
		return self.set(derivated: {
			$0.paragraphSpacingBefore = spacing
		})
	}
	
	/// Append specified first line head indent to the current attributes of the receiver string.
	///
	/// - Parameter indent: indent to apply.
	/// - Returns: receiver modified
	public func firstLineHeadIndent(_ indent: CGFloat) -> RichString {
		return self.set(derivated: {
			$0.firstLineHeadIndent = indent
		})
	}
	
	/// Append specified head indent to the current attributes of the receiver string.
	///
	/// - Parameter indent: head indent to apply.
	/// - Returns: receiver modified
	public func headIndent(_ indent: CGFloat) -> RichString {
		return self.set(derivated: {
			$0.headIndent = indent
		})
	}
	
	/// Append specified tail indent to the current attributes of the receiver string.
	///
	/// - Parameter indent: tail indent to apply.
	/// - Returns: receiver modified
	public func tailIndent(_ indent: CGFloat) -> RichString {
		return self.set(derivated: {
			$0.tailIndent = indent
		})
	}
	
	/// Append specified maximum line height to the current attributes of the receiver string.
	///
	/// - Parameter height: maximum line height to apply.
	/// - Returns: receiver modified
	public func maximumLineHeight(_ height: CGFloat) -> RichString {
		return self.set(derivated: {
			$0.maximumLineHeight = height
		})
	}
	
	/// Append specified minimum line height to the current attributes of the receiver string.
	///
	/// - Parameter height: minimum line height to apply.
	/// - Returns: receiver modified
	public func minimumLineHeight(_ height: CGFloat) -> RichString {
		return self.set(derivated: {
			$0.minimumLineHeight = height
		})
	}
	
	/// Append specified line spacing to the current attributes of the receiver string.
	///
	/// - Parameter spacing: line spacing to apply.
	/// - Returns: receiver modified
	public func lineSpacing(_ spacing: CGFloat) -> RichString {
		return self.set(derivated: {
			$0.lineSpacing = spacing
		})
	}
	
	/// Append specified line height multiple to the current attributes of the receiver string.
	///
	/// - Parameter spacing: line height multiple to apply.
	/// - Returns: receiver modified
	public func lineHeightMultiple(_ spacing: CGFloat) -> RichString {
		return self.set(derivated: {
			$0.lineHeightMultiple = spacing
		})
	}
}
