//
//  Colors.swift
//  SwiftStyler
//
//  Created by Daniele Margutti on 07/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import Foundation

public extension UIColor {

	
	/// Initialize a new color using given rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB
	/// Return nil if it no valid.
	/// - return: valid UIColor or nil
	public convenience init?(hex: String, alpha: Float, default dColor: UIColor = UIColor.black) {
		guard hex.hasPrefix("#") else {
			self.init(cgColor: dColor.cgColor)
			return
		}
		
		let hexString: String = hex.substring(from: hex.characters.index(hex.startIndex, offsetBy: 1))
		var hexValue:  UInt32 = 0
		
		guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
			self.init(cgColor: dColor.cgColor)
			return
		}
		
		switch (hexString.characters.count) {
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
