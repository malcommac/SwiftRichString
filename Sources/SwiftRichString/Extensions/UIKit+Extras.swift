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

#if os(iOS) || os(tvOS)

import UIKit

internal enum IBInterfaceKeys: String {
	case styleName = "SwiftRichString.StyleName"
	case styleObj = "SwiftRichString.StyleObj"
}

//MARK: - UILabel

extension UILabel {
	
	/// The name of a style in the global `NamedStyles` registry.
	@IBInspectable
	public var styleName: String? {
		get { return getAssociatedValue(key: IBInterfaceKeys.styleName.rawValue, object: self) }
		set {
			set(associatedValue: newValue, key: IBInterfaceKeys.styleName.rawValue, object: self)
			self.style = StylesManager.shared[newValue]
		}
	}
	
	/// Style instance to apply. Any change of this value reload the current text of the control with set style.
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
	
	/// Use this to render automatically the texct with the currently set style instance or styleName.
	public var styledText: String? {
		get {
			return attributedText?.string
		}
		set {
			guard let text = newValue else { return }
			self.attributedText = self.style?.set(to: text, range: nil)
		}
	}
	
}

//MARK: - UITextField

extension UITextField {
	
	/// The name of a style in the global `NamedStyles` registry.
	@IBInspectable
	public var styleName: String? {
		get { return getAssociatedValue(key: IBInterfaceKeys.styleName.rawValue, object: self) }
		set {
			set(associatedValue: newValue, key: IBInterfaceKeys.styleName.rawValue, object: self)
			self.style = StylesManager.shared[newValue]
		}
	}
	
	/// Style instance to apply. Any change of this value reload the current text of the control with set style.
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
	
	/// Use this to render automatically the texct with the currently set style instance or styleName.
	public var styledText: String? {
		get {
			return attributedText?.string
		}
		set {
			guard let text = newValue else { return }
			self.attributedText = self.style?.set(to: text, range: nil)
		}
	}
	
}

//MARK: - UITextView

extension UITextView {
	
	/// The name of a style in the global `NamedStyles` registry.
	@IBInspectable
	public var styleName: String? {
		get { return getAssociatedValue(key: IBInterfaceKeys.styleName.rawValue, object: self) }
		set {
			set(associatedValue: newValue, key: IBInterfaceKeys.styleName.rawValue, object: self)
			self.style = StylesManager.shared[newValue]
		}
	}
	
	/// Style instance to apply. Any change of this value reload the current text of the control with set style.
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
	
	/// Use this to render automatically the texct with the currently set style instance or styleName.
	public var styledText: String? {
		get {
			return attributedText?.string
		}
		set {
			guard let text = newValue else { return }
			self.attributedText = self.style?.set(to: text, range: nil)
		}
	}
	
}

#endif

//MARK: - compactMap for Swift 4.0 (not necessary > 4.0)

#if swift(>=4.1)
#else
extension Collection {
	func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
		return try flatMap(transform)
	}
}
#endif
