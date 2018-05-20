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

// MARK: - ColorConvertible

/// `ColorConvertible` protocol conformance is used to pass your own instance of a color representable object
/// as color's attributes for several properties inside a style. Style get the color instance from your object
/// and use it inside for string attributes.
/// Both `String` and `UIColor`/`NSColor` already conforms this protocol.
public protocol ColorConvertible {
	/// Transform a instance of a `ColorConvertible` conform object to a valid `UIColor`/`NSColor`.
	var color: Color { get }
}

// MARK: - ColorConvertible for `UIColor`/`NSColor`

extension Color: ColorConvertible {
	
	/// Just return itself
	public var color: Color {
		return self
	}
	
	/// Initialize a new color from HEX string representation.
	///
	/// - Parameter hexString: hex string
	public convenience init(hexString: String) {
		let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
		let scanner   = Scanner(string: hexString)
		
		if hexString.hasPrefix("#") {
			scanner.scanLocation = 1
		}
		
		var color: UInt32 = 0
		
		if scanner.scanHexInt32(&color) {
			self.init(hex: color, useAlpha: hexString.count > 7)
		} else {
			self.init(hex: 0x000000)
		}
	}
	
	/// Initialize a new color from HEX string as UInt32 with optional alpha chanell.
	///
	/// - Parameters:
	///   - hex: hex value
	///   - alphaChannel: `true` to include alpha channel, `false` to make it opaque.
	public convenience init(hex: UInt32, useAlpha alphaChannel: Bool = false) {
		let mask = UInt32(0xFF)
		
		let r = hex >> (alphaChannel ? 24 : 16) & mask
		let g = hex >> (alphaChannel ? 16 : 8) & mask
		let b = hex >> (alphaChannel ? 8 : 0) & mask
		let a = alphaChannel ? hex & mask : 255
		
		let red   = CGFloat(r) / 255
		let green = CGFloat(g) / 255
		let blue  = CGFloat(b) / 255
		let alpha = CGFloat(a) / 255
		
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}
	
}

// MARK: - ColorConvertible for `String`

extension String: ColorConvertible {
	
	/// Transform a string to a color. String must be a valid HEX representation of the color.
	public var color: Color {
		return Color(hexString: self)
	}
	
}

