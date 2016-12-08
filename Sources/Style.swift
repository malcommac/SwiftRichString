//
//  Style.swift
//  SwiftStyler
//
//  Created by Daniele Margutti on 07/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import Foundation

//MARK: StyleType

/// StyleType define the type of a style
///
/// - `default`: this is the default style. If added to a MarkupString, default style is applied automatically to the entire string
///              before any other defined style is added to given text ranges.
/// - named: custom style with given name
public enum StyleName {
	case `default`
	case named(String)
	
	public var value: String {
		switch self {
		case .default:
			return "#default"
		case .named(let name):
			return name
		}
	}
}

//MARK: Style

public func == (lhs: Style, rhs: Style) -> Bool {
	return lhs.name.value == rhs.name.value
}

public class Style: Equatable {
	
	/// Identifier of style
	public var name: StyleName
	
	/// Cache of attributes dictionary
	public fileprivate(set) var attributes: [String:Any] = [NSParagraphStyleAttributeName : NSMutableParagraphStyle()]
	
	/// Initialize a new style with given type
	///
	/// - Parameters:
	///   - type: type of style
	///   - maker: a closure which allows you to contextually define styles to apply. Use $0.<text_property> to define each property you
	///            want to apply to style.
	private init(_ name: StyleName, _ maker: (_ maker: Style) -> (Void) ) {
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
	///			$0.color = UIColor.green
	///		})
	public init(_ name: String, _ maker: (_ maker: Style) -> (Void) ) {
		self.name = .named(name)
		maker(self)
	}
	
	/// Create a new default attribute. Default attribute is applied to the string in first place.
	/// Any other attribute will be added to this default attribute if present.
	/// If you don't define a default attribute only other styles may change the attribute of your attributed string.
	///
	///   - maker: a closure which allows you to contextually define styles to apply. Use $0.<text_property> to define each property you
	///            want to apply to style.
	/// - Returns: a new Style instance
	public static func `default`(_ maker: (_ maker: Style) -> (Void) ) -> Style {
		return Style(.default, maker)
	}
	
	/// Set or remove from cached attributes dict value for a specified key
	///
	/// - Parameters:
	///   - key: key to assign
	///   - value: value to assign (nil to remove key from cached dictionay, valid value to set)
	private func set(key: String, value: Any?) {
		guard let setValue = value else {
			attributes.removeValue(forKey: key)
			return
		}
		attributes[key] = setValue
	}
	
	private func remove(key: String) {
		attributes.removeValue(forKey: key)
	}
	
	/// Private cached ParagraphStyle instance
	private var paragraph: NSMutableParagraphStyle {
		get {
			return attributes[NSParagraphStyleAttributeName] as! NSMutableParagraphStyle
		}
	}
	
	/// The text alignment of the receiver.
	/// Natural text alignment is realized as left or right alignment depending on the line sweep direction of the first script contained in the paragraph.
	public var align: NSTextAlignment {
		set { self.paragraph.alignment = newValue }
		get { return self.paragraph.alignment }
	}
	
	
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
	
	/// The mode that should be used to break lines in the receiver.
	/// This property contains the line break mode to be used laying out the paragraph’s text.
	public var lineBreak: NSLineBreakMode {
		set { self.paragraph.lineBreakMode = newValue }
		get { return self.paragraph.lineBreakMode }
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
	
	/// The space after the end of the paragraph.
	/// This property contains the space (measured in points) added at the end of the paragraph to separate it from the following paragraph.
	/// This value is always nonnegative. The space between paragraphs is determined by adding the previous paragraph’s paragraphSpacing
	/// and the current paragraph’s paragraphSpacingBefore.
	public var paragraphSpacing: Float {
		set { self.paragraph.paragraphSpacing = CGFloat(newValue) }
		get { return Float(self.paragraph.paragraphSpacing) }
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
	
	/// Font to apply.
	/// This is the define as FontAttribute which allows to define typesafe font by it's name.
	/// Custom fonts created by name are also available.
	/// You can however extended FontAttribute to add your own custom font and make them type safe as they should be.
	public var font: FontAttribute? {
		set { self.set(key: NSFontAttributeName, value: newValue?.font) }
		get { return FontAttribute(font: attributes[NSFontAttributeName] as? UIFont ) }
	}
	
	/// The value of this attribute is a UIColor object. Use this attribute to specify the color of the text during rendering.
	// If you do not specify this attribute, the text is rendered in black.
	public var color: UIColor? {
		didSet { self.set(key: NSForegroundColorAttributeName, value: self.color) }
	}
	
	/// The value of this attribute is a UIColor object. Use this attribute to specify the color of the background area behind the text.
	/// If you do not specify this attribute, no background color is drawn.
	public var backColor: UIColor? {
		didSet { self.set(key: NSBackgroundColorAttributeName, value: self.backColor) }
	}
	
	
	/// Ligatures cause specific character combinations to be rendered using a single custom glyph that corresponds to those characters.
	/// The value 0 indicates no ligatures. The value 1 indicates the use of the default ligatures.
	/// The value 2 indicates the use of all ligatures. The default value for this attribute is 1. (Value 2 is unsupported on iOS.)
	public var ligature: Int? {
		didSet { self.set(key: NSLigatureAttributeName, value: self.ligature) }
	}
	
	/// This value specifies the number of points by which to adjust kern-pair characters.
	/// Kerning prevents unwanted space from occurring between specific characters and depends on the font.
	/// The value 0 means kerning is disabled. The default value for this attribute is 0.
	public var kern: Float? {
		didSet { self.set(key: NSKernAttributeName, value: self.kern) }
	}

	/// This value indicates whether the text has a line through it and corresponds to one of the constants described in NSUnderlineStyle.
	/// The default value for this attribute is styleNone.
	public var strike: NSUnderlineStyle? {
		didSet { self.set(key: NSStrikethroughStyleAttributeName, value: self.strike) }
	}
	
	/// The value of this attribute is a UIColor object. The default value is nil, indicating same as foreground color.
	public var strikeColor: UIColor? {
		didSet { self.set(key: NSStrikethroughColorAttributeName, value: self.strikeColor) }
	}
	
	/// Define the underline attributes of the text
	public var underline: UnderlineAttribute? {
		set {
			guard let underline = newValue else {
				self.remove(key: NSUnderlineStyleAttributeName)
				self.remove(key: NSUnderlineColorAttributeName)
				return
			}
			self.set(key: NSUnderlineStyleAttributeName, value: underline.style?.rawValue)
			self.set(key: NSUnderlineColorAttributeName, value: underline.color)
		}
		get {
			return UnderlineAttribute(color: attributes[NSUnderlineColorAttributeName] as? UIColor,
			                          style: attributes[NSUnderlineStyleAttributeName] as? NSUnderlineStyle)
		}
	}
	
	/// Define stroke attributes
	public var stroke: StrokeAttribute? {
		set {
			guard let stroke = newValue else {
				self.remove(key: NSStrokeColorAttributeName)
				self.remove(key: NSStrokeWidthAttributeName)
				return
			}
			self.set(key: NSStrokeWidthAttributeName, value: stroke.width)
			self.set(key: NSStrokeColorAttributeName, value: stroke.color)
		}
		get {
			return StrokeAttribute(color: attributes[NSStrokeColorAttributeName] as? UIColor,
			                       width: attributes[NSStrokeWidthAttributeName] as? CGFloat)
		}
	}
	
	/// The value of this attribute is an NSShadow object. The default value of this property is nil.
	#if os(iOS) || os(macOS)
	public var shadow: ShadowAttribute? {
		set { self.set(key: NSShadowAttributeName, value: newValue?.shadowObj) }
		get { return ShadowAttribute(shadow: attributes[NSShadowAttributeName] as? NSShadow) }
	}
	#endif
	
	/// The value of this attribute is an NSString object. Use this attribute to specify a text effect, such as NSTextEffectLetterpressStyle.
	/// The default value of this property is nil, indicating no text effect.
	public var textEffect: String? {
		didSet { self.set(key: NSTextEffectAttributeName, value: self.textEffect) }
	}
	
	/// The value of this attribute is an NSTextAttachment object. The default value of this property is nil, indicating no attachment.
	#if os(iOS) || os(macOS)
	public var attach: NSTextAttachment? {
		didSet { self.set(key: NSAttachmentAttributeName, value: self.attach) }
	}
	#endif
	
	/// The value of this attribute is an NSURL object (preferred) or an NSString object. The default value of this property is nil, indicating no link.
	public var linkURL: URL? {
		didSet { self.set(key: NSLinkAttributeName, value: self.linkURL) }
	}
	
	/// Floating point value indicating the character’s offset from the baseline, in points. The default value is 0.
	public var baselineOffset: Float? {
		didSet { self.set(key: NSBaselineOffsetAttributeName, value: self.baselineOffset) }
	}
	
	/// Floating point value indicating skew to be applied to glyphs. The default value is 0, indicating no skew.
	public var oblique: Float? {
		didSet { self.set(key: NSObliquenessAttributeName, value: self.oblique) }
	}
	
	/// Floating point value indicating the log of the expansion factor to be applied to glyphs. The default value is 0, indicating no expansion.
	public var expansion: Float? {
		didSet { self.set(key: NSExpansionAttributeName, value: self.expansion) }
	}

	/// The value of this attribute is an NSArray object containing NSNumber objects representing the nested levels of writing direction overrides, 
	/// in order from outermost to innermost.
	public var direction: NSWritingDirection? {
		didSet { self.set(key: NSWritingDirectionAttributeName, value: self.direction) }
	}
	
	/// The value 0 indicates horizontal text. The value 1 indicates vertical text. In iOS, horizontal text is always used and specifying
	/// a different value is undefined.
	public var glyphForm: Int? {
		didSet { self.set(key: NSVerticalGlyphFormAttributeName, value: self.glyphForm) }
	}
	
}

//MARK: ShadowAttribute

public struct ShadowAttribute {
	
	/// The offset values of the shadow.
	/// This property contains the horizontal and vertical offset values, specified using the width and height fields of the CGSize data type.
	// These offsets are measured using the default user coordinate space and are not affected by custom transformations.
	/// This means that positive values always extend down and to the right from the user's perspective.
	public var offset: CGSize {
		set { self.shadow.shadowOffset = newValue }
		get { return self.shadow.shadowOffset }
	}
	
	/// The blur radius of the shadow.
	/// This property contains the blur radius, as measured in the default user coordinate space.
	/// A value of 0 indicates no blur, while larger values produce correspondingly larger blurring.
	/// This value must not be negative. The default value is 0.
	public var blurRadius: CGFloat {
		set { self.shadow.shadowBlurRadius = newValue }
		get { return self.shadow.shadowBlurRadius }
	}
	
	/// The color of the shadow.
	/// The default shadow color is black with an alpha of 1/3. If you set this property to nil, the shadow is not drawn.
	/// The color you specify must be convertible to an RGBA color and may contain alpha information.
	public var color: UIColor? {
		set { self.shadow.shadowColor = newValue }
		get { return self.shadow.shadowColor as? UIColor }
	}
	
	/// Private cached object
	private var shadow: NSShadow = NSShadow()
	
	/// Create a new shadow
	///
	/// - Parameters:
	///   - color: color of the shadow
	///   - radius: radius of the shadow
	///   - offset: offset of the shadow
	public init(color: UIColor, radius: CGFloat? = nil, offset: CGSize? = nil) {
		self.color = color
		self.blurRadius = radius ?? 0.0
		self.offset = offset ?? CGSize.zero
	}
	
	/// Init from NSShadow object
	///
	/// - Parameter shadow: shadow object
	public init?(shadow: NSShadow?) {
		guard let shadow = shadow else { return nil }
		self.shadow = shadow
	}
	
	/// Return represented NSShadow object
	public var shadowObj: NSShadow {
		return self.shadow
	}
}

//MARK: StrokeAttribute

public struct StrokeAttribute {
	
	/// If it is not defined (which is the case by default), 
	// it is assumed to be the same as the value of color; otherwise, it describes the outline color.
	public let color: UIColor?
	
	/// This value represents the amount to change the stroke width and is specified as a percentage
	/// of the font point size. Specify 0 (the default) for no additional changes. Specify positive values to change the 
	/// stroke width alone. Specify negative values to stroke and fill the text. For example, a typical value for 
	/// outlined text would be 3.0.
	public let width: CGFloat?
	
	public init(color: UIColor?, width: CGFloat?) {
		self.color = color
		self.width = width
	}

}

//MARK: UnderlineAttribute

public struct UnderlineAttribute {
	/// The value of this attribute is a UIColor object. The default value is nil, indicating same as foreground color.
	public let color: UIColor?
	
	/// This value indicates whether the text is underlined and corresponds to one of the constants described in NSUnderlineStyle.
	/// The default value for this attribute is styleNone.
	public let style: NSUnderlineStyle?
	
	public init(color: UIColor?, style: NSUnderlineStyle?) {
		self.color = color
		self.style = style
	}

}

//MARK: FontAttribute

/// FontAttribute define a safe type font
public struct FontAttribute {
	
	/// This define a type safe font name
	public var name: FontName

	/// Size of the font
	public var size: Float
	
	/// Create a new FontAttribute with given name and size
	///
	/// - Parameters:
	///   - name: name of the font (may be type safe or custom). You can extend the FontAttribute enum in order to include your own typesafe names
	///   - size: size of the font
	public init(_ name: FontName, size: Float) {
		self.name = name
		self.size = size
	}
	
	/// Create a new FontAttribute name with given font name and size
	/// - return: may return nil if name is not part of font's collection
	public init?(_ name: String, size: Float) {
		guard let name = FontName(rawValue: name) else {
			return nil
		}
		self.name = name
		self.size = size
	}
	
	/// Create a new FontAttribute from given UIFont instance
	/// - return: may return nil if font is not passed or not valid
	public init?(font: UIFont?) {
		guard let font = font else {
			return nil
		}
		let rawName = (font.fontName as NSString).replacingOccurrences(of: "_", with: "-")
		guard let fontName = FontName.fromFontName(rawName) else {
			return nil
		}
		self.name = fontName
		self.size = Float(font.pointSize)
	}
	
	/// Get the cached UIFont instance
	public var font: UIFont {
		let font = UIFont(name: self.name.rawValue, size: CGFloat(size))!
		return font
	}
}
