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

/// Style class encapsulate all the information about the attributes you can apply to a text.
public class Style: StyleProtocol {
	
	//MARK: - INTERNAL PROPERTIES

	/// Handler to initialize a new style.
	public typealias StyleInitHandler = ((Style) -> (Void))
	
	/// Contains font description and size along with all other additional
	/// attributes to render the text. You should not need to modify this object;
	/// configurable attributes are exposed at `Style` level.
	private var fontInfo: FontInfo = FontInfo()
	
	/// Attributes defined by the style. This is the dictionary modified when you
	/// set a style attributed.
	private var innerAttributes: [NSAttributedStringKey : Any] = [:]
	
	/// This is a cache array used to avoid the evaluation of font description and other
	/// sensitive data. Cache is invalidated automatically when needed.
	private var cachedAttributes: [NSAttributedStringKey : Any]? = nil
	
	//MARK: - PROPERTIES

	/// Alter the size of the currently set font to the specified value (expressed in point)
	public var size: CGFloat {
		set {
			self.fontInfo.size = newValue
			self.invalidateCache()
		}
		get { return self.fontInfo.size }
	}
	
	/// Set the font of the style.
	/// You can pass any `FontConvertible` conform object, it will be transformed to a valid `UIFont`/`NSFont``
	/// and used by the style itself. Both `String`, `SystemFonts` and `UIFont`/`NSFont` are conform to this protocol yet
	/// so you are able to pass a valid font as a string, from predefined list or directly as an instance.
	public var font: FontConvertible {
		set {
			self.fontInfo.font = newValue
			if let f = newValue as? Font {
				self.fontInfo.size = f.pointSize
			}
			self.invalidateCache()
		}
		get { return self.fontInfo.font }
	}

	/// Set the text color of the style.
	/// You can pass any `ColorConvertible` conform object, it will be transformed to a valid `UIColor`/`NSColor`
	/// automatically. Both `UIColor`/`NSColor` and `String` are conform to this protocol.
	public var color: ColorConvertible? {
		set { self.set(attribute: newValue?.color, forKey: .foregroundColor) }
		get { return self.get(attributeForKey: .foregroundColor) }
	}
	
	/// Set the background color of the style.
	/// You can pass any `ColorConvertible` conform object, it will be transformed to a valid `UIColor`/`NSColor`
	/// automatically. Both `UIColor`/`NSColor` and `String` are conform to this protocol.
	public var backColor: ColorConvertible? {
		set { self.set(attribute: newValue?.color, forKey: .backgroundColor) }
		get { return self.get(attributeForKey: .backgroundColor) }
	}
	
	/// This value indicates whether the text is underlined.
	/// Value must be a tuple which define the style of the line (as `NSUnderlineStyle`)
	/// and the optional color of the line (if `nil`, foreground color is used instead).
	public var underline: (style: NSUnderlineStyle?, color: ColorConvertible?)? {
		set {
			self.set(attribute: NSNumber.from(underlineStyle: newValue?.style), forKey: .underlineStyle)
			self.set(attribute: newValue?.color?.color, forKey: .underlineColor)
		}
		get {
			let style: NSNumber? = self.get(attributeForKey: .underlineStyle)
			let color: Color? = self.get(attributeForKey: .underlineColor)
			return (style?.toUnderlineStyle(),color)
		}
	}
	
	/// This value indicates whether the text has a line through it.
	/// Value must be a tuple which define the style of the line (as `NSUnderlineStyle`)
	/// and the optional color of the line (if `nil`, foreground color is used instead).
	public var strikethrough: (style: NSUnderlineStyle?, color: ColorConvertible?)? {
		set {
			self.set(attribute: NSNumber.from(underlineStyle: newValue?.style), forKey: .strikethroughStyle)
			self.set(attribute: newValue?.color?.color, forKey: .strikethroughColor)
		}
		get {
			let style: NSNumber? = self.get(attributeForKey: .strikethroughStyle)
			let color: Color? = self.get(attributeForKey: .strikethroughColor)
			return (style?.toUnderlineStyle(),color)
		}
	}
	
	/// Floating point value indicating the character’s offset from the baseline, in points.
	/// Default value when not set is 0.
	public var baselineOffset: Float? {
		set { self.set(attribute: NSNumber.from(float: newValue), forKey: .baselineOffset) }
		get {
			let value: NSNumber? = self.get(attributeForKey: .baselineOffset)
			return value?.floatValue
		}
	}
	
	/// Allows to set a default paragraph style to the content.
	/// A new `NSMutableParagraphStyle` instance is created automatically when you set any paragraph
	/// related property if an instance is not set yet.
	public var paragraph: NSMutableParagraphStyle {
		set {
			self.invalidateCache()
			self.set(attribute: newValue, forKey: .paragraphStyle)
		}
		get {
			if let paragraph: NSMutableParagraphStyle = self.get(attributeForKey: .paragraphStyle) {
				return paragraph
			}
			let paragraph = NSMutableParagraphStyle()
			self.set(attribute: paragraph, forKey: .paragraphStyle)
			return paragraph
		}
	}
	
	/// The distance in points between the bottom of one line fragment and the top of the next.
	/// This value is always nonnegative.
	/// This value is included in the line fragment heights in the layout manager.
	/// The default value is 0.
	public var lineSpacing: CGFloat {
		set { self.paragraph.lineSpacing = newValue }
		get { return self.paragraph.lineSpacing }
	}
	
	/// The distance between the paragraph’s top and the beginning of its text content.
	/// This property contains the space (measured in points) between the paragraph’s top
	/// and the beginning of its text content.
	///
	/// The default value of this property is 0.
	public var paragraphSpacingBefore: CGFloat {
		set { self.paragraph.paragraphSpacingBefore = newValue }
		get { return self.paragraph.paragraphSpacingBefore }
	}
	
	/// This property contains the space (measured in points) added at the end of the paragraph
	/// to separate it from the following paragraph.
	///
	/// This value must be nonnegative.
	/// The space between paragraphs is determined by adding the previous paragraph’s `paragraphSpacing`
	/// and the current paragraph’s `paragraphSpacingBefore`.
	///
	/// Default value is 0.
	public var paragraphSpacingAfter: CGFloat {
		set { self.paragraph.paragraphSpacing = newValue }
		get { return self.paragraph.paragraphSpacing }
	}
	
	/// The text alignment of the receiver.
	/// By default value is `natural`, depending by system's locale.
	/// Natural text alignment is realized as left or right alignment depending on the line sweep
	/// direction of the first script contained in the paragraph.
	///
	/// Default value is `natural`.
	public var alignment: NSTextAlignment {
		set { self.paragraph.alignment = newValue }
		get { return self.paragraph.alignment }
	}
	
	/// The distance (in points) from the leading margin of a text container to
	/// the beginning of the paragraph’s first line.
	/// This value is always nonnegative.
	///
	/// Default value is 0.
	public var firstLineHeadIndent: CGFloat {
		set { self.paragraph.firstLineHeadIndent = newValue }
		get { return self.paragraph.firstLineHeadIndent }
	}
	
	/// The distance (in points) from the leading margin of a text container to the beginning
	/// of lines other than the first.
	/// This value is always nonnegative.
	///
	/// Default value is 0.
	public var headIndent: CGFloat {
		set { self.paragraph.headIndent = newValue }
		get { return self.paragraph.headIndent }
	}
	
	/// If positive, this value is the distance from the leading margin
	/// (for example, the left margin in left-to-right text).
	/// If 0 or negative, it’s the distance from the trailing margin.
	///
	/// Default value is `0.0`.
	public var tailIndent: CGFloat {
		set { self.paragraph.tailIndent = newValue }
		get { return self.paragraph.tailIndent }
	}
	
	/// The mode that should be used to break lines.
	///
	/// Default value is `byTruncatingTail`.
	public var lineBreakMode: LineBreak {
		set { self.paragraph.lineBreakMode = newValue }
		get { return self.paragraph.lineBreakMode }
	}
	
	/// The minimum height in points that any line in the receiver will occupy,
	/// regardless of the font size or size of any attached graphic.
	/// This value must be nonnegative.
	///
	/// The default value is 0.
	public var minimumLineHeight: CGFloat {
		set { self.paragraph.minimumLineHeight = newValue }
		get { return self.paragraph.minimumLineHeight }
	}
	
	/// The maximum height in points that any line in the receiver will occupy,
	/// regardless of the font size or size of any attached graphic.
	/// This value is always nonnegative.
	///
	/// Glyphs and graphics exceeding this height will overlap neighboring lines;
	/// however, a maximum height of 0 implies no line height limit.
	/// Although this limit applies to the line itself, line spacing adds extra space between adjacent lines.
	///
	/// The default value is 0.
	public var maximumLineHeight: CGFloat {
		set { self.paragraph.maximumLineHeight = newValue }
		get { return self.paragraph.maximumLineHeight }
	}
	
	/// The initial writing direction used to determine the actual writing direction for text.
	/// The default value of this property is `natural`.
	///
	/// The Text system uses this value as a hint for calculating the actual direction for displaying Unicode characters.
	/// If you know the base writing direction of the text you are rendering, you can set the value of this property
	/// to the correct direction to help the text system.
	public var baseWritingDirection: NSWritingDirection {
		set { self.paragraph.baseWritingDirection = newValue }
		get { return self.paragraph.baseWritingDirection }
	}
	
	/// The natural line height of the receiver is multiplied by this factor (if positive)
	/// before being constrained by minimum and maximum line height.
	///
	/// The default value of this property is 0.
	public var lineHeightMultiple: CGFloat {
		set { self.paragraph.lineHeightMultiple = newValue }
		get { return self.paragraph.lineHeightMultiple }
	}
	
	/// The threshold controlling when hyphenation is attempted.
	public var hyphenationFactor: Float {
		set { self.paragraph.hyphenationFactor = newValue }
		get { return self.paragraph.hyphenationFactor }
	}
	
	/// Ligatures cause specific character combinations to be rendered using a single custom glyph that corresponds
	/// to those characters.
	/// 
	/// The default value for this attribute is `defaults`. (Value `all` is unsupported on iOS.)
	public var ligatures: Ligatures? {
		set {
			self.set(attribute: NSNumber.from(int: newValue?.rawValue), forKey: .ligature)
		}
		get {
			guard let value: NSNumber = self.get(attributeForKey: .ligature) else { return nil }
			return Ligatures(rawValue: value.intValue)
		}
	}
	
	#if os(iOS) || os(tvOS) || os(watchOS)
	
	/// Enable spoken of all punctuation in the text.
	public var speaksPunctuation: Bool? {
		set { self.set(attribute: newValue, forKey: NSAttributedStringKey(UIAccessibilitySpeechAttributePunctuation)) }
		get { return self.get(attributeForKey: NSAttributedStringKey(UIAccessibilitySpeechAttributePunctuation)) }
	}
	
	/// The language to use when speaking a string (value is a BCP 47 language code string).
	public var speakingLanguage: String? {
		set { self.set(attribute: newValue, forKey: NSAttributedStringKey(UIAccessibilitySpeechAttributeLanguage)) }
		get { return self.get(attributeForKey: NSAttributedStringKey(UIAccessibilitySpeechAttributeLanguage)) }
	}
	
	/// Pitch to apply to spoken content. Value must be in range range 0.0 to 2.0.
	/// The value indicates whether the text should be specified spoken with a higher or lower pitch
	/// than is used for the default.
	/// Values between 0.0 and 1.0 result in a lower pitch and values between 1.0 and 2.0 result in a higher pitch.
	///
	/// The default value for this attribute is 1.0, which indicates a normal pitch.
	public var speakingPitch: Double? {
		set { self.set(attribute: newValue, forKey: NSAttributedStringKey(UIAccessibilitySpeechAttributePitch)) }
		get { return self.get(attributeForKey: NSAttributedStringKey(UIAccessibilitySpeechAttributePitch)) }
	}

	/// No overview available.
	/// Note: available only from iOS 11, tvOS 11 and watchOS 4.
	@available(iOS 11.0, tvOS 11.0, iOSApplicationExtension 11.0, watchOS 4, *)
	public var speakingPronunciation: String? {
		set { self.set(attribute: newValue, forKey: NSAttributedStringKey(UIAccessibilitySpeechAttributeIPANotation)) }
		get { return self.get(attributeForKey: NSAttributedStringKey(UIAccessibilitySpeechAttributeIPANotation)) }
	}
	
	/// Spoken text is queued behind, or interrupts, existing spoken content.
	/// When the value is true, this announcement is queued behind existing speech.
	/// When the value is false, the announcement interrupts the existing speech.
	///
	/// The default behavior is to interrupt existing speech.
	@available(iOS 11.0, tvOS 11.0, iOSApplicationExtension 11.0, watchOS 4, *)
	public var shouldQueueSpeechAnnouncement: Bool? {
		set {
			let key = NSAttributedStringKey(UIAccessibilitySpeechAttributeQueueAnnouncement)
			guard let v = newValue else {
				self.innerAttributes.removeValue(forKey: key)
				return
			}
			self.set(attribute: NSNumber.init(value: v), forKey: key)
		}
		get {
			let key = NSAttributedStringKey(UIAccessibilitySpeechAttributeQueueAnnouncement)
			if let n: NSNumber = self.get(attributeForKey: key) {
				return n.boolValue
			} else { return false }
		}
	}
	
	/// Specify the heading level of the text.
	/// Value is a number in the range 0 to 6.
	/// Use 0 to indicate the absence of a specific heading level and use other numbers to indicate the heading level.
	@available(iOS 11.0, tvOS 11.0, iOSApplicationExtension 11.0, watchOS 4, *)
	public var headingLevel: HeadingLevel? {
		set {
			let key = NSAttributedStringKey(UIAccessibilityTextAttributeHeadingLevel)
			guard let v = newValue else {
				self.innerAttributes.removeValue(forKey: key)
				return
			}
			self.set(attribute: v.rawValue, forKey: key)
		}
		get {
			let key = NSAttributedStringKey(UIAccessibilityTextAttributeHeadingLevel)
			if let n: Int = self.get(attributeForKey: key) {
				return HeadingLevel(rawValue: n)
			} else { return nil }
		}
	}
	
	#endif
	
	#if os(OSX) || os(iOS) || os(tvOS)
	
	///  Configuration for the number case, also known as "figure style".
	public var numberCase: NumberCase? {
		set { self.fontInfo.numberCase = newValue }
		get { return self.fontInfo.numberCase }
	}
	
	/// Configuration for number spacing, also known as "figure spacing".
	public var numberSpacing: NumberSpacing? {
		set { self.fontInfo.numberSpacing = newValue }
		get { return self.fontInfo.numberSpacing }
	}
	
	/// Configuration for displyaing a fraction.
	public var fractions: Fractions? {
		set { self.fontInfo.fractions = newValue }
		get { return self.fontInfo.fractions }
	}
	
	/// Superscript (superior) glpyh variants are used, as in footnotes¹.
	public var superscript: Bool? {
		set { self.fontInfo.superscript = newValue }
		get { return self.fontInfo.superscript }
	}
	
	/// Subscript (inferior) glyph variants are used: vₑ.
	public var `subscript`: Bool? {
		set { self.fontInfo.subscript = newValue }
		get { return self.fontInfo.subscript }
	}

	/// Ordinal glyph variants are used, as in the common typesetting of 4th.
	public var ordinals: Bool? {
		set { self.fontInfo.ordinals = newValue }
		get { return self.fontInfo.ordinals }
	}
	
	/// Scientific inferior glyph variants are used: H₂O
	public var scientificInferiors: Bool? {
		set { self.fontInfo.scientificInferiors = newValue }
		get { return self.fontInfo.scientificInferiors }
	}
	
	/// Configure small caps behavior.
	/// `fromUppercase` and `fromLowercase` can be combined: they are not mutually exclusive.
	public var smallCaps: Set<SmallCaps> {
		set { self.fontInfo.smallCaps = newValue }
		get { return self.fontInfo.smallCaps }
	}

	/// Different stylistic alternates available for customizing a font.
	///
	/// Typically, a font will support a small subset of these alternates, and
	/// what they mean in a particular font is up to the font's creator.
	///
	/// For example, in Apple's San Francisco font, turn on alternate set "six" to
	/// enable high-legibility alternates for ambiguous characters like: 0lI164.
	public var stylisticAlternates: StylisticAlternates {
		set { self.fontInfo.stylisticAlternates = newValue }
		get { return self.fontInfo.stylisticAlternates }
	}
	
	/// Different contextual alternates available for customizing a font.
	/// Note: Not all fonts support all (or any) of these options.
	public var contextualAlternates: ContextualAlternates {
		set { self.fontInfo.contextualAlternates = newValue }
		get { return self.fontInfo.contextualAlternates }
	}
	
	/// Tracking to apply.
	public var kerning: Kerning? {
		set { self.fontInfo.kerning = newValue }
		get { return self.fontInfo.kerning }
	}
	
	/// Describe trait variants to apply to the font.
	public var traitVariants: TraitVariant? {
		set { self.fontInfo.traitVariants = newValue }
		get { return self.fontInfo.traitVariants }
	}

	#endif

	//MARK: - INIT
	
	/// Initialize a new style with optional configuration handler callback.
	///
	/// - Parameter handler: configuration handler callback.
	public init(_ handler: StyleInitHandler? = nil) {
		self.fontInfo.style = self
		#if os(tvOS)
		self.set(attribute: Font.systemFont(ofSize: TVOS_SYSTEMFONT_SIZE), forKey: .font)
		#elseif os(watchOS)
		self.set(attribute: Font.systemFont(ofSize: WATCHOS_SYSTEMFONT_SIZE), forKey: .font)
		#else
		self.set(attribute: Font.systemFont(ofSize: Font.systemFontSize), forKey: .font)
		#endif
		handler?(self)
	}
	
	/// Initialize a new style from a predefined set of attributes.
	/// Font related attributes are not set automatically but are encapsulasted to the font object itself.
	///
	/// - Parameter dictionary: dictionary to set
	public init(dictionary: [NSAttributedStringKey: Any]?) {
		self.fontInfo.style = self
		if let font = dictionary?[.font] as? Font {
			self.fontInfo.font = font
			self.fontInfo.size = font.pointSize
		}
		self.innerAttributes = (dictionary ?? [:])
	}
	
	/// Initialize a new Style by cloning an existing style.
	///
	/// - Parameter style: style to clone
	public init(style: Style) {
		self.fontInfo.style = self
		self.innerAttributes = style.innerAttributes
		self.fontInfo = style.fontInfo
	}
	
	//MARK: - INTERNAL METHODS

	/// Invalidate cache
	internal func invalidateCache() {
		self.cachedAttributes = nil
	}
	
	//MARK: - PUBLIC METHODS
	
	/// Set a raw `NSAttributedStringKey`'s attribute value.
	///
	/// - Parameters:
	///   - value: valid value to set, `nil` to remove exiting value for given key.
	///   - key: key to set
	public func set<T>(attribute value: T?, forKey key: NSAttributedStringKey) {
		guard let value = value else {
			self.innerAttributes.removeValue(forKey: key)
			return
		}
		self.innerAttributes[key] = value
		self.invalidateCache()
	}
	
	/// Get the raw value for given `NSAttributedStringKey` key.
	///
	/// - Parameter key: key to read.
	/// - Returns: value or `nil` if value is not set.
	public func get<T>(attributeForKey key: NSAttributedStringKey) -> T? {
		return (self.innerAttributes[key] as? T)
	}
	
	/// Return all attributes defined by the style.
	public var attributes: [NSAttributedStringKey : Any] {
		if let cachedAttributes = self.cachedAttributes {
			return cachedAttributes
		}
		// generate font from `fontInfo` attributes collection, then merge it with the inner attributes of the
		// string to generate a single attributes dictionary for `NSAttributedString`.
		self.cachedAttributes = self.innerAttributes.merging(self.fontInfo.attributes) { (_, new) in return new }
		return self.cachedAttributes!
	}
	
	/// Create a new style copy of `self` with the opportunity to configure it via configuration callback.
	///
	/// - Parameter handler: configuration handler.
	/// - Returns: configured style.
	public func byAdding(_ handler: StyleInitHandler) -> Style {
		let styleCopy = Style(style: self)
		handler(styleCopy)
		return styleCopy
	}
}
