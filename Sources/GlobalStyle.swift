//
//  GlobalStyle.swift
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

private var _globalStyle: Style? = nil

public extension RichString {
	
	/// Global style is the commong base for each new `Style` instance (excluding the init methods
	/// which explictly don't use it).
	/// You can create a global style for your app and derivate each new additional style from the properties
	/// set here.
	/// By default global style has only `UIFont.systemFont` set with `UIFont.systemFontSize` point size.
	public static var globalStyle: Style {
		get {
			if _globalStyle == nil {
				_globalStyle = Style.init(global: false, kind: .`default`)
				_globalStyle!.paragraph = NSMutableParagraphStyle()
				_globalStyle!.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
			}
			return _globalStyle!
			
		}
		set {
			if newValue.paragraph == nil { newValue.paragraph = NSMutableParagraphStyle() }
			if newValue.font == nil { newValue.font = UIFont.systemFont(ofSize: UIFont.systemFontSize) }
			_globalStyle = newValue
	
		}
	}
	
}
