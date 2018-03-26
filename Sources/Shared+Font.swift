//
//  Shared+Font.swift
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

/// FontConvertible protocol allows you to define serveral types which can be conform to a protocol
/// which transform the type instance to a valid `Font` object can be used in `Style` properties.
public protocol FontConvertible {
	
	/// Convert type to a font object with given size; `nil` is returned in case type cannot be converted to font.
	///
	/// - Parameter size: size of the font.
	/// - Returns: a valid font if applicable, `nil` if conversion fail.
	func toFont(size: CGFloat?) -> Font?
	
	/// Return the size of the font. May return `nil` if not applicable.
	var fontSize: CGFloat? { get }
	
}

// MARK: - String / FontConvertible support for `String` type.
/// Allows to pass a string as font description; `Font` instance is generated automatically if possible.
extension String: FontConvertible {
	
	/// Attempt to generate a font from string.
	///
	/// - Parameter size: if passed font is generated with this size, `nil` to use `UIFont.systemFontSize`
	/// - Returns: font instance if conversion succeded, `nil` otherwise.
	public func toFont(size: CGFloat?) -> Font? {
		return UIFont(name: self, size: size ?? UIFont.systemFontSize)
	}
	
	/// Return `nil` for this type.
	public var fontSize: CGFloat? {
		return nil
	}
	
}

// MARK: - Font / FontConvertible support for `UIFont` type.
extension Font: FontConvertible {
	
	/// Return the font itself with a new size if specified, just receiver if `nil` size is passed.
	///
	/// - Parameter size: size of the new font, `nil` to keep font's instance size.
	/// - Returns: new font.
	public func toFont(size: CGFloat?) -> Font? {
		guard let size = size else { return self }
		let font = UIFont(descriptor: self.fontDescriptor, size: size)
		return font
	}
	
	/// Return the size of the font.
	public var fontSize: CGFloat? {
		return self.pointSize
	}
	
}

/// MARK: - CustomFont / FontConvertible support for custom font generator.
/// This class allows you to generate a variant font from a specified input font passed both as `String` or `Font`.
public struct CustomFont: FontConvertible {
	
	/// Represented font instance
	public private(set) var fontInstance: Font
	
	/// Traits to apply
	public private(set) var traits: FontTraits
	
	/// Size to set
	public private(set) var size: CGFloat
	
	/// Generate font
	public lazy var font: Font = {
		return self.toFont(size: self.size)!
	}()
	
	/// Size of the font
	public var fontSize: CGFloat? {
		return self.size
	}
	
	/// Get the font with styles applied.
	///
	/// - Parameter size: size of the font to generate.
	/// - Returns: new font with given traits and sie.
	public func toFont(size: CGFloat?) -> Font? {
		guard let descriptor = self.fontInstance.fontDescriptor.withSymbolicTraits(self.traits) else {
			debugPrint("Font \(self.fontInstance.fontName) does not have bold trait")
			return self.fontInstance
		}
		let font = Font(descriptor: descriptor, size: (size ?? self.size))
		return font
	}
	
	/// Initialize a new `CustomFont` instance from a `FontConvertible` object.
	///
	/// - Parameters:
	///   - font: source font.
	///   - traits: traits to apply.
	///   - size: size to apply.
	public init?(font: FontConvertible, traits: FontTraits, size: CGFloat) {
		guard let f = font.toFont(size: size) else { return nil }
		self.fontInstance = f
		self.traits = traits
		self.size = size
	}
	
	/// Initialize a new `CustomFont` instance from a given `Font` instance.
	///
	/// - Parameters:
	///   - font: source font.
	///   - traits: traits to apply.
	///   - size: size to apply.
	public init(font: Font, traits: FontTraits, size: CGFloat) {
		self.fontInstance = font
		self.traits = traits
		self.size = size
	}
	
	/// Generate a bold variant of the passed font.
	///
	/// - Parameters:
	///   - font: source font.
	///   - size: size.
	/// - Returns: bold variant of the passed font.
	public static func bold(_ font: FontConvertible, size: CGFloat) -> CustomFont? {
		return CustomFont(font: font, traits: .traitBold, size: size)
	}
	
	/// Generate a italic variant of the passed font.
	///
	/// - Parameters:
	///   - font: source font.
	///   - size: size.
	/// - Returns: italic variant of the passed font.
	public static func italic(_ font: FontConvertible, size: CGFloat) -> CustomFont? {
		return CustomFont(font: font, traits: .traitItalic, size: size)
	}
	/// Generate an expanded variant of the passed font.
	///
	/// - Parameters:
	///   - font: source font.
	///   - size: size.
	/// - Returns: expanded variant of the passed font.
	public static func expanded(_ font: FontConvertible, size: CGFloat) -> CustomFont? {
		return CustomFont(font: font, traits: .traitExpanded, size: size)
	}
	/// Generate a condensed variant of the passed font.
	///
	/// - Parameters:
	///   - font: source font.
	///   - size: size.
	/// - Returns: condensed variant of the passed font.
	public static func condensed(_ font: FontConvertible, size: CGFloat) -> CustomFont? {
		return CustomFont(font: font, traits: .traitCondensed, size: size)
	}
	
	/// Generate a monospaced variant of the passed font.
	///
	/// - Parameters:
	///   - font: source font.
	///   - size: size.
	/// - Returns: monospaced variant of the passed font.
	public static func monospaced(_ font: FontConvertible, size: CGFloat) -> CustomFont? {
		return CustomFont(font: font, traits: .traitMonoSpace, size: size)
	}
	
}

public enum SystemFonts: String, FontConvertible {
	case Copperplate_Light = "Copperplate-Light"
	case Copperplate = "Copperplate"
	case Copperplate_Bold = "Copperplate-Bold"
	case IowanOldStyle_Italic = "IowanOldStyle-Italic"
	case IowanOldStyle_Roman = "IowanOldStyle-Roman"
	case IowanOldStyle_BoldItalic = "IowanOldStyle-BoldItalic"
	case IowanOldStyle_Bold = "IowanOldStyle-Bold"
	case KohinoorTelugu_Regular = "KohinoorTelugu-Regular"
	case KohinoorTelugu_Medium = "KohinoorTelugu-Medium"
	case KohinoorTelugu_Light = "KohinoorTelugu-Light"
	case Thonburi = "Thonburi"
	case Thonburi_Bold = "Thonburi-Bold"
	case Thonburi_Light = "Thonburi-Light"
	case CourierNewPS_BoldMT = "CourierNewPS-BoldMT"
	case CourierNewPS_ItalicMT = "CourierNewPS-ItalicMT"
	case CourierNewPSMT = "CourierNewPSMT"
	case CourierNewPS_BoldItalicMT = "CourierNewPS-BoldItalicMT"
	case GillSans_Italic = "GillSans-Italic"
	case GillSans_Bold = "GillSans-Bold"
	case GillSans_BoldItalic = "GillSans-BoldItalic"
	case GillSans_LightItalic = "GillSans-LightItalic"
	case GillSans = "GillSans"
	case GillSans_Light = "GillSans-Light"
	case GillSans_SemiBold = "GillSans-SemiBold"
	case GillSans_SemiBoldItalic = "GillSans-SemiBoldItalic"
	case GillSans_UltraBold = "GillSans-UltraBold"
	case AppleSDGothicNeo_Bold = "AppleSDGothicNeo-Bold"
	case AppleSDGothicNeo_Thin = "AppleSDGothicNeo-Thin"
	case AppleSDGothicNeo_UltraLight = "AppleSDGothicNeo-UltraLight"
	case AppleSDGothicNeo_Regular = "AppleSDGothicNeo-Regular"
	case AppleSDGothicNeo_Light = "AppleSDGothicNeo-Light"
	case AppleSDGothicNeo_Medium = "AppleSDGothicNeo-Medium"
	case AppleSDGothicNeo_SemiBold = "AppleSDGothicNeo-SemiBold"
	case MarkerFelt_Thin = "MarkerFelt-Thin"
	case MarkerFelt_Wide = "MarkerFelt-Wide"
	case AvenirNextCondensed_BoldItalic = "AvenirNextCondensed-BoldItalic"
	case AvenirNextCondensed_Heavy = "AvenirNextCondensed-Heavy"
	case AvenirNextCondensed_Medium = "AvenirNextCondensed-Medium"
	case AvenirNextCondensed_Regular = "AvenirNextCondensed-Regular"
	case AvenirNextCondensed_HeavyItalic = "AvenirNextCondensed-HeavyItalic"
	case AvenirNextCondensed_MediumItalic = "AvenirNextCondensed-MediumItalic"
	case AvenirNextCondensed_Italic = "AvenirNextCondensed-Italic"
	case AvenirNextCondensed_UltraLightItalic = "AvenirNextCondensed-UltraLightItalic"
	case AvenirNextCondensed_UltraLight = "AvenirNextCondensed-UltraLight"
	case AvenirNextCondensed_DemiBold = "AvenirNextCondensed-DemiBold"
	case AvenirNextCondensed_Bold = "AvenirNextCondensed-Bold"
	case AvenirNextCondensed_DemiBoldItalic = "AvenirNextCondensed-DemiBoldItalic"
	case TamilSangamMN = "TamilSangamMN"
	case TamilSangamMN_Bold = "TamilSangamMN-Bold"
	case HelveticaNeue_Italic = "HelveticaNeue-Italic"
	case HelveticaNeue_Bold = "HelveticaNeue-Bold"
	case HelveticaNeue_UltraLight = "HelveticaNeue-UltraLight"
	case HelveticaNeue_CondensedBlack = "HelveticaNeue-CondensedBlack"
	case HelveticaNeue_BoldItalic = "HelveticaNeue-BoldItalic"
	case HelveticaNeue_CondensedBold = "HelveticaNeue-CondensedBold"
	case HelveticaNeue_Medium = "HelveticaNeue-Medium"
	case HelveticaNeue_Light = "HelveticaNeue-Light"
	case HelveticaNeue_Thin = "HelveticaNeue-Thin"
	case HelveticaNeue_ThinItalic = "HelveticaNeue-ThinItalic"
	case HelveticaNeue_LightItalic = "HelveticaNeue-LightItalic"
	case HelveticaNeue_UltraLightItalic = "HelveticaNeue-UltraLightItalic"
	case HelveticaNeue_MediumItalic = "HelveticaNeue-MediumItalic"
	case HelveticaNeue = "HelveticaNeue"
	case GurmukhiMN_Bold = "GurmukhiMN-Bold"
	case GurmukhiMN = "GurmukhiMN"
	case TimesNewRomanPSMT = "TimesNewRomanPSMT"
	case TimesNewRomanPS_BoldItalicMT = "TimesNewRomanPS-BoldItalicMT"
	case TimesNewRomanPS_ItalicMT = "TimesNewRomanPS-ItalicMT"
	case TimesNewRomanPS_BoldMT = "TimesNewRomanPS-BoldMT"
	case Georgia_BoldItalic = "Georgia-BoldItalic"
	case Georgia = "Georgia"
	case Georgia_Italic = "Georgia-Italic"
	case Georgia_Bold = "Georgia-Bold"
	case AppleColorEmoji = "AppleColorEmoji"
	case ArialRoundedMTBold = "ArialRoundedMTBold"
	case Kailasa_Bold = "Kailasa-Bold"
	case Kailasa = "Kailasa"
	case KohinoorDevanagari_Light = "KohinoorDevanagari-Light"
	case KohinoorDevanagari_Regular = "KohinoorDevanagari-Regular"
	case KohinoorDevanagari_Semibold = "KohinoorDevanagari-Semibold"
	case KohinoorBangla_Semibold = "KohinoorBangla-Semibold"
	case KohinoorBangla_Regular = "KohinoorBangla-Regular"
	case KohinoorBangla_Light = "KohinoorBangla-Light"
	case ChalkboardSE_Bold = "ChalkboardSE-Bold"
	case ChalkboardSE_Light = "ChalkboardSE-Light"
	case ChalkboardSE_Regular = "ChalkboardSE-Regular"
	case SinhalaSangamMN_Bold = "SinhalaSangamMN-Bold"
	case SinhalaSangamMN = "SinhalaSangamMN"
	case PingFangTC_Medium = "PingFangTC-Medium"
	case PingFangTC_Regular = "PingFangTC-Regular"
	case PingFangTC_Light = "PingFangTC-Light"
	case PingFangTC_Ultralight = "PingFangTC-Ultralight"
	case PingFangTC_Semibold = "PingFangTC-Semibold"
	case PingFangTC_Thin = "PingFangTC-Thin"
	case GujaratiSangamMN_Bold = "GujaratiSangamMN-Bold"
	case GujaratiSangamMN = "GujaratiSangamMN"
	case DamascusLight = "DamascusLight"
	case DamascusBold = "DamascusBold"
	case DamascusSemiBold = "DamascusSemiBold"
	case DamascusMedium = "DamascusMedium"
	case Damascus = "Damascus"
	case Noteworthy_Light = "Noteworthy-Light"
	case Noteworthy_Bold = "Noteworthy-Bold"
	case GeezaPro = "GeezaPro"
	case GeezaPro_Bold = "GeezaPro-Bold"
	case Avenir_Medium = "Avenir-Medium"
	case Avenir_HeavyOblique = "Avenir-HeavyOblique"
	case Avenir_Book = "Avenir-Book"
	case Avenir_Light = "Avenir-Light"
	case Avenir_Roman = "Avenir-Roman"
	case Avenir_BookOblique = "Avenir-BookOblique"
	case Avenir_Black = "Avenir-Black"
	case Avenir_MediumOblique = "Avenir-MediumOblique"
	case Avenir_BlackOblique = "Avenir-BlackOblique"
	case Avenir_Heavy = "Avenir-Heavy"
	case Avenir_LightOblique = "Avenir-LightOblique"
	case Avenir_Oblique = "Avenir-Oblique"
	case AcademyEngravedLetPlain = "AcademyEngravedLetPlain"
	case DiwanMishafi = "DiwanMishafi"
	case Futura_CondensedMedium = "Futura-CondensedMedium"
	case Futura_CondensedExtraBold = "Futura-CondensedExtraBold"
	case Futura_Medium = "Futura-Medium"
	case Futura_MediumItalic = "Futura-MediumItalic"
	case Farah = "Farah"
	case KannadaSangamMN = "KannadaSangamMN"
	case KannadaSangamMN_Bold = "KannadaSangamMN-Bold"
	case ArialHebrew_Bold = "ArialHebrew-Bold"
	case ArialHebrew_Light = "ArialHebrew-Light"
	case ArialHebrew = "ArialHebrew"
	case ArialMT = "ArialMT"
	case Arial_BoldItalicMT = "Arial-BoldItalicMT"
	case Arial_BoldMT = "Arial-BoldMT"
	case Arial_ItalicMT = "Arial-ItalicMT"
	case PartyLetPlain = "PartyLetPlain"
	case Chalkduster = "Chalkduster"
	case HoeflerText_Italic = "HoeflerText-Italic"
	case HoeflerText_Regular = "HoeflerText-Regular"
	case HoeflerText_Black = "HoeflerText-Black"
	case HoeflerText_BlackItalic = "HoeflerText-BlackItalic"
	case Optima_Regular = "Optima-Regular"
	case Optima_ExtraBlack = "Optima-ExtraBlack"
	case Optima_BoldItalic = "Optima-BoldItalic"
	case Optima_Italic = "Optima-Italic"
	case Optima_Bold = "Optima-Bold"
	case Palatino_Bold = "Palatino-Bold"
	case Palatino_Roman = "Palatino-Roman"
	case Palatino_BoldItalic = "Palatino-BoldItalic"
	case Palatino_Italic = "Palatino-Italic"
	case LaoSangamMN = "LaoSangamMN"
	case MalayalamSangamMN_Bold = "MalayalamSangamMN-Bold"
	case MalayalamSangamMN = "MalayalamSangamMN"
	case AlNile_Bold = "AlNile-Bold"
	case AlNile = "AlNile"
	case BradleyHandITCTT_Bold = "BradleyHandITCTT-Bold"
	case PingFangHK_Ultralight = "PingFangHK-Ultralight"
	case PingFangHK_Semibold = "PingFangHK-Semibold"
	case PingFangHK_Thin = "PingFangHK-Thin"
	case PingFangHK_Light = "PingFangHK-Light"
	case PingFangHK_Regular = "PingFangHK-Regular"
	case PingFangHK_Medium = "PingFangHK-Medium"
	case Trebuchet_BoldItalic = "Trebuchet-BoldItalic"
	case TrebuchetMS = "TrebuchetMS"
	case TrebuchetMS_Bold = "TrebuchetMS-Bold"
	case TrebuchetMS_Italic = "TrebuchetMS-Italic"
	case Helvetica_Bold = "Helvetica-Bold"
	case Helvetica = "Helvetica"
	case Helvetica_LightOblique = "Helvetica-LightOblique"
	case Helvetica_Oblique = "Helvetica-Oblique"
	case Helvetica_BoldOblique = "Helvetica-BoldOblique"
	case Helvetica_Light = "Helvetica-Light"
	case Courier_BoldOblique = "Courier-BoldOblique"
	case Courier = "Courier"
	case Courier_Bold = "Courier-Bold"
	case Courier_Oblique = "Courier-Oblique"
	case Cochin_Bold = "Cochin-Bold"
	case Cochin = "Cochin"
	case Cochin_Italic = "Cochin-Italic"
	case Cochin_BoldItalic = "Cochin-BoldItalic"
	case HiraMinProN_W6 = "HiraMinProN-W6"
	case HiraMinProN_W3 = "HiraMinProN-W3"
	case DevanagariSangamMN = "DevanagariSangamMN"
	case DevanagariSangamMN_Bold = "DevanagariSangamMN-Bold"
	case OriyaSangamMN = "OriyaSangamMN"
	case OriyaSangamMN_Bold = "OriyaSangamMN-Bold"
	case SnellRoundhand_Bold = "SnellRoundhand-Bold"
	case SnellRoundhand = "SnellRoundhand"
	case SnellRoundhand_Black = "SnellRoundhand-Black"
	case ZapfDingbatsITC = "ZapfDingbatsITC"
	case BodoniSvtyTwoITCTT_Bold = "BodoniSvtyTwoITCTT-Bold"
	case BodoniSvtyTwoITCTT_Book = "BodoniSvtyTwoITCTT-Book"
	case BodoniSvtyTwoITCTT_BookIta = "BodoniSvtyTwoITCTT-BookIta"
	case Verdana_Italic = "Verdana-Italic"
	case Verdana_BoldItalic = "Verdana-BoldItalic"
	case Verdana = "Verdana"
	case Verdana_Bold = "Verdana-Bold"
	case AmericanTypewriter_CondensedLight = "AmericanTypewriter-CondensedLight"
	case AmericanTypewriter = "AmericanTypewriter"
	case AmericanTypewriter_CondensedBold = "AmericanTypewriter-CondensedBold"
	case AmericanTypewriter_Light = "AmericanTypewriter-Light"
	case AmericanTypewriter_Bold = "AmericanTypewriter-Bold"
	case AmericanTypewriter_Condensed = "AmericanTypewriter-Condensed"
	case AvenirNext_UltraLight = "AvenirNext-UltraLight"
	case AvenirNext_UltraLightItalic = "AvenirNext-UltraLightItalic"
	case AvenirNext_Bold = "AvenirNext-Bold"
	case AvenirNext_BoldItalic = "AvenirNext-BoldItalic"
	case AvenirNext_DemiBold = "AvenirNext-DemiBold"
	case AvenirNext_DemiBoldItalic = "AvenirNext-DemiBoldItalic"
	case AvenirNext_Medium = "AvenirNext-Medium"
	case AvenirNext_HeavyItalic = "AvenirNext-HeavyItalic"
	case AvenirNext_Heavy = "AvenirNext-Heavy"
	case AvenirNext_Italic = "AvenirNext-Italic"
	case AvenirNext_Regular = "AvenirNext-Regular"
	case AvenirNext_MediumItalic = "AvenirNext-MediumItalic"
	case Baskerville_Italic = "Baskerville-Italic"
	case Baskerville_SemiBold = "Baskerville-SemiBold"
	case Baskerville_BoldItalic = "Baskerville-BoldItalic"
	case Baskerville_SemiBoldItalic = "Baskerville-SemiBoldItalic"
	case Baskerville_Bold = "Baskerville-Bold"
	case Baskerville = "Baskerville"
	case KhmerSangamMN = "KhmerSangamMN"
	case Didot_Italic = "Didot-Italic"
	case Didot_Bold = "Didot-Bold"
	case Didot = "Didot"
	case SavoyeLetPlain = "SavoyeLetPlain"
	case BodoniOrnamentsITCTT = "BodoniOrnamentsITCTT"
	case Symbol = "Symbol"
	case Menlo_Italic = "Menlo-Italic"
	case Menlo_Bold = "Menlo-Bold"
	case Menlo_Regular = "Menlo-Regular"
	case Menlo_BoldItalic = "Menlo-BoldItalic"
	case BodoniSvtyTwoSCITCTT_Book = "BodoniSvtyTwoSCITCTT-Book"
	case Papyrus = "Papyrus"
	case Papyrus_Condensed = "Papyrus-Condensed"
	case HiraginoSans_W3 = "HiraginoSans-W3"
	case HiraginoSans_W6 = "HiraginoSans-W6"
	case PingFangSC_Ultralight = "PingFangSC-Ultralight"
	case PingFangSC_Regular = "PingFangSC-Regular"
	case PingFangSC_Semibold = "PingFangSC-Semibold"
	case PingFangSC_Thin = "PingFangSC-Thin"
	case PingFangSC_Light = "PingFangSC-Light"
	case PingFangSC_Medium = "PingFangSC-Medium"
	case EuphemiaUCAS_Italic = "EuphemiaUCAS-Italic"
	case EuphemiaUCAS = "EuphemiaUCAS"
	case EuphemiaUCAS_Bold = "EuphemiaUCAS-Bold"
	case Zapfino = "Zapfino"
	case BodoniSvtyTwoOSITCTT_Book = "BodoniSvtyTwoOSITCTT-Book"
	case BodoniSvtyTwoOSITCTT_Bold = "BodoniSvtyTwoOSITCTT-Bold"
	case BodoniSvtyTwoOSITCTT_BookIt = "BodoniSvtyTwoOSITCTT-BookIt"
	
	/// Return a font from receiver.
	/// - Parameter size: size of the font.
	/// - Returns: font instance.
	public func toFont(size: CGFloat?) -> Font? {
		let s = (size ?? UIFont.systemFontSize)
		guard let d = UIFont(name: self.rawValue, size: s) else {
			return nil
		}
		return d
	}
	
	/// Return a font from receiver.
	///
	/// - Parameters:
	///   - size: size of the font.
	///   - traits: traits to apply.
	/// - Returns: font instance
	public func toFont(size: CGFloat?, traits: FontTraits = []) -> Font? {
		let s = (size ?? UIFont.systemFontSize)
		guard let d = UIFontDescriptor.init(name: self.rawValue, size: s).withSymbolicTraits(traits) else {
			return nil
		}
		return UIFont(descriptor: d, size: s)
	}
	
	/// Not applicable
	public var fontSize: CGFloat? {
		return nil
	}
	
	/// This is the internal function which allows us to generate the enum above
	///
	/// - Returns: raw enum definitions
	public static func generateEnumList() -> String {
		return Font.familyNames
			.flatMap { Font.fontNames(forFamilyName: $0) }
			.map { "case \($0.replacingOccurrences(of: "-", with: "_")) = \"\($0)\"" }
			.joined(separator: "\n")
	}
}

