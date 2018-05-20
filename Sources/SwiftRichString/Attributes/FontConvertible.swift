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

//MARK: - FontConvertible Protocol

/// FontConvertible Protocol; you can implement conformance to any object.
/// By defailt both `String` and `UIFont`/`NSFont` are conform to this protocol.
public protocol FontConvertible {
	/// Transform the instance of the object to a valid `UIFont`/`NSFont` instance.
	///
	/// - Parameter size: optional size of the font.
	/// - Returns: valid font instance.
	func font(size: CGFloat?) -> Font
}


// MARK: - FontConvertible for UIFont/NSFont
extension Font: FontConvertible {
	
	/// Return the same instance of the font with specified size.
	///
	/// - Parameter size: size of the font in points. If size is `nil`, `Font.systemFontSize` is used.
	/// - Returns: instance of the font.
	public func font(size: CGFloat?) -> Font {
		#if os(tvOS)
		return Font(name: self.fontName, size: (size ?? TVOS_SYSTEMFONT_SIZE))!
		#elseif os(watchOS)
		return Font(name: self.fontName, size: (size ?? WATCHOS_SYSTEMFONT_SIZE))!
		#else
		return Font(name: self.fontName, size: (size ?? Font.systemFontSize))!
		#endif
	}
	
}

// MARK: - FontConvertible for String
extension String: FontConvertible {
	
	/// Transform a string to a valid `UIFont`/`NSFont` instance.
	/// String must contain a valid Postscript font's name.
	///
	/// - Parameter size: size of the font.
	/// - Returns: instance of the font.
	public func font(size: CGFloat?) -> Font {
		#if os(tvOS)
		return Font(name: self, size:  (size ?? TVOS_SYSTEMFONT_SIZE))!
		#elseif os(watchOS)
		return Font(name: self, size:  (size ?? WATCHOS_SYSTEMFONT_SIZE))!
		#else
		return Font(name: self, size: (size ?? Font.systemFontSize))!
		#endif
	}
	
}
