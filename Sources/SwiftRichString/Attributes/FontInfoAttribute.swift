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

// Portions of this file is taken from BonMot project.

import Foundation

// This is not supported on watchOS
#if os(iOS) || os(tvOS) || os(OSX)

import CoreText

/// Protocol to provide values to be used by `UIFontFeatureTypeIdentifierKey`
/// and `UIFontFeatureSelectorIdentifierKey`. You can typically find these
/// values in CoreText.SFNTLayoutTypes.
public protocol FontInfoAttribute {
	func featureSettings() -> [(type: Int, selector: Int)]
}

public extension FontInfoAttribute {
	
	func attributes() -> [[FontDescriptor.FeatureKey: Any]] {
		let featureSettings = self.featureSettings()
		return featureSettings.map {
			return [
				FontFeatureTypeIdentifierKey: $0.type,
				FontFeatureSelectorIdentifierKey: $0.selector,
			]
		}
	}
	
}


// MARK: - UIFont/NSFont with FontInfoAttribute

internal extension Font {
	
	/// Instance a new font instance with passed attributes.
	///
	/// - Parameter attributes: font info attributes
	/// - Returns: a valid instance of the font with specified attributes.
	func withAttributes(_ attributes: [FontInfoAttribute]) -> Font {
		let newFeatures = attributes.flatMap { $0.attributes() }
		guard newFeatures.count > 0 else {
			return self
		}
		
		var fontAttributes = fontDescriptor.fontAttributes
		var features = fontAttributes[FontDescriptorFeatureSettingsAttribute] as? [[FontDescriptor.FeatureKey: Any]] ?? []
		
		features.append(contentsOf: newFeatures)
		fontAttributes[FontDescriptorFeatureSettingsAttribute] = features
		
		let descriptor = FontDescriptor(fontAttributes: fontAttributes)
		#if os(OSX)
			return Font(descriptor: descriptor, size: pointSize)!
		#else
			return Font(descriptor: descriptor, size: pointSize)
		#endif
	}
	
}

//MARK: - NumberCase

/// A feature provider for changing the number case, also known as "figure style".
///
/// - upper: 	Uppercase numbers, also known as "lining figures", are the same height
///				as uppercase letters, and they do not extend below the baseline.
/// - lower:	Lowercase numbers, also known as "oldstyle figures", are similar in
///				size and visual weight to lowercase letters, allowing them to
///				blend in better in a block of text.
///				They may have descenders hich drop below the typographic baseline.
public enum NumberCase: FontInfoAttribute {
	case upper
	case lower
	
	public func featureSettings() -> [(type: Int, selector: Int)] {
		switch self {
		case .upper:	return [(type: kNumberCaseType, selector: kUpperCaseNumbersSelector)]
		case .lower:	return [(type: kNumberCaseType, selector: kLowerCaseNumbersSelector)]
		}
	}
}

//MARK: - NumberSpacing

/// Number spacing, also known as "figure spacing".
///
/// - monospaced:	Monospaced numbers, also known as "tabular figures", each take up
///					the same amount of horizontal space, meaning that different numbers
///					will line up when arranged in columns.
/// - proportional:	Proportionally spaced numbers, also known as "proprotional figures",
///					are of variable width.
///					This makes them look better in most cases, but they should be avoided
///					when numbers need to line up in columns.
public enum NumberSpacing: FontInfoAttribute {
	case monospaced
	case proportional
	
	public func featureSettings() -> [(type: Int, selector: Int)] {
		switch self {
		case .monospaced:		return [(type: kNumberSpacingType, selector: kMonospacedNumbersSelector)]
		case .proportional:		return [(type: kNumberSpacingType, selector: kProportionalNumbersSelector)]
		}
	}
}

//MARK: - VerticalPosition

/// Vertical position of the text.
///
/// - normal: 				No vertical position adjustment is applied.
/// - superscript: 			Superscript (superior) glpyh variants are used, as in footnotes¹.
/// - `subscript`: 			Subscript (inferior) glyph variants are used: vₑ.
/// - ordinals: 			Ordinal glyph variants are used, as in the common typesetting of 4th.
/// - scientificInferiors: 	Scientific inferior glyph variants are used: H₂O
internal enum VerticalPosition: FontInfoAttribute {
	case normal
	case superscript
	case `subscript`
	case ordinals
	case scientificInferiors
	
	func featureSettings() -> [(type: Int, selector: Int)] {
		let selector: Int
		switch self {
		case .normal: 				selector = kNormalPositionSelector
		case .superscript: 			selector = kSuperiorsSelector
		case .`subscript`: 			selector = kInferiorsSelector
		case .ordinals: 			selector = kOrdinalsSelector
		case .scientificInferiors: 	selector = kScientificInferiorsSelector
		}
		return [(type: kVerticalPositionType, selector: selector)]
	}
	
}

//MARK: - Fractions

/// Configuration for displaying a fraction.
///
/// - disabled: No fraction formatting.
/// - diagonal: Diagonal Fractions, when written on paper, are written on one line
///				with the numerator diagonally above and to the left of the
///				demoninator, with the slash ("/") between them.
/// - vertical:	Vertical Fractions, when written on paper, are written on one line
///				with the numerator directly above the demoninator, with a line lying horizontally between them.
public enum Fractions: FontInfoAttribute {
	case disabled
	case diagonal
	case vertical
	
	public func featureSettings() -> [(type: Int, selector: Int)] {
		switch self {
		case .disabled:		return [(type: kFractionsType, selector: kNoFractionsSelector)]
		case .diagonal:		return [(type: kFractionsType, selector: kDiagonalFractionsSelector)]
		case .vertical:		return [(type: kFractionsType, selector: kVerticalFractionsSelector)]
		}
	}
}

//MARK: - SmallCaps

/// Configure small caps behavior.
/// Note: `fromUppercase` and `fromLowercase` can be combined: they are not
/// mutually exclusive.
///
/// - disabled: 		No small caps are used.
/// - fromUppercase: 	Uppercase letters in the source string are replaced with small caps.
///						Lowercase letters remain unmodified.
/// - fromLowercase: 	Lowercase letters in the source string are replaced with small caps.
///						Uppercase letters remain unmodified.
public enum SmallCaps: FontInfoAttribute {
	case disabled
	case fromUppercase
	case fromLowercase
	
	public func featureSettings() -> [(type: Int, selector: Int)] {
		switch self {
		case .disabled:
			return [
				(type: kLowerCaseType, selector: kDefaultLowerCaseSelector),
				(type: kUpperCaseType, selector: kDefaultUpperCaseSelector),
			]
		case .fromUppercase:
			return [(type: kUpperCaseType, selector: kUpperCaseSmallCapsSelector)]
		case .fromLowercase:
			return [(type: kLowerCaseType, selector: kLowerCaseSmallCapsSelector)]
		}
	}
	
}

//MARK: - StylisticAlternates

/// Different stylistic alternates available for customizing a font.
/// Typically, a font will support a small subset of these alternates, and
/// what they mean in a particular font is up to the font's creator. For
/// example, in Apple's San Francisco font, turn on alternate set "six" to
/// enable high-legibility alternates for ambiguous characters like: 0lI164.
public struct StylisticAlternates {
	var one: Bool?
	var two: Bool?
	var three: Bool?
	var four: Bool?
	var five: Bool?
	var six: Bool?
	var seven: Bool?
	var eight: Bool?
	var nine: Bool?
	var ten: Bool?
	var eleven: Bool?
	var twelve: Bool?
	var thirteen: Bool?
	var fourteen: Bool?
	var fifteen: Bool?
	var sixteen: Bool?
	var seventeen: Bool?
	var eighteen: Bool?
	var nineteen: Bool?
	var twenty: Bool?
	
	public init() { }
}

// Convenience constructors
extension StylisticAlternates {
	
	public static func one(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.one = isOn
		return alts
	}
	
	public static func two(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.two = isOn
		return alts
	}
	
	public static func three(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.three = isOn
		return alts
	}
	
	public static func four(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.four = isOn
		return alts
	}
	
	public static func five(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.five = isOn
		return alts
	}
	
	public static func six(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.six = isOn
		return alts
	}
	
	public static func seven(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.seven = isOn
		return alts
	}
	
	public static func eight(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.eight = isOn
		return alts
	}
	
	public static func nine(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.nine = isOn
		return alts
	}
	
	public static func ten(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.ten = isOn
		return alts
	}
	
	public static func eleven(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.eleven = isOn
		return alts
	}
	
	public static func twelve(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.twelve = isOn
		return alts
	}
	
	public static func thirteen(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.thirteen = isOn
		return alts
	}
	
	public static func fourteen(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.fourteen = isOn
		return alts
	}
	
	public static func fifteen(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.fifteen = isOn
		return alts
	}
	
	public static func sixteen(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.sixteen = isOn
		return alts
	}
	
	public static func seventeen(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.seventeen = isOn
		return alts
	}
	
	public static func eighteen(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.eighteen = isOn
		return alts
	}
	
	public static func nineteen(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.nineteen = isOn
		return alts
	}
	
	public static func twenty(on isOn: Bool) -> StylisticAlternates {
		var alts = StylisticAlternates()
		alts.twenty = isOn
		return alts
	}
	
}

extension StylisticAlternates {
	
	mutating public func add(other theOther: StylisticAlternates) {
		// swiftlint:disable operator_usage_whitespace
		one       = theOther.one       ?? one
		two       = theOther.two       ?? two
		three     = theOther.three     ?? three
		four      = theOther.four      ?? four
		five      = theOther.five      ?? five
		six       = theOther.six       ?? six
		seven     = theOther.seven     ?? seven
		eight     = theOther.eight     ?? eight
		nine      = theOther.nine      ?? nine
		ten       = theOther.ten       ?? ten
		eleven    = theOther.eleven    ?? eleven
		twelve    = theOther.twelve    ?? twelve
		thirteen  = theOther.thirteen  ?? thirteen
		fourteen  = theOther.fourteen  ?? fourteen
		fifteen   = theOther.fifteen   ?? fifteen
		sixteen   = theOther.sixteen   ?? sixteen
		seventeen = theOther.seventeen ?? seventeen
		eighteen  = theOther.eighteen  ?? eighteen
		nineteen  = theOther.nineteen  ?? nineteen
		twenty    = theOther.twenty    ?? twenty
		// swiftlint:enable operator_usage_whitespace
	}
	
	public func byAdding(other theOther: StylisticAlternates) -> StylisticAlternates {
		var varSelf = self
		varSelf.add(other: theOther)
		return varSelf
	}
	
}

extension StylisticAlternates: FontInfoAttribute {
	
	//swiftlint:disable:next cyclomatic_complexity
	public func featureSettings() -> [(type: Int, selector: Int)] {
		var selectors = [Int]()
		
		if let one = one {
			selectors.append(one ? kStylisticAltOneOnSelector : kStylisticAltOneOffSelector)
		}
		if let two = two {
			selectors.append(two ? kStylisticAltTwoOnSelector : kStylisticAltTwoOffSelector)
		}
		if let three = three {
			selectors.append(three ? kStylisticAltThreeOnSelector : kStylisticAltThreeOffSelector)
		}
		if let four = four {
			selectors.append(four ? kStylisticAltFourOnSelector : kStylisticAltFourOffSelector)
		}
		if let five = five {
			selectors.append(five ? kStylisticAltFiveOnSelector : kStylisticAltFiveOffSelector)
		}
		if let six = six {
			selectors.append(six ? kStylisticAltSixOnSelector : kStylisticAltSixOffSelector)
		}
		if let seven = seven {
			selectors.append(seven ? kStylisticAltSevenOnSelector : kStylisticAltSevenOffSelector)
		}
		if let eight = eight {
			selectors.append(eight ? kStylisticAltEightOnSelector : kStylisticAltEightOffSelector)
		}
		if let nine = nine {
			selectors.append(nine ? kStylisticAltNineOnSelector : kStylisticAltNineOffSelector)
		}
		if let ten = ten {
			selectors.append(ten ? kStylisticAltTenOnSelector : kStylisticAltTenOffSelector)
		}
		if let eleven = eleven {
			selectors.append(eleven ? kStylisticAltElevenOnSelector : kStylisticAltElevenOffSelector)
		}
		if let twelve = twelve {
			selectors.append(twelve ? kStylisticAltTwelveOnSelector : kStylisticAltTwelveOffSelector)
		}
		if let thirteen = thirteen {
			selectors.append(thirteen ? kStylisticAltThirteenOnSelector : kStylisticAltThirteenOffSelector)
		}
		if let fourteen = fourteen {
			selectors.append(fourteen ? kStylisticAltFourteenOnSelector : kStylisticAltFourteenOffSelector)
		}
		if let fifteen = fifteen {
			selectors.append(fifteen ? kStylisticAltFifteenOnSelector : kStylisticAltFifteenOffSelector)
		}
		if let sixteen = sixteen {
			selectors.append(sixteen ? kStylisticAltSixteenOnSelector : kStylisticAltSixteenOffSelector)
		}
		if let seventeen = seventeen {
			selectors.append(seventeen ? kStylisticAltSeventeenOnSelector : kStylisticAltSeventeenOffSelector)
		}
		if let eighteen = eighteen {
			selectors.append(eighteen ? kStylisticAltEighteenOnSelector : kStylisticAltEighteenOffSelector)
		}
		if let nineteen = nineteen {
			selectors.append(nineteen ? kStylisticAltNineteenOnSelector : kStylisticAltNineteenOffSelector)
		}
		if let twenty = twenty {
			selectors.append(twenty ? kStylisticAltTwentyOnSelector : kStylisticAltTwentyOffSelector)
		}
		
		return selectors.map { (type: kStylisticAlternativesType, selector: $0) }
	}
	
}

public func + (lhs: StylisticAlternates, rhs: StylisticAlternates) -> StylisticAlternates {
	return lhs.byAdding(other: rhs)
}

//MARK: - ContextualAlternates

/// Different contextual alternates available for customizing a font. Not
/// all fonts support all (or any) of these options.
public struct ContextualAlternates {
	var contextualAlternates: Bool?
	var swashAlternates: Bool?
	var contextualSwashAlternates: Bool?
	
	public init() { }
}

// Convenience constructors
extension ContextualAlternates {
	
	public static func contextualAlternates(on isOn: Bool) -> ContextualAlternates {
		var alts = ContextualAlternates()
		alts.contextualAlternates = isOn
		return alts
	}
	
	public static func swashAlternates(on isOn: Bool) -> ContextualAlternates {
		var alts = ContextualAlternates()
		alts.swashAlternates = isOn
		return alts
	}
	
	public static func contextualSwashAlternates(on isOn: Bool) -> ContextualAlternates {
		var alts = ContextualAlternates()
		alts.contextualSwashAlternates = isOn
		return alts
	}
	
}

extension ContextualAlternates {
	
	mutating public func add(other theOther: ContextualAlternates) {
		contextualAlternates = theOther.contextualAlternates ?? contextualAlternates
		swashAlternates = theOther.swashAlternates ?? swashAlternates
		contextualSwashAlternates = theOther.contextualSwashAlternates ?? contextualSwashAlternates
	}
	
	public func byAdding(other theOther: ContextualAlternates) -> ContextualAlternates {
		var varSelf = self
		varSelf.add(other: theOther)
		return varSelf
	}
	
}

extension ContextualAlternates: FontInfoAttribute {
	
	public func featureSettings() -> [(type: Int, selector: Int)] {
		var selectors = [Int]()
		
		if let contextualAlternates = contextualAlternates {
			selectors.append(contextualAlternates ? kContextualAlternatesOnSelector : kContextualAlternatesOffSelector)
		}
		if let swashAlternates = swashAlternates {
			selectors.append(swashAlternates ? kSwashAlternatesOnSelector : kSwashAlternatesOffSelector)
		}
		if let contextualSwashAlternates = contextualSwashAlternates {
			selectors.append(contextualSwashAlternates ? kContextualSwashAlternatesOnSelector : kContextualSwashAlternatesOffSelector)
		}
		
		return selectors.map { (type: kContextualAlternatesType, selector: $0) }
	}
	
}

public func + (lhs: ContextualAlternates, rhs: ContextualAlternates) -> ContextualAlternates {
	return lhs.byAdding(other: rhs)
}

#endif
