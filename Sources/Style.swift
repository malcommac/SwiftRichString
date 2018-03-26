//
//  Style.swift
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

// MARK: - Array of StyleProtocol extension
public extension Array where Element: StyleProtocol {
	
	/// Create a new style which is the merge of all the attributes of the array taken in order.
	/// NOTE: first `default` Style in the array is put at the beginning of the array before any operation.
	///
	/// - Returns: `Style` merge of the attributes.
	public func mergedStyle() -> Style {
		var merged: [RichAttribute: Any] = [:]
		self.sorted().forEach {
			merged.merge($0.attributes, uniquingKeysWith: { (_, last) in last })
		}
		return Style(kind: .id(nil), attributes: merged)
	}
	
}

//MARK: - StyleProtocol

/// StyleProtocol define a common set of functions and variables adopted both by `Style` and `StyleGroup`.
public protocol StyleProtocol: Comparable {
	
	/// Attributes of the string
	var attributes: [RichAttribute : Any] { get }
	
	/// Return the instance of the style
	var style: Style { get }
	
	/// Render a plain string with the style itself.
	///
	/// - Parameter string: string to render.
	/// - Returns: rendered string.
	func render(_ string: String) -> RichString
	
	/// Marge the style with another style.
	///
	/// - Parameter style: style to merge.
	/// - Returns: merged `Style`.
	func merge(with style: Style) -> Style
	
	/// Change the type of Style.
	///
	/// - Parameter kind: new value
	/// - Returns: receiver
	func set(kind: Kind) -> Self
	
}

//MARK: - Kind

/// Define the type of style.
/// There are two types of styles, `default` style and `id` style. `default` style
/// is always applied as first style both in a group or when you pass it to a `set`
/// function; its basically the ground style you could apply to the content.
///
///
/// - `default`: default style, is always applied as first style both in `StyleGroup` or
///              `set()` call when passing sequences or array of styles.
/// - id: define a custom style with given name. You could assign an id to the style in order
///       to apply it to tag-based string. If you apply it using `set()` function you can omit the name.
public enum Kind: Equatable, Comparable {
	case `default`
	case id(_: String?)
	
	/// `true` if this is a default style
	public var isDefault: Bool {
		guard case .`default` = self else { return false }
		return true
	}
	
	/// Equatable protocol implementation for `Kind` enum.
	public static func ==(lhs: Kind, rhs: Kind) -> Bool {
		switch (lhs,rhs) {
		case (.`default`,.`default`):	return true
		case (.id(let l),.id(let r)):	return (l == r)
		default:						return false
		}
	}
	
	/// Order is used only to put `default` style on top. Other elements still stay at the same position.
	internal var order: Int {
		switch self {
		case .default:	return 0
		default:		return 1
		}
	}
	
	/// Comparable support.
	public static func <(lhs: Kind, rhs: Kind) -> Bool {
		return (lhs.order < rhs.order)
	}
	
}

//MARK: - StyleGroup

/// StyleGroup allows to set a group of `Style`.
public final class StyleGroup: StyleProtocol {

	/// Inner representation of the group's styles
	public private(set) var styles: [Style] = []
	
	/// Return first `default` style of the group, if any.
	public var defaultStyle: Style? {
		return self.styles.first(where: { $0.kind.isDefault })
	}
	
	/// Does nothing for group.
	public func set(kind: Kind) -> Self {
		return self
	}
	
	/// Initialize a new group with a given set of styles.
	/// Styles are ordered to put automatically at the first position the first found `default` style.
	///
	/// - Parameter styles: styles to set.
	public init(_ styles: [Style]) {
		self.styles = styles.sorted()
	}
	
	/// Merge attributes in a single attribute sequence in the same order of `styles`.
	/// Note: value is not cached because you are able to change, anytime a value inside the `styles` array.
	public var attributes: [RichAttribute : Any] {
		var merged: [RichAttribute: Any] = [:]
		self.styles.forEach {
			merged.merge($0.attributes, uniquingKeysWith: { (_, last) in last })
		}
		return merged
	}
	
	/// Merge the resulting style derived from the group to another style instance.
	///
	/// - Parameter style: style to merge.
	/// - Returns: new merged `Style`.
	public func merge(with style: Style) -> Style {
		return self.style.merge(with: style)
	}
	
	/// Create a `.default` style which merge all the styles of the group in the same order of `styles` array.
	public var style: Style {
		return Style.init(kind: .default, attributes: self.attributes)
	}
	
	/// Render a plain `String` instance with the style result of the group's style.
	///
	/// - Parameter string: source string.
	/// - Returns: `RichString`
	public func render(_ string: String) -> RichString {
		return self.style.render(string)
	}
	
	/// Comparable support.
	public static func <(lhs: StyleGroup, rhs: StyleGroup) -> Bool {
		return true // does nothing, order still the same for groups
	}
	
	
	/// Equatable protocol support.
	public static func ==(lhs: StyleGroup, rhs: StyleGroup) -> Bool {
		return (lhs.styles == rhs.styles)
	}
}

//MARK: - Style

/// Style class encapsulate attributes you can apply both to simple `String` instances
/// and `NSMutableAttributedString` instances (called `RichString` with typealias).
public final class Style: Equatable, Comparable, StyleProtocol {
	
	/// Equatable protocol for `Style` instances.
	/// Comparison check first the equality of the `kind`, then it also works on `attributes` dictionary.
	public static func ==(lhs: Style, rhs: Style) -> Bool {
		guard lhs.kind == rhs.kind else { return false }
		return (lhs.attributes as NSDictionary) == (rhs.attributes as NSDictionary)
	}
	
	/// Comparable support.
	/// It's just compare the `kind` property.
	public static func <(lhs: Style, rhs: Style) -> Bool {
		return (lhs.kind.order < rhs.kind.order)
	}
	
	//MARK: PROPERTIES

	/// Kind of style
	public var kind: Kind
	
	/// Attributes dictionary. It contains all the `NSAttributedStringKey` which compose the string.
	public private(set) var attributes: [RichAttribute : Any] = [:]
	
	/// Return all keys of the attributes part of the style
	public var attributeKeys: [RichAttribute] { return Array(self.attributes.keys) }
	
	/// Does nothing for group.
	public func set(kind: Kind) -> Self {
		self.kind = kind
		return self
	}
	
	//MARK: INITIALIZATION

	/// Initialize a new `default` style with all attributes specified by the global style.
	///
	/// - Parameters:
	///   - global: `true` to use attributes specified by global style, `false` to create an empty `Style`.
	///   - kind: kind of style, if not specified `default` is used.
	public init(global: Bool = true, kind: Kind = .default) {
		self.kind = .default
		self.attributes = (global ? RichString.globalStyle.attributes : [:])
	}
	
	/// Initialize a new `default` `Style` by reading attributes for a source attributed string.
	///
	/// NOTE: global attributes are ignored during the creation of this `Style`; only attributes from
	/// source string are used to compose the internal dictionary.
	///
	/// - Parameters:
	///   - str: string to read attributes from.
	///   - configuration: optional callback used to add/replace attributes.
	public convenience init(attributesFrom str: RichString, _ configuration: ((Style) -> (Void))? = nil) {
		self.init(global: false)
		self.attributes = str.attributes(at: 0,
										 longestEffectiveRange: nil,
										 in: NSRange(location: 0, length: str.length))
		configuration?(self)
	}
	
	/// Initialize a new style using a dictionary of attributes.
	///
	/// NOTE: 	global attributes are ignored during the creation of this `Style`; only attributes
	///			specified in `attributes` parameter are used.
	///
	/// - Parameters:
	///   - kind: kind of style.
	///   - attributes: attributes to set.
	public convenience init(kind: Kind, attributes: [RichAttribute: Any]) {
		self.init(global: false, kind: kind)
		self.attributes = attributes
	}
	
	/// Initialize a new empty style (without data from global style) using a configuration callback
	/// to setup attributes.
	///
	/// - Parameter configuration: configuration callback to setup attributes.
	public convenience init(empty configuration: ((Style) -> (Void))) {
		self.init(global: false, kind: .default)
		configuration(self)
	}
	
	/// Initialize a new `default` `Style` by setting initial attributes to the global style's attributes
	/// and giving the opportunity to override these values via `configuration` callback.
	///
	/// - Parameter configuration: optional callback used to add/replace attributes.
	public convenience init(default configuration: ((Style) -> (Void))) {
		self.init(global: true)
		configuration(self)
	}
	
	/// Initialize a new `id` `Style` by setting initial attributes to the global style's attributes
	/// and giving the opportunity to override these values via `configuration` callback.
	///
	/// - Parameters:
	///   - identifier: identifier name of the style. You may leave it `nil` if you don't plan
	///					to use it in tag-based rendering functions.
	///   - configuration: optional callback used to add/replace attributes.
	public convenience init(id identifier: String? = nil, _ configuration: ((Style) -> (Void))) {
		self.init(global: true, kind: .id(identifier))
		configuration(self)
	}

	/// Initialize a new style by reading initial set of attributes from another given `Style` instance, then
	/// give the opportunity to make changes to the style via configuration callback.
	///
	/// NOTE: global attributes are ignored during the creation of this `Style`; only attributes from
	/// source string are used to compose the internal dictionary.
	///
	/// - Parameters:
	///   - style: origin style to read attributes from.
	///   - configuration: optional callback used to add/replace attributes.
	public convenience init(_ style: Style, _ configuration: ((Style) -> (Void))) {
		self.init(global: false, kind: style.kind)
		self.attributes = style.attributes
		configuration(self)
	}
	
	/// Convenience initializer to produce a new `default` `Style` with passed configuration.
	/// Initial attributes of the style prior configuration call are taken from global style.
	///
	/// - Parameter configuration: optional callback used to add/replace attributes.
	/// - Returns: new `Style`.
	public static func `default`(_ configuration: ((Style) -> (Void))) -> Style {
		return Style(default: configuration)
	}
	
	/// Convenience initializer to produce a new `id` `Style` with passed configuration.
	/// Initial attributes of the style prior configuration call are taken from global style.
	///
	/// - Parameters:
	///   - identifier: identifier name of the style. You may leave it `nil` if you don't plan
	///					to use it in tag-based rendering functions.
	///   - configuration: optional callback used to add/replace attributes.
	/// - Returns: new `Style`.
	public static func id(_ identifier: String? = nil, _ configuration: ((Style) -> (Void))) -> Style {
		return Style(id: identifier, configuration)
	}
	
	
	//MARK: STYLE PROPERTIES
	
	/// Allows to set font traits for actual set font.
	/// If font for style is not set yet when you call this function, then the global style's font is used.
	public var fontTraits: FontTraits? {
		get {
			let font = (self.font ?? RichString.globalStyle.font!) as! UIFont
			let traits: FontTraits = font.fontDescriptor.symbolicTraits
			return traits
		}
		set {
			let font = (self.font ?? RichString.globalStyle.font!)
			guard let desc = font.toFont(size: self.fontSize)?.fontDescriptor.withSymbolicTraits( (newValue ?? []) ) else {
				return
			}
			let adjustedFont = UIFont.init(descriptor: desc, size: self.fontSize )
			self.font = adjustedFont
		}
	}
	
	/// Set the font.
	///
	/// `FontConvertible` is a general protocol which is adopted from:
	/// - `UIFont`: pass directly your desidered instance of font.
	/// - `String`: by passing a string the library attempt to convert it to a valid `UIFont`;
	///				if it fails set operation will be not applied it fails silently).
	/// - `CustomFont`: a special object which allows to set font easily and pick from a type-safe
	///					set of available fonts on the platform.
	public var font: FontConvertible? {
		set { self.set(attribute: .font, value: newValue?.toFont(size: nil)) }
		get { return self.get(attribute: .font) }
	}
	
	/// Set new `pointSize` of the currently set font.
	/// If no font is set yet global style's font is applied automatically with passed point size.
	public var fontSize: CGFloat {
		set {
			let newFontSize = (self.font ?? RichString.globalStyle.font!).toFont(size: newValue)
			self.set(attribute: .font, value: newFontSize)
		}
		get {
			let font: FontConvertible? = self.get(attribute: .font, fallback: nil)
			return (font?.fontSize ?? UIFont.systemFontSize)
		}
	}
	
	/// Set the text color.
	///
	/// Value must be conform to `ColorConvertible` protocol, adopted by:
	/// - `UIColor`: pass directly your desidered instance of color.
	/// - `String`: passing a string the library attempts to convert it to a valid `UIColor`. Supported strings
	/// 			formats are HEX strings in form of `#XXXXXX` or comma separated value of `r,g,b,a`.
	public var color: ColorConvertible? {
		set { self.set(attribute: .foregroundColor, value: newValue?.toColor()) }
		get { return self.get(attribute: .foregroundColor, fallback: nil) }
	}
	
	/// Set the background color applied to the text.
	///
	/// Value must be conform to `ColorConvertible` protocol, adopted by:
	/// - `UIColor`: pass directly your desidered instance of color.
	/// - `String`: passing a string the library attempts to convert it to a valid `UIColor`. Supported strings
	/// 			formats are HEX strings in form of `#XXXXXX` or comma separated value of `r,g,b,a`.
	public var backColor: ColorConvertible? {
		set { self.set(attribute: .backgroundColor, value: newValue?.toColor()) }
		get { return self.get(attribute: .backgroundColor, fallback: nil) }
	}
	
	/// Ligatures cause specific character combinations to be rendered using a single custom
	/// glyph that corresponds to those characters.
	///
	/// Allowed values are `.none`, `.defaults` or `.all` (`all` is not supported on iOS).
	public var ligature: Ligature {
		set { self.set(attribute: .ligature, value: newValue.rawValue) }
		get { return self.get(attribute: .ligature, fallback: Ligature.`default`)! }
	}
	
	/// This value specifies the number of points by which to adjust kern-pair characters.
	/// Kerning prevents unwanted space from occurring between specific characters and depends on the font.
	///
	/// Allowed values are `.none` (kerning is disabled) or `custom` where you must specify a `CGFloat` value.
	public var kern: Kern {
		set { self.set(attribute: .kern, value: newValue.rawValue) }
		get { return Kern(rawValue: self.get(attribute: .kern, fallback: 0.0)!)! }
	}
	
	/// This value indicates whether the text has a line through it and corresponds to one of
	/// the constants described in NSUnderlineStyle.
	/// The default value for this attribute is `.styleNone`.
	///
	/// Value is ignored if `strikeThroughColor` is not applied.
	public var strikeThrough: NSUnderlineStyle {
		set { self.set(attribute: .strikethroughStyle, value: newValue.rawValue) }
		get { return self.get(attribute: .strikethroughStyle, fallback: NSUnderlineStyle.styleNone)! }
	}
	
	/// Set the striketrhough color as `ColorConvertible conform object.
	/// The default value is nil, indicating same as foreground color.
	///
	/// Value is ignored if `strikeThrough` is not applied.
	public var strikeThroughColor: ColorConvertible? {
		set { self.set(attribute: .strikethroughColor, value: newValue?.toColor()) }
		get { return self.get(attribute: .strikethroughColor, fallback: nil) }
	}
	
	/// This value indicates whether the text is underlined and corresponds to one of
	/// the constants described in `NSUnderlineStyle.`
	/// The default value for this attribute is `.styleNone`.
	///
	/// Value is ignored if `underlineColor` is not applied.
	public var underline: NSUnderlineStyle {
		set { self.set(attribute: .underlineStyle, value: newValue.rawValue) }
		get { return self.get(attribute: .underlineStyle, fallback: NSUnderlineStyle.styleNone)! }
	}
	
	/// Set the string underline color as a `ColorConvertible` conform object.
	/// The default value is nil, indicating same as foreground color.
	///
	/// Value is ignored if `underline` is not applied.
	public var underlineColor: ColorConvertible? {
		set { self.set(attribute: .underlineColor, value: newValue?.toColor()) }
		get { return self.get(attribute: .underlineColor, fallback: nil) }
	}
	
	/// This value represents the amount to change the stroke width and is specified as a percentage
	/// of the font point size.
	///
	/// Allowed values are:
	/// - 0 (the default) for no additional changes.
	/// - positive values to change the stroke width alone.
	/// - negative values to stroke and fill the text. For example, a typical value for outlined text would be 3.0.
	/// You must also specify a valid `strokeColor` value.
	public var strokeWidth: CGFloat {
		set { self.set(attribute: .strokeWidth, value: newValue) }
		get { return self.get(attribute: .strokeWidth, fallback: 0)! }
	}
	
	/// Set the stroke color as a `ColorConvertible` conform object.
	///
	/// If it is not defined (which is the case by default),
	/// it is assumed to be the same as the value of color; otherwise, it describes the outline color.
	/// You must also specify a valid `strokeWidth` value.
	public var strokeColor: ColorConvertible? {
		set { self.set(attribute: .strokeWidth, value: newValue?.toColor()) }
		get { return self.get(attribute: .strokeWidth, fallback: nil) }
	}
	
	/// The text alignment of the receiver.
	/// By default value is `natural`, depending by system's locale.
	/// Natural text alignment is realized as left or right alignment depending on the line sweep
	/// direction of the first script contained in the paragraph.
	///
	/// Value is part of the `paragraph` property; if no instance is set before applying this property a
	/// new paragraph value taken from globalStyle is applied (if also `paragraph` property of `globalStyle` is
	/// `nil`, a new empty `NSMutableParagraphStyle` is created automatically).
	public var alignment: NSTextAlignment {
		set {
			let paragraph = self.get(attribute: .paragraphStyle, fallback: RichString.globalStyle.paragraph!)!
			paragraph.alignment = newValue
			self.set(attribute: .paragraphStyle, value: paragraph)
		}
		get {
			guard let p: NSMutableParagraphStyle = self.get(attribute: .paragraphStyle, fallback: nil) else {
				return NSTextAlignment.natural
			}
			return p.alignment
		}
	}
	
	/// The value of this attribute is an `URL` object (preferred).
	/// The default value of this property is `nil`, indicating no link.
	public var link: URL? {
		set { self.set(attribute: .link, value: newValue) }
		get { return self.get(attribute: .link, fallback: nil) }
	}
	
	/// Floating point value indicating the character’s offset from the baseline, in points.
	/// The default value is 0.
	public var baselineOffset: CGFloat {
		set { self.set(attribute: .baselineOffset, value: newValue) }
		get { return self.get(attribute: .baselineOffset, fallback: 0.0)! }
	}
	
	/// Floating point value indicating the log of the expansion factor to be applied to glyphs.
	/// The default value is 0, indicating no expansion.
	public var expansionFactor: CGFloat {
		set { self.set(attribute: .expansion, value: newValue) }
		get { return self.get(attribute: .expansion, fallback: 0.0)! }
	}
	
	/// Floating point value indicating skew to be applied to glyphs.
	/// The default value is 0, indicating no skew.
	public var obliqueness: CGFloat {
		set { self.set(attribute: .obliqueness, value: newValue) }
		get { return self.get(attribute: .obliqueness, fallback: 0.0)! }
	}
	
	/// The value of this attribute is an `NSShadow` object and allows to set a specific shadow
	/// applied to the text.
	/// The default value of this property is `nil`.
	public var shadow: NSShadow? {
		set { self.set(attribute: .shadow, value: newValue) }
		get { return self.get(attribute: .shadow, fallback: nil) }
	}
	
	/// This value allows to apply text effect to the content.
	/// Use this attribute to specify a text effect, such as `NSTextEffectLetterpressStyle`.
	/// The default value of this property is `nil`, indicating no text effect.
	public var textEffect: RichString.TextEffectStyle? {
		set { self.set(attribute: .textEffect, value: newValue) }
		get { return self.get(attribute: .textEffect, fallback: nil) }
	}
	
	/// The value of this attribute is an array of `WritingDirection` objects
	/// representing the nested levels of writing direction overrides, in order from outermost to innermost.
	/// Default value is `nil`.
	public var writingDirection: [WritingDirection]? {
		set { self.set(attribute: .writingDirection, value: newValue) }
		get { return self.get(attribute: .writingDirection, fallback: nil) }
	}
	
	/// Allows to set a default paragraph style to the content.
	/// If not specified value is `nil`.
	public var paragraph: NSMutableParagraphStyle? {
		set { self.set(attribute: .paragraphStyle, value: newValue) }
		get { return self.get(attribute: .paragraphStyle, fallback: nil) }
	}
	
	/// The mode that should be used to break lines.
	///
	/// Value is part of the `paragraph` property; if no instance is set before applying this property a
	/// new paragraph value taken from globalStyle is applied (if also `paragraph` property of `globalStyle` is
	/// `nil`, a new empty `NSMutableParagraphStyle` is created automatically).
	///
	/// Default value is `.byTruncatingTail`.
	/// As part of the `paragraph` instance this value will be overriden if you set a new `paragraph`.
	public var lineBreak: NSLineBreakMode {
		set { self.paragraph?.lineBreakMode = newValue }
		get { return self.paragraph?.lineBreakMode ?? .byTruncatingTail }
	}
	
	/// This property contains the space (measured in points) added at the end of the paragraph
	/// to separate it from the following paragraph.
	///
	/// This value must be nonnegative.
	/// The space between paragraphs is determined by adding the previous paragraph’s `paragraphSpacing`
	/// and the current paragraph’s `paragraphSpacingBefore`.
	///
	/// Default value is `0.0`.
	/// As part of the `paragraph` instance this value will be overriden if you set a new `paragraph`.
	public var paragraphSpacing: CGFloat {
		set { self.paragraph?.paragraphSpacing = newValue }
		get { return self.paragraph?.paragraphSpacing ?? 0.0 }
	}
	
	/// The distance between the paragraph’s top and the beginning of its text content.
	/// This property contains the space (measured in points) between the paragraph’s top
	/// and the beginning of its text content.
	///
	/// The default value of this property is `0.0`.
	/// As part of the `paragraph` instance this value will be overriden if you set a new `paragraph`.
	public var paragraphSpacingBefore: CGFloat {
		set { self.paragraph?.paragraphSpacingBefore = newValue }
		get { return self.paragraph?.paragraphSpacingBefore ?? 0.0 }
	}
	
	/// The distance (in points) from the leading margin of a text container to
	/// the beginning of the paragraph’s first line.
	/// This value is always nonnegative.
	/// Default value is `0.0`.
	///
	/// As part of the `paragraph` instance this value will be overriden if you set a new `paragraph`.
	public var firstLineHeadIndent: CGFloat {
		set { self.paragraph?.firstLineHeadIndent = newValue }
		get { return self.paragraph?.firstLineHeadIndent ?? 0.0 }
	}
	
	/// The distance (in points) from the leading margin of a text container to the beginning
	/// of lines other than the first.
	/// This value is always nonnegative.
	/// Default value is `0.0`.
	///
	/// As part of the `paragraph` instance this value will be overriden if you set a new `paragraph`.
	public var headIndent: CGFloat {
		set { self.paragraph?.headIndent = newValue }
		get { return self.paragraph?.headIndent ?? 0.0 }
	}
	
	/// If positive, this value is the distance from the leading margin
	/// (for example, the left margin in left-to-right text).
	/// If 0 or negative, it’s the distance from the trailing margin.
	///
	/// Default value is `0.0`.
	/// As part of the `paragraph` instance this value will be overriden if you set a new `paragraph`.
	public var tailIndent: CGFloat {
		set { self.paragraph?.tailIndent = newValue }
		get { return self.paragraph?.tailIndent ?? 0.0 }
	}
	
	
	/// The maximum height in points that any line in the receiver will occupy,
	/// regardless of the font size or size of any attached graphic.
	/// This value is always nonnegative.
	///
	/// Glyphs and graphics exceeding this height will overlap neighboring lines;
	/// however, a maximum height of 0 implies no line height limit.
	/// Although this limit applies to the line itself, line spacing adds extra space between adjacent lines.
	///
	/// The default value is `0.0`.
	/// As part of the `paragraph` instance this value will be overriden if you set a new `paragraph`.
	public var maximumLineHeight: CGFloat {
		set { self.paragraph?.maximumLineHeight = newValue }
		get { return self.paragraph?.maximumLineHeight ?? 0.0 }
	}
	
	/// The minimum height in points that any line in the receiver will occupy,
	/// regardless of the font size or size of any attached graphic.
	/// This value must be nonnegative.
	///
	/// The default value is `0.0`.
	/// As part of the `paragraph` instance this value will be overriden if you set a new `paragraph`.
	public var minimumLineHeight: CGFloat {
		set { self.paragraph?.minimumLineHeight = newValue }
		get { return self.paragraph?.minimumLineHeight ?? 0.0 }
	}
	
	/// The distance in points between the bottom of one line fragment and the top of the next.
	/// This value is always nonnegative.
	/// This value is included in the line fragment heights in the layout manager.
	///
	/// The default value is `0.0`.
	/// As part of the `paragraph` instance this value will be overriden if you set a new `paragraph`.
	public var lineSpacing: CGFloat {
		set { self.paragraph?.lineSpacing = newValue }
		get { return self.paragraph?.lineSpacing ?? 0.0 }
	}
	
	/// The natural line height of the receiver is multiplied by this factor (if positive)
	/// before being constrained by minimum and maximum line height.
	///
	/// The default value of this property is `0.0`.
	/// As part of the `paragraph` instance this value will be overriden if you set a new `paragraph`.
	public var lineHeightMultiple: CGFloat {
		set { self.paragraph?.lineHeightMultiple = newValue }
		get { return self.paragraph?.lineHeightMultiple ?? 0.0 }
	}
	
	//MARK: INTERNAL FUNCTIONS
	
	/// Set passed `value` at specified `key`.
	///
	/// - Parameters:
	///   - key: attribute's key to set.
	///   - value: value to set, `nil` will remove existing attribute.
	private func set<T>(attribute key: RichAttribute, value: T?) {
		if value == nil {
			self.attributes.removeValue(forKey: key)
		} else {
			self.attributes[key] = value
		}
	}
	
	/// Get the attribute from attributes dictionary with given key.
	///
	/// - Parameters:
	///   - key: key to search.
	///   - fallback: fallback value if no key is set.
	/// - Returns: value for given `key`, `fallback` value is not found and specified, `nil` otherwise.
	private func get<T>(attribute key: RichAttribute, fallback: T? = nil) -> T? {
		guard let v = self.attributes[key] as? T else {
			return fallback
		}
		return v
	}
	
	//MARK: RENDER
	
	/// Create a new `RichString` from given plain `String` by applying receiver attributes.
	///
	/// - Parameter string: source string to render.
	/// - Returns: new `RichString`.
	public func render(_ string: String) -> RichString {
		return RichString(string: string, attributes: self.attributes)
	}
	
	//MARK: PUBLIC FUNCTIONS
	
	/// Merge receiver with another `Style` and produce a new `Style` where merged instance
	/// may override initial receiver values.
	///
	/// - Parameter style: style to merge.
	/// - Returns: new merged `Style`.
	public func merge(with style: Style) -> Style {
		return Style(kind: self.kind, attributes: (self.attributes + style.attributes))
	}
	
	/// Create a new `Style` where attributes are copied from receiver giving the opportunity
	/// to override or add more attributes via configuration callback.
	///
	/// - Parameter configuration: optional callback used to add/replace attributes.
	/// - Returns: new derived `Style`.
	public func derivated(_ configuration: ((Style) -> (Void))) -> Style {
		return Style(self, configuration)
	}
	
	/// Just return the receiver. It's added to conformance to `StyleProtocol`.
	public var style: Style {
		return self
	}
}
