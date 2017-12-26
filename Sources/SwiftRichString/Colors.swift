//
//  Colors.swift
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
	import UIKit
#elseif os(OSX)
	import AppKit
#endif

#if os(iOS)

import UIKit
	
public extension SRColor {

	
	/// Initialize a new color using given rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB
	/// Return nil if it no valid.
	/// - return: valid SRColor or nil
	public convenience init?(hex: String, alpha: Float, default dColor: SRColor = SRColor.black) {
		guard hex.hasPrefix("#") else {
			self.init(cgColor: dColor.cgColor)
			return
		}
		
		let hexString: String = String(hex[hex.index(hex.startIndex, offsetBy: 1)..<hex.endIndex])
	//	let hexString: String = hex.substring(from: hex.characters.index(hex.startIndex, offsetBy: 1))
		var hexValue:  UInt32 = 0
		
		guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
			self.init(cgColor: dColor.cgColor)
			return
		}
		
		switch (hexString.count) {
		case 3:
			let hex3 = UInt16(hexValue)
			let divisor = CGFloat(15)
			let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
			let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
			let blue    = CGFloat( hex3 & 0x00F      ) / divisor
			self.init(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
		case 4:
			let hex4 = UInt16(hexValue)
			let divisor = CGFloat(15)
			let red     = CGFloat((hex4 & 0xF000) >> 12) / divisor
			let green   = CGFloat((hex4 & 0x0F00) >>  8) / divisor
			let blue    = CGFloat((hex4 & 0x00F0) >>  4) / divisor
			let alpha   = CGFloat( hex4 & 0x000F       ) / divisor
			self.init(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
		case 6:
			let divisor = CGFloat(255)
			let red     = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
			let green   = CGFloat((hexValue & 0x00FF00) >>  8) / divisor
			let blue    = CGFloat( hexValue & 0x0000FF       ) / divisor
			self.init(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
		case 8:
			let divisor = CGFloat(255)
			let red     = CGFloat((hexValue & 0xFF000000) >> 24) / divisor
			let green   = CGFloat((hexValue & 0x00FF0000) >> 16) / divisor
			let blue    = CGFloat((hexValue & 0x0000FF00) >>  8) / divisor
			let alpha   = CGFloat( hexValue & 0x000000FF       ) / divisor
			self.init(red: red, green: green, blue: blue, alpha: alpha)
		default:
			self.init(cgColor: dColor.cgColor)
		}
	}
	
}
#endif
