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
import CoreGraphics

//MARK: - Typealiases

#if os(OSX)
	import AppKit

	public typealias Color = NSColor
	public typealias Image = NSImage
	public typealias Font = NSFont
	public typealias FontDescriptor = NSFontDescriptor
	public typealias SymbolicTraits = NSFontDescriptor.SymbolicTraits
	public typealias LineBreak = NSLineBreakMode

	let FontDescriptorFeatureSettingsAttribute = NSFontDescriptor.AttributeName.featureSettings
	let FontFeatureTypeIdentifierKey = NSFontDescriptor.FeatureKey.typeIdentifier
	let FontFeatureSelectorIdentifierKey = NSFontDescriptor.FeatureKey.selectorIdentifier

#else
	import UIKit

	public typealias Color = UIColor
	public typealias Image = UIImage
	public typealias Font = UIFont
	public typealias FontDescriptor = UIFontDescriptor
	public typealias SymbolicTraits = UIFontDescriptor.SymbolicTraits
	public typealias LineBreak = NSLineBreakMode

	let FontDescriptorFeatureSettingsAttribute = UIFontDescriptor.AttributeName.featureSettings
	let FontFeatureTypeIdentifierKey = UIFontDescriptor.FeatureKey.featureIdentifier
	let FontFeatureSelectorIdentifierKey = UIFontDescriptor.FeatureKey.typeIdentifier

#endif

//MARK: - Kerning

/// An enumeration representing the tracking to be applied.
///
/// - point: point value.
/// - adobe: adobe format point value.
public enum Kerning {
	case point(CGFloat)
	case adobe(CGFloat)
	
	public func kerning(for font: Font?) -> CGFloat {
		switch self {
		case .point(let kernValue):
			return kernValue
		case .adobe(let adobeTracking):
			let AdobeTrackingDivisor: CGFloat = 1000.0
			if font == nil {
				print("Missing font for apply tracking; 0 is the fallback.")
			}
			return (font?.pointSize ?? 0) * (adobeTracking / AdobeTrackingDivisor)
		}
	}
	
}

//MARK: - Ligatures

/// Ligatures cause specific character combinations to be rendered using a single custom glyph that corresponds
/// to those characters.
///
/// - disabled: use only required ligatures when setting text, for the glyphs in the selection
///				if the receiver is a rich text view, or for all glyphs if it’s a plain text view.
/// - defaults: use the standard ligatures available for the fonts and languages used when setting text,
///				for the glyphs in the selection if the receiver is a rich text view, or for all glyphs if it’s a plain text view.
/// - all: 		use all ligatures available for the fonts and languages used when setting text, for the glyphs
///				in the selection if the receiver is a rich text view, or for all glyphs if it’s a
///				plain text view (not supported on iOS).
public enum Ligatures: Int {
	case disabled = 0
	case defaults = 1
	#if os(OSX)
	case all = 2
	#endif
}

//MARK: - HeadingLevel

/// Specify the heading level of the text.
/// Value is a number in the range 0 to 6.
/// Use 0 to indicate the absence of a specific heading level and use other numbers to indicate the heading level.
///
/// - none: no heading
/// - one: level 1
/// - two: level 2
/// - three: level 3
/// - four: level 4
/// - five: level 5
/// - six: level 6
public enum HeadingLevel: Int {
	case none = 0
	case one = 1
	case two = 2
	case three = 3
	case four = 4
	case five = 5
	case six = 6
}

//MARK: - Trait Variants

/// Describe a trait variant for font
public struct TraitVariant: OptionSet {
	public var rawValue: Int
	
	/// The font typestyle is italic
	public static let italic = TraitVariant(rawValue: 1 << 0)
	
	/// The font typestyle is boldface
	public static let bold = TraitVariant(rawValue: 1 << 1)
	
	// The font typestyle is expanded. Expanded and condensed traits are mutually exclusive.
	public static let expanded = TraitVariant(rawValue: 1 << 2)
	
	/// The font typestyle is condensed. Expanded and condensed traits are mutually exclusive
	public static let condensed = TraitVariant(rawValue: 1 << 3)
	
	/// The font uses vertical glyph variants and metrics.
	public static let vertical = TraitVariant(rawValue: 1 << 4)
	
	/// The font synthesizes appropriate attributes for user interface rendering, such as control titles, if necessary.
	public static let uiOptimized = TraitVariant(rawValue: 1 << 5)
	
	/// The font use a tigher line spacing variant.
	public static let tightLineSpacing = TraitVariant(rawValue: 1 << 6)
	
	/// The font use a loose line spacing variant.
	public static let looseLineSpacing = TraitVariant(rawValue: 1 << 7)
	
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
}


extension TraitVariant {
	
	var symbolicTraits: SymbolicTraits {
		var traits: SymbolicTraits = []
		if contains(.italic) {
			traits.insert(SymbolicTraits.italic)
		}
		if contains(.bold) {
			traits.insert(.bold)
		}
		if contains(.expanded) {
			traits.insert(.expanded)
		}
		if contains(.condensed) {
			traits.insert(.condensed)
		}
		if contains(.vertical) {
			traits.insert(.vertical)
		}
		if contains(.uiOptimized) {
			traits.insert(.uiOptimized)
		}
		if contains(.tightLineSpacing) {
			traits.insert(.tightLineSpacing)
		}
		if contains(.looseLineSpacing) {
			traits.insert(.looseLineSpacing)
		}
		
		return traits
	}
	
}

//MARK: - Symbolic Traits (UIFontDescriptorSymbolicTraits) Extensions

extension SymbolicTraits {
	#if os(iOS) || os(tvOS) || os(watchOS)
	static var italic: SymbolicTraits {
		return .traitItalic
	}
	static var bold: SymbolicTraits {
		return .traitBold
	}
	static var expanded: SymbolicTraits {
		return .traitExpanded
	}
	static var condensed: SymbolicTraits {
		return .traitCondensed
	}
	static var vertical: SymbolicTraits {
		return .traitVertical
	}
	static var uiOptimized: SymbolicTraits {
		return .traitUIOptimized
	}
	static var tightLineSpacing: SymbolicTraits {
		return .traitTightLeading
	}
	static var looseLineSpacing: SymbolicTraits {
		return .traitLooseLeading
	}
	#else
	static var uiOptimized: SymbolicTraits {
		return .UIOptimized
	}
	static var tightLineSpacing: SymbolicTraits {
		return .tightLeading
	}
	static var looseLineSpacing: SymbolicTraits {
		return .looseLeading
	}
	#endif
}
