//
//  SwiftRichString
//  https://github.com/malcommac/SwiftRichString
//  Copyright (c) 2020 Daniele Margutti (hello@danielemargutti.com).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

/// Style class encapsulate all the information about the attributes you can apply to a text.
public struct Style: StyleProtocol {
	
	//MARK: - INTERNAL PROPERTIES

	/// Handler to initialize a new style.
	public typealias StyleInitHandler = ((inout Style) -> (Void))
	
	/// Contains font description and size along with all other additional
	/// attributes to render the text. You should not need to modify this object;
	/// configurable attributes are exposed at `Style` level.
	public var fontStyle: FontStyle? = FontStyle()
    
    
    /// See `fontStyle`.
    @available(*, deprecated, message: "Use fontStyle instead")
    public var fontData: FontStyle? {
        fontStyle
    }
	
	/// Attributes defined by the style. This is the dictionary modified when you
	/// set a style attributed.
	private var innerAttributes: [NSAttributedString.Key : Any] = [:]
	
	//MARK: - PROPERTIES
    
    /// Apply any transform to the text.
    public var textTransforms: [TextTransform]?

	/// Alter the size of the currently set font to the specified value (expressed in point)
	/// **Note**: in order to be used you must also set the `.font` attribute of the style.
	public var size: CGFloat? {
		set { fontStyle?.size = newValue }
		get { fontStyle?.size }
	}
	
	/// Set the font of the style.
	/// You can pass any `FontConvertible` conform object, it will be transformed to a valid `UIFont`/`NSFont``
	/// and used by the style itself. Both `String`, `SystemFonts` and `UIFont`/`NSFont` are conform to this protocol yet
	/// so you are able to pass a valid font as a string, from predefined list or directly as an instance.
	public var font: FontConvertible? {
		set {
			fontStyle?.font = newValue
            fontStyle?.size = (newValue as? Font)?.pointSize
		}
		get { fontStyle?.font }
	}

	#if os(tvOS) || os(watchOS) || os(iOS)
    /// Set the dynamic text attributes to adapt the font/text to the current Dynamic Type settings.
    /// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(iOS 11.0, tvOS 11.0, iOSApplicationExtension 11.0, watchOS 4, *)
    public var dynamicText: DynamicText? {
        set { fontStyle?.dynamicText = newValue }
        get { fontStyle?.dynamicText }
    }
	#endif

	/// Set the text color of the style.
	/// You can pass any `ColorConvertible` conform object, it will be transformed to a valid `UIColor`/`NSColor`
	/// automatically. Both `UIColor`/`NSColor` and `String` are conform to this protocol.
	public var color: ColorConvertible? {
		set { set(attribute: newValue?.color, forKey: .foregroundColor) }
        mutating get { get(attributeForKey: .foregroundColor) }
	}
	
	/// Set the background color of the style.
	/// You can pass any `ColorConvertible` conform object, it will be transformed to a valid `UIColor`/`NSColor`
	/// automatically. Both `UIColor`/`NSColor` and `String` are conform to this protocol.
	public var backColor: ColorConvertible? {
		set { set(attribute: newValue?.color, forKey: .backgroundColor) }
        mutating get { get(attributeForKey: .backgroundColor) }
	}
	
	/// This value indicates whether the text is underlined.
	/// Value must be a tuple which define the style of the line (as `NSUnderlineStyle`)
	/// and the optional color of the line (if `nil`, foreground color is used instead).
	public var underline: (style: NSUnderlineStyle?, color: ColorConvertible?)? {
		set {
			set(attribute: NSNumber.from(underlineStyle: newValue?.style), forKey: .underlineStyle)
			set(attribute: newValue?.color?.color, forKey: .underlineColor)
		}
        mutating get {
			let style: NSNumber? = get(attributeForKey: .underlineStyle)
			let color: Color? = get(attributeForKey: .underlineColor)
			return (style?.toUnderlineStyle(),color)
		}
	}
	
	/// Define stroke attributes
	/// Value must be a tuple which defines the color of the line and the width.
	///
	/// If `color` it is not defined it is assumed to be the same as the value of color;
	/// otherwise, it describes the outline color.
	///
	/// The `width` value represents the amount to change the stroke width and is specified as a percentage
	/// of the font point size. Specify 0 (the default) for no additional changes.
	/// Specify positive values to change the stroke width alone.
	/// Specify negative values to stroke and fill the text. For example, a typical value for
	/// outlined text would be -3.0.
	public var stroke: (color: ColorConvertible?, width: Float?)? {
		set {
			set(attribute: newValue?.color?.color, forKey: .strokeColor)
			set(attribute: NSNumber.from(float: newValue?.width), forKey: .strokeWidth)
		}
        mutating get {
			let color: Color? = get(attributeForKey: .strokeColor)
			let width: NSNumber? = get(attributeForKey: .strokeWidth)
			return (color,width?.floatValue)
		}
	}
	
	/// This value indicates whether the text has a line through it.
	/// Value must be a tuple which define the style of the line (as `NSUnderlineStyle`)
	/// and the optional color of the line (if `nil`, foreground color is used instead).
	public var strikethrough: (style: NSUnderlineStyle?, color: ColorConvertible?)? {
		set {
			set(attribute: NSNumber.from(underlineStyle: newValue?.style), forKey: .strikethroughStyle)
			set(attribute: newValue?.color?.color, forKey: .strikethroughColor)
		}
        mutating get {
			let style: NSNumber? = get(attributeForKey: .strikethroughStyle)
			let color: Color? = get(attributeForKey: .strikethroughColor)
			return (style?.toUnderlineStyle(),color)
		}
	}
	
	/// Floating point value indicating the character’s offset from the baseline, in points.
	/// Default value when not set is 0.
	public var baselineOffset: Float? {
		set { set(attribute: NSNumber.from(float: newValue), forKey: .baselineOffset) }
        mutating get {
			let value: NSNumber? = get(attributeForKey: .baselineOffset)
			return value?.floatValue
		}
	}
	
	/// Allows to set a default paragraph style to the content.
	/// A new `NSMutableParagraphStyle` instance is created automatically when you set any paragraph
	/// related property if an instance is not set yet.
	public var paragraph: NSMutableParagraphStyle {
		set { set(attribute: newValue, forKey: .paragraphStyle) }
        mutating get { get(attributeForKey: .paragraphStyle, builder: { NSMutableParagraphStyle() })! }
		
	}
	
	/// The distance in points between the bottom of one line fragment and the top of the next.
	/// This value is always nonnegative.
	/// This value is included in the line fragment heights in the layout manager.
	/// The default value is 0.
	public var lineSpacing: CGFloat {
		set { paragraph.lineSpacing = newValue }
        mutating get { paragraph.lineSpacing }
	}
	
	/// The distance between the paragraph’s top and the beginning of its text content.
	/// This property contains the space (measured in points) between the paragraph’s top
	/// and the beginning of its text content.
	///
	/// The default value of this property is 0.
	public var paragraphSpacingBefore: CGFloat {
		set { paragraph.paragraphSpacingBefore = newValue }
        mutating get { paragraph.paragraphSpacingBefore }
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
		set { paragraph.paragraphSpacing = newValue }
        mutating get { paragraph.paragraphSpacing }
	}
	
	/// The text alignment of the receiver.
	/// By default value is `natural`, depending by system's locale.
	/// Natural text alignment is realized as left or right alignment depending on the line sweep
	/// direction of the first script contained in the paragraph.
	///
	/// Default value is `natural`.
	public var alignment: NSTextAlignment {
		set { paragraph.alignment = newValue }
        mutating get { paragraph.alignment }
	}
	
	/// The distance (in points) from the leading margin of a text container to
	/// the beginning of the paragraph’s first line.
	/// This value is always nonnegative.
	///
	/// Default value is 0.
	public var firstLineHeadIndent: CGFloat {
		set { paragraph.firstLineHeadIndent = newValue }
        mutating get { paragraph.firstLineHeadIndent }
	}
	
	/// The distance (in points) from the leading margin of a text container to the beginning
	/// of lines other than the first.
	/// This value is always nonnegative.
	///
	/// Default value is 0.
	public var headIndent: CGFloat {
		set { paragraph.headIndent = newValue }
        mutating get { paragraph.headIndent }
	}
	
	/// If positive, this value is the distance from the leading margin
	/// (for example, the left margin in left-to-right text).
	/// If 0 or negative, it’s the distance from the trailing margin.
	///
	/// Default value is `0.0`.
	public var tailIndent: CGFloat {
		set { paragraph.tailIndent = newValue }
        mutating get { paragraph.tailIndent }
	}
	
	/// The mode that should be used to break lines.
	///
	/// Default value is `byTruncatingTail`.
	public var lineBreakMode: LineBreak {
		set { paragraph.lineBreakMode = newValue }
        mutating get { paragraph.lineBreakMode }
	}
	
	/// The minimum height in points that any line in the receiver will occupy,
	/// regardless of the font size or size of any attached graphic.
	/// This value must be nonnegative.
	///
	/// The default value is 0.
	public var minimumLineHeight: CGFloat {
		set { paragraph.minimumLineHeight = newValue }
        mutating get { paragraph.minimumLineHeight }
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
		set { paragraph.maximumLineHeight = newValue }
        mutating get { paragraph.maximumLineHeight }
	}
	
	/// The initial writing direction used to determine the actual writing direction for text.
	/// The default value of this property is `natural`.
	///
	/// The Text system uses this value as a hint for calculating the actual direction for displaying Unicode characters.
	/// If you know the base writing direction of the text you are rendering, you can set the value of this property
	/// to the correct direction to help the text system.
	public var baseWritingDirection: NSWritingDirection {
		set { paragraph.baseWritingDirection = newValue }
        mutating get { paragraph.baseWritingDirection }
	}
	
	/// The natural line height of the receiver is multiplied by this factor (if positive)
	/// before being constrained by minimum and maximum line height.
	///
	/// The default value of this property is 0.
	public var lineHeightMultiple: CGFloat {
		set { paragraph.lineHeightMultiple = newValue }
        mutating get { paragraph.lineHeightMultiple }
	}
	
	/// The threshold controlling when hyphenation is attempted.
	public var hyphenationFactor: Float {
		set { paragraph.hyphenationFactor = newValue }
        mutating get { paragraph.hyphenationFactor }
	}
	
	/// Ligatures cause specific character combinations to be rendered using a single custom glyph that corresponds
	/// to those characters.
	/// 
	/// The default value for this attribute is `defaults`. (Value `all` is unsupported on iOS.)
	public var ligatures: Ligatures? {
		set {
			set(attribute: NSNumber.from(int: newValue?.rawValue), forKey: .ligature)
		}
        mutating get {
			guard let value: NSNumber = get(attributeForKey: .ligature) else { return nil }
			return Ligatures(rawValue: value.intValue)
		}
	}
	
	#if os(iOS) || os(tvOS) || os(macOS)

	/// The value of this attribute is an `NSShadow` object. The default value of this property is nil.
	public var shadow: NSShadow? {
		set { set(attribute: newValue, forKey: .shadow) }
        mutating get { get(attributeForKey: .shadow) }
	}

	#endif
	
	#if os(iOS) || os(tvOS) || os(watchOS)
	
	/// Enable spoken of all punctuation in the text.
	public var speaksPunctuation: Bool? {
        set { set(attribute: newValue, forKey: NSAttributedString.Key(NSAttributedString.Key.accessibilitySpeechPunctuation.rawValue)) }
        mutating get { get(attributeForKey: NSAttributedString.Key(NSAttributedString.Key.accessibilitySpeechPunctuation.rawValue)) }
	}
	
	/// The language to use when speaking a string (value is a BCP 47 language code string).
	public var speakingLanguage: String? {
        set { set(attribute: newValue, forKey: NSAttributedString.Key(NSAttributedString.Key.accessibilitySpeechLanguage.rawValue)) }
        mutating get { get(attributeForKey: NSAttributedString.Key(NSAttributedString.Key.accessibilitySpeechLanguage.rawValue)) }
	}
	
	/// Pitch to apply to spoken content. Value must be in range range 0.0 to 2.0.
	/// The value indicates whether the text should be specified spoken with a higher or lower pitch
	/// than is used for the default.
	/// Values between 0.0 and 1.0 result in a lower pitch and values between 1.0 and 2.0 result in a higher pitch.
	///
	/// The default value for this attribute is 1.0, which indicates a normal pitch.
	public var speakingPitch: Double? {
        set { set(attribute: newValue, forKey: NSAttributedString.Key(NSAttributedString.Key.accessibilitySpeechPitch.rawValue)) }
        mutating get { get(attributeForKey: NSAttributedString.Key(NSAttributedString.Key.accessibilitySpeechPitch.rawValue)) }
	}

	/// No overview available.
	/// Note: available only from iOS 11, tvOS 11 and watchOS 4.
	@available(iOS 11.0, tvOS 11.0, iOSApplicationExtension 11.0, watchOS 4, *)
	public var speakingPronunciation: String? {
        set { set(attribute: newValue, forKey: NSAttributedString.Key(NSAttributedString.Key.accessibilitySpeechIPANotation.rawValue)) }
        mutating get { get(attributeForKey: NSAttributedString.Key(NSAttributedString.Key.accessibilitySpeechIPANotation.rawValue)) }
	}
	
	/// Spoken text is queued behind, or interrupts, existing spoken content.
	/// When the value is true, this announcement is queued behind existing speech.
	/// When the value is false, the announcement interrupts the existing speech.
	///
	/// The default behavior is to interrupt existing speech.
	@available(iOS 11.0, tvOS 11.0, iOSApplicationExtension 11.0, watchOS 4, *)
	public var shouldQueueSpeechAnnouncement: Bool? {
		set {
            let key = NSAttributedString.Key(NSAttributedString.Key.accessibilitySpeechQueueAnnouncement.rawValue)
			guard let v = newValue else {
				innerAttributes.removeValue(forKey: key)
				return
			}
			set(attribute: NSNumber.init(value: v), forKey: key)
		}
        mutating get {
            let key = NSAttributedString.Key(NSAttributedString.Key.accessibilitySpeechQueueAnnouncement.rawValue)
			if let n: NSNumber = get(attributeForKey: key) {
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
            let key = NSAttributedString.Key(NSAttributedString.Key.accessibilityTextHeadingLevel.rawValue)
			guard let v = newValue else {
				innerAttributes.removeValue(forKey: key)
				return
			}
			set(attribute: v.rawValue, forKey: key)
		}
        mutating get {
            let key = NSAttributedString.Key(NSAttributedString.Key.accessibilityTextHeadingLevel.rawValue)
			if let n: Int = get(attributeForKey: key) {
				return HeadingLevel(rawValue: n)
			} else { return nil }
		}
	}
	
	#endif
	
	/// The value of this attribute is an NSURL object (preferred) or an NSString object.
	/// The default value of this property is nil, indicating no link.
	public var linkURL: URLRepresentable? {
		set { set(attribute: newValue, forKey: .link) }
        mutating get { get(attributeForKey: .link) }
	}
	
	#if os(OSX) || os(iOS) || os(tvOS)
	
	///  Configuration for the number case, also known as "figure style".
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.numberCase instead")
	public var numberCase: NumberCase? {
		set { fontStyle?.numberCase = newValue }
		get { fontStyle?.numberCase }
	}
	
	/// Configuration for number spacing, also known as "figure spacing".
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.numberSpacing instead")
	public var numberSpacing: NumberSpacing? {
		set { fontStyle?.numberSpacing = newValue }
		get { fontStyle?.numberSpacing }
	}
	
	/// Configuration for displyaing a fraction.
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.fractions instead")
	public var fractions: Fractions? {
		set { fontStyle?.fractions = newValue }
		get { fontStyle?.fractions }
	}
	
	/// Superscript (superior) glpyh variants are used, as in footnotes¹.
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.superscript instead")
	public var superscript: Bool? {
		set { fontStyle?.subscript = newValue }
		get { fontStyle?.superscript }
	}
	
	/// Subscript (inferior) glyph variants are used: vₑ.
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.subscript instead")
	public var `subscript`: Bool? {
		set { fontStyle?.subscript = newValue }
		get { fontStyle?.subscript }
	}

	/// Ordinal glyph variants are used, as in the common typesetting of 4th.
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.ordinals instead")
	public var ordinals: Bool? {
		set { fontStyle?.ordinals = newValue }
		get { fontStyle?.ordinals }
	}
	
	/// Scientific inferior glyph variants are used: H₂O
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.scientificInferiors instead")
	public var scientificInferiors: Bool? {
        set { fontStyle?.scientificInferiors = newValue }
		get { fontStyle?.scientificInferiors }
	}
	
	/// Configure small caps behavior.
	/// `fromUppercase` and `fromLowercase` can be combined: they are not mutually exclusive.
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.smallCaps instead")
	public var smallCaps: Set<SmallCaps> {
        set { fontStyle?.smallCaps = newValue }
		get { fontStyle?.smallCaps ?? Set() }
	}

	/// Different stylistic alternates available for customizing a font.
	///
	/// Typically, a font will support a small subset of these alternates, and
	/// what they mean in a particular font is up to the font's creator.
	///
	/// For example, in Apple's San Francisco font, turn on alternate set "six" to
	/// enable high-legibility alternates for ambiguous characters like: 0lI164.
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.stylisticAlternates instead")
	public var stylisticAlternates: StylisticAlternates {
        set { fontStyle?.stylisticAlternates = newValue }
		get { fontStyle?.stylisticAlternates ?? StylisticAlternates() }
	}
	
	/// Different contextual alternates available for customizing a font.
	/// Note: Not all fonts support all (or any) of these options.
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.contextualAlternates instead")
	public var contextualAlternates: ContextualAlternates {
        set { fontStyle?.contextualAlternates = newValue }
		get { fontStyle?.contextualAlternates ?? ContextualAlternates() }
	}
	
	/// Tracking to apply.
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.kerning instead")
	public var kerning: Kerning? {
        set { fontStyle?.kerning = newValue }
		get { fontStyle?.kerning }
	}
	
	/// Describe trait variants to apply to the font.
	/// **Note**: in order to be used you must also set the `.font`/`.size` attribute of the style.
    @available(*, deprecated, message: "Use fontStyle.traitVariants instead")
	public var traitVariants: TraitVariant? {
        set { fontStyle?.traitVariants = newValue }
		get { fontStyle?.traitVariants }
	}

	#endif

	//MARK: - INIT
	
	/// Initialize a new style with optional configuration handler callback.
	///
	/// - Parameter handler: configuration handler callback.
	public init(_ handler: StyleInitHandler? = nil) {
		handler?(&self)
	}
	
	/// Initialize a new style from a predefined set of attributes.
	/// Font related attributes are not set automatically but are encapsulasted to the font object itself.
	///
	/// - Parameter dictionary: dictionary to set
    /// - Parameters:
    ///   - dictionary: dictionary to set.
    ///   - textTransforms: tranforms to apply.
    public init(dictionary: [NSAttributedString.Key: Any]?, textTransforms newTextTransforms: [TextTransform]? = nil) {
		if let font = dictionary?[.font] as? Font {
			fontStyle?.font = font
			fontStyle?.size = font.pointSize
		}
		innerAttributes = (dictionary ?? [:])
        textTransforms = newTextTransforms
	}
	
	/// Initialize a new Style by cloning an existing style.
	///
	/// - Parameter style: style to clone
	public init(style: Style) {
		innerAttributes = style.innerAttributes
		fontStyle = style.fontStyle
	}
	
	//MARK: - PUBLIC METHODS
	
	/// Set a raw `NSAttributedStringKey`'s attribute value.
	///
	/// - Parameters:
	///   - value: valid value to set, `nil` to remove exiting value for given key.
	///   - key: key to set
	public mutating func set<T>(attribute value: T?, forKey key: NSAttributedString.Key) {
		guard let value = value else {
			innerAttributes.removeValue(forKey: key)
			return
		}
		innerAttributes[key] = value
	}
	
	/// Get the raw value for given `NSAttributedStringKey` key.
	///
	/// - Parameter key: key to read.
	/// - Returns: value or `nil` if value is not set.
    public mutating func get<T>(attributeForKey key: NSAttributedString.Key, builder: (() -> T?)? = nil) -> T? {
        guard let value = innerAttributes[key] as? T else {
            if let newValue = builder?() {
                set(attribute: newValue, forKey: key)
                return newValue
            }
            
            return nil
        }
        
        return value
	}
	
	/// Return attributes defined by the style.
	/// Not all attributes are returned, fonts attributes may be omitted.
	/// Refer to `attributes` to get the complete list.
	public var attributes: [NSAttributedString.Key : Any] {
		var fontAttributes = fontStyle?.attributes ?? [:]
        fontAttributes.merge(innerAttributes) { (_, new) in return new }
		return fontAttributes
	}
	
	/// Create a new style copy of `self` with the opportunity to configure it via configuration callback.
	///
	/// - Parameter handler: configuration handler.
	/// - Returns: configured style.
	public func byAdding(_ handler: StyleInitHandler) -> Style {
		var styleCopy = Style(style: self)
        handler(&styleCopy)
		return styleCopy
	}
    
    // MARK ---
    
    public func set(to source: String, range: NSRange?) -> AttributedString {
        let attributedText = NSMutableAttributedString(string: source)
        fontStyle?.addAttributes(to: attributedText, range: nil)
        attributedText.addAttributes(attributes, range: (range ?? NSMakeRange(0, attributedText.length)))
        return attributedText.applyTextTransform(textTransforms)
    }
    
    public func add(to source: AttributedString, range: NSRange?) -> AttributedString {
        fontStyle?.addAttributes(to: source, range: range)
        source.addAttributes(attributes, range: (range ?? NSMakeRange(0, source.length)))
        return source.applyTextTransform(textTransforms)
    }
    
    @discardableResult
    public func set(to source: AttributedString, range: NSRange?) -> AttributedString {
        fontStyle?.addAttributes(to: source, range: range)
        source.addAttributes(attributes, range: (range ?? NSMakeRange(0, source.length)))
        return source.applyTextTransform(textTransforms)
    }
    
    @discardableResult
    public func remove(from source: AttributedString, range: NSRange?) -> AttributedString {
        attributes.keys.forEach({
            source.removeAttribute($0, range: (range ?? NSMakeRange(0, source.length)))
        })
        return source.applyTextTransform(textTransforms)
    }
    
}
