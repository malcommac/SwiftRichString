//
//  String+RichExtensions.swift
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

// MARK: - Conversion to `RichString` methods
extension String {
	
	/// Apply given style to the string to produce an attribute string.
	///
	/// - Parameter style: style to apply.
	/// - Returns: attributed string.
	public func set<T: StyleProtocol>(_ style: T) -> RichString {
		return style.render(self)
	}

	/// Apply ordered list of styles and produce a new `RichString`.
	/// NOTE: 	First found `default` style is used as initial style regardeless
	/// 		the order you have added it to the array.
	///			Any other existing attributed is replaced by the list of attributes passed.
	///
	/// - Parameter styles: styles to apply.
	/// - Returns: attributed string.
	public func set<T: StyleProtocol>(_ styles: [T]) -> RichString {
		return self.set(styles.mergedStyle())
	}
	
	/// Same of `set()` with array of `StyleProtocol` elements.
	///
	/// - Parameter styles: styles to apply.
	/// - Returns: attributed string.
	public func set<T: Sequence>(_ styles: T) -> RichString {
		return self.set(Array(styles))
	}

	/// Apply configuration passed via callback to the receiver and produce an attributed string.
	///
	/// - Parameter callback: callback used to produce a new set of attributes.
	/// - Returns: attributed string
	public func set(_ callback: ((Style) -> (Void))) -> RichString {
		return self.set(Style(callback))
	}
	
}

// MARK: - In place conversion with attribute set
public extension String {
	
	/// Generate a `RichString` with the initial attributes of the global style and specified bold trait if available.
	/// NOTE: Font maybe not bold if family does not support this trait.
	///
	/// - Returns: attributed string
	public func bold() -> RichString {
		return self.set({
			$0.fontTraits = FontTraits.merge($0.fontTraits, .traitBold)
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified italic trait if available.
	/// NOTE: Font maybe not italic if family does not support this trait.
	///
	/// - Returns: attributed string
	public func italic() -> RichString {
		return self.set({
			$0.fontTraits = FontTraits.merge($0.fontTraits, .traitItalic)
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified monospaced trait if available.
	/// NOTE: Font maybe not monospace if family does not support this trait.
	///
	/// - Returns: attributed string
	public func monospaced() -> RichString {
		return self.set({
			$0.fontTraits = FontTraits.merge($0.fontTraits, .traitMonoSpace)
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified condensed trait if available.
	/// NOTE: Font maybe not condensed if family does not support this trait.
	///
	/// - Returns: attributed string
	public func condensed() -> RichString {
		return self.set({
			$0.fontTraits = FontTraits.merge($0.fontTraits, .traitCondensed)
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified expanded trait if available.
	/// NOTE: Font maybe not expanded if family does not support this trait.
	///
	/// - Returns: attributed string
	public func expanded() -> RichString {
		return self.set({
			$0.fontTraits = FontTraits.merge($0.fontTraits, .traitExpanded)
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified font.
	///
	/// - Parameter font: font to set.
	/// - Returns: attributed string
	public func font(_ font: FontConvertible) -> RichString {
		return self.set(Style.id {
			$0.font = font
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified font size.
	///
	/// - Parameter font: font size to set (global font is used).
	/// - Returns: attributed string
	public func fontSize(_ size: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.fontSize = size
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified text color.
	///
	/// - Parameter color: color to set.
	/// - Returns: attributed string.
	public func color(_ color: ColorConvertible) -> RichString {
		return self.set(Style.id {
			$0.color = color
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified back color.
	///
	/// - Parameter color: background color to set.
	/// - Returns: attributed string.
	public func backColor(_ color: ColorConvertible) -> RichString {
		return self.set(Style.id {
			$0.backColor = color
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified ligature value.
	///
	/// - Parameter ligature: ligature to set.
	/// - Returns: attributed string
	public func ligature(_ ligature: Ligature) -> RichString {
		return self.set(Style.id {
			$0.ligature = ligature
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified kerning value.
	///
	/// - Parameter kern: kerning value to set.
	/// - Returns: attributed string
	public func kern(_ kern: Kern) -> RichString {
		return self.set(Style.id {
			$0.kern = kern
		})
	}

	/// Generate a `RichString` with the initial attributes of the global style and specified
	/// strikethought with given style and color.
	///
	/// - Parameters:
	///   - style: style to apply.
	///   - color: color of the underline.
	/// - Returns: attributed string
	public func strikethrough(style: NSUnderlineStyle, color: ColorConvertible? = nil) -> RichString {
		return self.set(Style.id {
			$0.strikeThrough = style
			$0.strikeThroughColor = color
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified
	/// underline with given style and color.
	///
	/// - Parameters:
	///   - style: style to apply.
	///   - color: color of the underline.
	/// - Returns: attributed string
	public func underline(style: NSUnderlineStyle, color: ColorConvertible? = nil) -> RichString {
		return self.set(Style.id {
			$0.underline = style
			$0.underlineColor = color
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified
	/// stroke with given width and color.
	///
	/// - Parameters:
	///   - width: width of the stroke.
	///   - color: color of the stroke.
	/// - Returns: attributed string
	public func stroke(width: CGFloat, color: ColorConvertible?) -> RichString {
		return self.set(Style.id {
			$0.strokeWidth = width
			$0.strokeColor = color
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified text alignment.
	///
	/// - Parameter alignment: alignment
	/// - Returns: attributed string
	public func alignment(_ alignment: NSTextAlignment) -> RichString {
		return self.set(Style.id {
			$0.alignment = alignment
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified link.
	///
	/// - Parameter url: link to set.
	/// - Returns: attributed string
	public func link(_ url: URL?) -> RichString {
		return self.set(Style.id {
			$0.link = url
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified baseline offset.
	///
	/// - Parameter offset: offset of the baseline.
	/// - Returns: attributed string
	public func baselineOffset(_ offset: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.baselineOffset = offset
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified expansion.
	///
	/// - Parameter factor: Expansion factor to be applied to glyphs
	/// - Returns: attributed string.
	public func expansionFactor(_ factor: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.expansionFactor = factor
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified obliquenes.
	///
	/// - Parameter skew: Floating point value indicating skew to be applied to glyphs.
	/// - Returns: attributed string.
	public func obliqueness(skew: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.obliqueness = skew
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified shadow.
	///
	/// - Parameter shadow: `NSShadow` object and allows to set a specific shadow applied to the text.
	/// - Returns: attributed string.
	public func shadow(_ shadow: NSShadow) -> RichString {
		return self.set(Style.id {
			$0.shadow = shadow
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified text effect.
	///
	/// - Parameter effect: effect of the text.
	/// - Returns: attributed string.
	public func textEffect(_ effect: RichString.TextEffectStyle) -> RichString {
		return self.set(Style.id {
			$0.textEffect = effect
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified writing direction order.
	///
	/// - Parameter direction: The value of this attribute is an array of `WritingDirection` objects
	/// representing the nested levels of writing direction overrides, in order from outermost to innermost.
	/// - Returns: attributed string
	public func writingDirection(_ direction: [WritingDirection]) -> RichString {
		return self.set(Style.id {
			$0.writingDirection = direction
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified paragraph attributes.
	///
	/// - Parameter paragraph: paragraph attributes to set (replace all other sub attributes of the paragraph).
	/// - Returns: attributed string
	public func paragraph(_ paragraph: NSMutableParagraphStyle) -> RichString {
		return self.set(Style.id {
			$0.paragraph = paragraph
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified paragraph
	/// attributes you can configure inside the callback.
	///
	/// - Parameter configure: callback used to configure paragraph.
	/// - Returns: attributed string
	public func paragraph(_ configure: ((NSMutableParagraphStyle) -> (Void))) -> RichString {
		let paragraph = NSMutableParagraphStyle()
		configure(paragraph)
		return self.set(Style.id {
			$0.paragraph = paragraph
		})
	}

	/// Generate a `RichString` with the initial attributes of the global style and specified line break mode.
	///
	/// - Parameter lineBreak: line break mode.
	public func lineBreak(_ lineBreak: NSLineBreakMode) -> RichString {
		return self.set(Style.id {
			$0.lineBreak = lineBreak
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified paragraph spacing.
	///
	/// - Parameter spacing: paragraph spacing.
	public func paragraphSpacing(_ spacing: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.paragraphSpacing = spacing
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified paragraph spacing before.
	///
	/// - Parameter spacing: The distance between the paragraph’s top and the beginning of its text content
	public func paragraphSpacingBefore(_ spacing: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.paragraphSpacingBefore = spacing
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified line head indent.
	///
	/// - Parameter spacing: The distance (in points) from the leading margin of a text container to
	/// 					 the beginning of the paragraph’s first line.
	public func firstLineHeadIndent(_ indent: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.firstLineHeadIndent = indent
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified head indent.
	///
	/// - Parameter indent: The distance (in points) from the leading margin of a text container to the beginning
	/// 					of lines other than the first.
	public func headIndent(_ indent: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.headIndent = indent
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified tail indent.
	///
	/// - Parameter indent: tail indent
	public func tailIndent(_ indent: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.tailIndent = indent
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified max line height
	///
	/// - Parameter height: The maximum height in points that any line in the receiver will occupy,
	/// 					regardless of the font size or size of any attached graphic.
	public func maximumLineHeight(_ height: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.maximumLineHeight = height
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified min line height
	///
	/// - Parameter height: The minimum height in points that any line in the receiver will occupy,
	/// 					regardless of the font size or size of any attached graphic.
	public func minimumLineHeight(_ height: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.minimumLineHeight = height
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified line spacing.
	///
	/// - Parameter indent: The distance in points between the bottom of one line fragment and the top of the next.
	/// 					This value is always nonnegative.
	public func lineSpacing(_ spacing: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.lineSpacing = spacing
		})
	}
	
	/// Generate a `RichString` with the initial attributes of the global style and specified line height multiple.
	///
	/// - Parameter height: The natural line height of the receiver is multiplied by this factor (if positive)
	/// 					before being constrained by minimum and maximum line height.
	public func lineHeightMultiple(_ height: CGFloat) -> RichString {
		return self.set(Style.id {
			$0.lineHeightMultiple = height
		})
	}
}
