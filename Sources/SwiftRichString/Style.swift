//
//  Style.swift
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
#if os(iOS) || os(tvOS) || os(watchOS)
	public typealias LineBreakMode = NSLineBreakMode
	import UIKit
#elseif os(OSX)
	public typealias LineBreakMode = NSParagraphStyle.LineBreakMode
	import AppKit
#endif

/// This is the struct which defines a regular expression rule and a set of styles to apply
public struct RegExpPatternStyles {
	
	/// regular expression to match
	private(set) var regularExpression: NSRegularExpression
	
	/// Styles to apply
	private(set) var styles: [Style]
	
	
	/// Initialize a new rule to apply a set of styles
	///
	/// - Parameters:
	///   - pattern: pattern to match as regexp
	///   - opts: options for searching
	///   - styles: styles to apply
	public init?(pattern: String, opts: NSRegularExpression.Options = .caseInsensitive, styles: [Style]) {
		do {
			self.regularExpression = try NSRegularExpression(pattern: pattern, options: opts)
			self.styles = styles
		} catch {
			return nil
		}
	}
	
	/// Initialize a new regular expression matcher by defining a rule and a single style to apply when it matches
	///
	/// - Parameters:
	///   - pattern: pattern to match as regexp
	///   - opts: options for searching
	///   - style: style to apply, defined directly as a `StyleMaker` closure
	public init?(pattern: String, opts: NSRegularExpression.Options = .caseInsensitive, style maker: Style.StyleMaker) {
		do {
			self.regularExpression = try NSRegularExpression(pattern: pattern, options: opts)
			self.styles = [Style(maker)]
		} catch {
			return nil
		}
	}
}


//MARK: StyleType

/// StyleType define the type of a style
///
/// - `default`: this is the default style. If added to a MarkupString, default style is applied automatically to the entire string
///              before any other defined style is added to given text ranges.
/// - `none`: none allows you to specify a style without name which can be applied regardeless the tag on source string.
/// - named: custom style with given name
public enum StyleName {
	case `default`
	case named(String)
	case none
	
	public var value: String {
		switch self {
		case .default:
			return "#default"
		case .named(let name):
			return name
		case .none:
			return ""
		}
	}
}

//MARK: Style

public func == (lhs: Style, rhs: Style) -> Bool {
	return lhs.name.value == rhs.name.value
}

public class Style: Equatable {
	
	public typealias StyleMaker = ((_ maker: Style) -> (Void))
	
	/// Identifier of style
	public var name: StyleName
	
	/// Cache of attributes dictionary
	public fileprivate(set) var attributes: [NSAttributedStringKey:Any] = [.paragraphStyle : NSMutableParagraphStyle()]
	
	/// Initialize a new style with given type
	///
	/// - Parameters:
	///   - type: type of style
	///   - maker: a closure which allows you to contextually define styles to apply. Use $0.<text_property> to define each property you
	///            want to apply to style.
	private init(_ name: StyleName, _ maker: StyleMaker ) {
		self.name = name
		maker(self)
	}
	
	/// Create a new custom style with given name and attributes
	///
	/// - Parameters:
	///   - name: name of the style (used to apply defined attributes inside source string for defined tags inside these entities)
	///   - maker: a closure which allows you to contextually define styles to apply. Use $0.<text_property> to define each property you
	///            want to apply to style.
	/// - Returns: a new Style instance
	/// - Example:
	///		let italic = Style.new("italic", {
	///			$0.font = FontAttribute(.TimesNewRomanPSMT, size: 50)
	///			$0.color = SRColor.green
	///		})
	public init(_ name: String, _ maker: StyleMaker ) {
		self.name = .named(name)
		maker(self)
	}
	
	/// Create a new style without specify a name.
	/// You can't use it to parse content in MarkupString, however you can use it to apply it into a String or AttributedString
	///
	/// - Parameter maker: a closure which allows you to contextually define styles to apply. Use $0.<text_property> to define each property you want to apply to style.
	public init(_ maker: StyleMaker) {
		self.name = .none
		maker(self)
	}
	
	/// Create a new default attribute. Default attribute is applied to the string in first place.
	/// Any other attribute will be added to this default attribute if present.
	/// If you don't define a default attribute only other styles may change the attribute of your attributed string.
	///
	///   - maker: a closure which allows you to contextually define styles to apply. Use $0.<text_property> to define each property you
	///            want to apply to style.
	/// - Returns: a new Style instance
	public static func `default`(_ maker: StyleMaker ) -> Style {
		return Style(.default, maker)
	}
	
	/// Set or remove from cached attributes dict value for a specified key
	///
	/// - Parameters:
	///   - key: key to assign
	///   - value: value to assign (nil to remove key from cached dictionay, valid value to set)
	private func set(key: NSAttributedStringKey, value: Any?) {
		guard let setValue = value else {
			attributes.removeValue(forKey: key)
			return
		}
		attributes[key] = setValue
	}
	
	private func remove(key: NSAttributedStringKey) {
		attributes.removeValue(forKey: key)
	}
	
	/// Private cached ParagraphStyle instance
	private var paragraph: NSMutableParagraphStyle {
		get {
			return attributes[.paragraphStyle] as! NSMutableParagraphStyle
		}
	}
	
	/// The text alignment of the receiver.
	/// Natural text alignment is realized as left or right alignment depending on the line sweep direction of the first script contained in the paragraph.
	public var align: NSTextAlignment {
		set { self.paragraph.alignment = newValue }
		get { return self.paragraph.alignment }
	}
	
	/// The mode that should be used to break lines in the receiver.
	/// This property contains the line break mode to be used laying out the paragraph’s text.
	public var lineBreak: LineBreakMode {
		set { self.paragraph.lineBreakMode = newValue }
		get { return self.paragraph.lineBreakMode }
	}
	
	/// Writing direction (may be `rightToLeft`, `leftToRight` or `natural`
	public var writingDirection: NSWritingDirection {
		set { self.paragraph.baseWritingDirection = newValue }
		get { return self.paragraph.baseWritingDirection }
	}
	
	/// The space after the end of the paragraph.
	/// This property contains the space (measured in points) added at the end of the paragraph to separate it from the following paragraph.
	/// This value is always nonnegative. The space between paragraphs is determined by adding the previous paragraph’s paragraphSpacing
	/// and the current paragraph’s paragraphSpacingBefore.
	public var paragraphSpacing: Float {
		set { self.paragraph.paragraphSpacing = CGFloat(newValue) }
		get { return Float(self.paragraph.paragraphSpacing) }
	}
	
	/// Font to apply.
	/// This is the define as FontAttribute which allows to define typesafe font by it's name.
	/// Custom fonts created by name are also available.
	/// You can however extended FontAttribute to add your own custom font and make them type safe as they should be.
	public var font: FontAttribute? {
		set { self.set(key: .font, value: newValue?.font) }
		get { return FontAttribute(font: attributes[.font] as? SRFont ) }
	}
	
	/// The value of this attribute is a SRColor object. Use this attribute to specify the color of the text during rendering.
	// If you do not specify this attribute, the text is rendered in black.
	public var color: SRColor? {
		didSet { self.set(key: .foregroundColor, value: self.color) }
	}
	
	/// The value of this attribute is a SRColor object. Use this attribute to specify the color of the background area behind the text.
	/// If you do not specify this attribute, no background color is drawn.
	public var backColor: SRColor? {
		didSet { self.set(key: .backgroundColor, value: self.backColor) }
	}
	
	/// Define stroke attributes
	public var stroke: StrokeAttribute? {
		set {
			guard let stroke = newValue else {
				self.remove(key: .strokeColor)
				self.remove(key: .strokeWidth)
				return
			}
			self.set(key: .strokeWidth, value: stroke.width)
			self.set(key: .strokeColor, value: stroke.color)
		}
		get {
			return StrokeAttribute(color: attributes[.strokeColor] as? SRColor,
			                       width: attributes[.strokeWidth] as? CGFloat)
		}
	}
	
	/// Define underline attributes
	public var underline: UnderlineAttribute? {
		set {
			guard let underline = newValue else {
				self.remove(key: .underlineColor)
				self.remove(key: .underlineStyle)
				return
			}
            self.set(key: .underlineStyle, value: underline.style?.rawValue)
			self.set(key: .underlineColor, value: underline.color)
		}
		get {
			return UnderlineAttribute(color: attributes[.underlineColor] as? SRColor,
			                          style: attributes[.underlineStyle] as? NSUnderlineStyle)
		}
	}
	
	/// Define the underline attributes of the text
	public var strike: StrikeAttribute? {
		set {
			guard let strike = newValue else {
				self.remove(key: .strikethroughStyle)
				self.remove(key: .strikethroughColor)
				return
			}
			self.set(key: .strikethroughStyle, value: strike.style?.rawValue)
			self.set(key: .strikethroughColor, value: strike.color)
		}
		get {
			return StrikeAttribute(color: attributes[.strikethroughColor] as? SRColor,
			                       style: attributes[.strikethroughStyle] as? NSUnderlineStyle)
		}
	}

	/// The value of this attribute is an NSShadow object. The default value of this property is nil.
	#if os(iOS) || os(macOS) || os(tvOS)
	public var shadow: ShadowAttribute? {
		set { self.set(key: .shadow, value: newValue?.shadowObj) }
		get { return ShadowAttribute(shadow: attributes[.shadow] as? NSShadow) }
	}
	#endif
	
	/// The indentation of the first line of the receiver.
	/// This property contains the distance (in points) from the leading margin of a text container to the beginning of the paragraph’s first line.
	/// This value is always nonnegative.
	public var firstLineHeadIntent: Float {
		set { self.paragraph.firstLineHeadIndent = CGFloat(newValue) }
		get { return Float(self.paragraph.firstLineHeadIndent) }
	}
	
	/// The indentation of the receiver’s lines other than the first.
	/// This property contains the distance (in points) from the leading margin of a text container to the beginning of lines other than the first.
	/// This value is always nonnegative.
	public var headIndent: Float {
		set { self.paragraph.headIndent = CGFloat(newValue) }
		get { return Float(self.paragraph.headIndent) }
	}
	
	/// The trailing indentation of the receiver.
	/// If positive, this value is the distance from the leading margin (for example, the left margin in left-to-right text).
	/// If 0 or negative, it’s the distance from the trailing margin.
	///
	/// For example, a paragraph style designed to fit exactly in a 2-inch wide container has a head indent of 0.0 and a tail indent of 0.0.
	/// One designed to fit with a quarter-inch margin has a head indent of 0.25 and a tail indent of –0.25.
	public var tailIndent: Float {
		set { self.paragraph.tailIndent = CGFloat(newValue) }
		get { return Float(self.paragraph.tailIndent) }
	}
	
	/// The receiver’s maximum line height.
	/// This property contains the maximum height in points that any line in the receiver will occupy, regardless of the font size or size of
	/// any attached graphic. This value is always nonnegative. The default value is 0.
	///
	/// Glyphs and graphics exceeding this height will overlap neighboring lines; however, a maximum height of 0 implies no line height limit.
	/// Although this limit applies to the line itself, line spacing adds extra space between adjacent lines.
	public var maximumLineHeight: Float {
		set { self.paragraph.maximumLineHeight = CGFloat(newValue) }
		get { return Float(self.paragraph.maximumLineHeight) }
	}
	
	/// The receiver’s minimum height.
	/// This property contains the minimum height in points that any line in the receiver will occupy,
	/// regardless of the font size or size of any attached graphic. This value is always nonnegative
	public var minimumLineHeight: Float {
		set { self.paragraph.minimumLineHeight = CGFloat(newValue) }
		get { return Float(self.paragraph.minimumLineHeight) }
	}
	
	/// The distance in points between the bottom of one line fragment and the top of the next.
	/// This value is always nonnegative. This value is included in the line fragment heights in the layout manager.
	public var lineSpacing: Float {
		set { self.paragraph.lineSpacing = CGFloat(newValue) }
		get { return Float(self.paragraph.lineSpacing) }
	}
	
	/// The distance between the paragraph’s top and the beginning of its text content.
	/// This property contains the space (measured in points) between the paragraph’s top and the beginning of its text content.
	/// The default value of this property is 0.0.
	public var paragraphSpacingBefore: Float {
		set { self.paragraph.paragraphSpacingBefore = CGFloat(newValue) }
		get { return Float(self.paragraph.paragraphSpacingBefore) }
	}
	
	/// The line height multiple.
	/// The natural line height of the receiver is multiplied by this factor (if positive) before being constrained by minimum and maximum line height.
	/// The default value of this property is 0.0.
	public var lineHeightMultiple: Float {
		set { self.paragraph.lineHeightMultiple = CGFloat(newValue) }
		get { return Float(self.paragraph.lineHeightMultiple) }
	}
	
	/// The paragraph’s threshold for hyphenation.
	/// Hyphenation is attempted when the ratio of the text width (as broken without hyphenation) to the width of the line fragment is less than
	/// the hyphenation factor. When the paragraph’s hyphenation factor is 0.0, the layout manager’s hyphenation factor is used instead.
	/// When both are 0.0, hyphenation is disabled.
	public var hyphenationFactor: Float {
		set { self.paragraph.hyphenationFactor = newValue }
		get { return self.paragraph.hyphenationFactor }
	}
	
	/// Ligatures cause specific character combinations to be rendered using a single custom glyph that corresponds to those characters.
	/// The value 0 indicates no ligatures. The value 1 indicates the use of the default ligatures.
	/// The value 2 indicates the use of all ligatures. The default value for this attribute is 1. (Value 2 is unsupported on iOS.)
	public var ligature: Int? {
		didSet { self.set(key: .ligature, value: self.ligature) }
	}
	
	/// This value specifies the number of points by which to adjust kern-pair characters.
	/// Kerning prevents unwanted space from occurring between specific characters and depends on the font.
	/// The value 0 means kerning is disabled. The default value for this attribute is 0.
	public var kern: Float? {
		didSet { self.set(key: .kern, value: self.kern) }
	}
	
	/// The value of this attribute is an NSString object. Use this attribute to specify a text effect, such as NSTextEffectLetterpressStyle.
	/// The default value of this property is nil, indicating no text effect.
	public var textEffect: String? {
		didSet { self.set(key: .textEffect, value: self.textEffect) }
	}
	
	/// The value of this attribute is an NSTextAttachment object. The default value of this property is nil, indicating no attachment.
	#if os(iOS) || os(macOS)
	public var attach: NSTextAttachment? {
		didSet { self.set(key: .attachment, value: self.attach) }
	}
	#endif
	
	/// The value of this attribute is an NSURL object (preferred) or an NSString object. The default value of this property is nil, indicating no link.
	public var linkURL: URL? {
		didSet { self.set(key: .link, value: self.linkURL) }
	}
	
	/// Floating point value indicating the character’s offset from the baseline, in points. The default value is 0.
	public var baselineOffset: Float? {
		didSet { self.set(key: .baselineOffset, value: self.baselineOffset) }
	}
	
	/// Floating point value indicating skew to be applied to glyphs. The default value is 0, indicating no skew.
	public var oblique: Float? {
		didSet { self.set(key: .obliqueness, value: self.oblique) }
	}
	
	/// Floating point value indicating the log of the expansion factor to be applied to glyphs. The default value is 0, indicating no expansion.
	public var expansion: Float? {
		didSet { self.set(key: .expansion, value: self.expansion) }
	}

	/// The value of this attribute is an NSArray object containing NSNumber objects representing the nested levels of writing direction overrides, 
	/// in order from outermost to innermost.
	public var direction: NSWritingDirection? {
		didSet { self.set(key: .writingDirection, value: self.direction) }
	}
	
	/// The value 0 indicates horizontal text. The value 1 indicates vertical text. In iOS, horizontal text is always used and specifying
	/// a different value is undefined.
	public var glyphForm: Int? {
		didSet { self.set(key: .verticalGlyphForm, value: self.glyphForm) }
	}
	
}
