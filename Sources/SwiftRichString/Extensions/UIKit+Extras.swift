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

extension NSNumber {
	
	internal static func from(float: Float?) -> NSNumber? {
		guard let float = float else { return nil }
		return NSNumber(value: float)
	}
	
	internal static func from(int: Int?) -> NSNumber? {
		guard let int = int else { return nil }
		return NSNumber(value: int)
	}
	
	internal static func from(underlineStyle: NSUnderlineStyle?) -> NSNumber? {
		guard let v = underlineStyle?.rawValue else { return nil }
		return NSNumber(value: v)
	}
	
	internal func toUnderlineStyle() -> NSUnderlineStyle? {
		return NSUnderlineStyle.init(rawValue: self.intValue)
	}
	
}

#if os(iOS) || os(tvOS)

import UIKit

internal enum IBInterfaceKeys: String {
	case styleName = "SwiftRichString.StyleName"
	case styleObj = "SwiftRichString.StyleObj"
}

extension UILabel {
	
	/// The name of a style in the global `NamedStyles` registry. The getter
	/// always returns `nil`, and should not be used.
	@IBInspectable
	public var styleName: String? {
		get { return getAssociatedValue(key: IBInterfaceKeys.styleName.rawValue, object: self) }
		set {
			set(associatedValue: newValue, key: IBInterfaceKeys.styleName.rawValue, object: self)
			self.style = StylesManager.shared[newValue]
		}
	}
	
	public var style: StyleProtocol? {
		set {
			set(associatedValue: newValue, key: IBInterfaceKeys.styleObj.rawValue, object: self)
			self.styledText = self.text
		}
		get {
			if let innerValue: StyleProtocol? = getAssociatedValue(key: IBInterfaceKeys.styleObj.rawValue, object: self) {
				return innerValue
			}
			return StylesManager.shared[self.styleName]
		}
	}
	
	public var styledText: String? {
		get {
			return attributedText?.string
		}
		set {
			self.attributedText = self.style?.set(to: (self.text ?? ""), range: nil)
		}
	}
	
}

#endif
