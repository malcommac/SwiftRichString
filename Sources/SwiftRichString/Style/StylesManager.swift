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

/// Shortcut to singleton of the `StylesManager`
public let Styles: StylesManager = StylesManager.shared

/// StylesManager act as a central repository where you can register your own style and use
/// globally in your app.
public class StylesManager {
	
	/// Singleton instance.
	public static let shared: StylesManager = StylesManager()
	
	/// You can defeer the creation of a style to the first time its required.
	/// Implementing this method you will receive a call with the name of the style
	/// you are about to provide and you have a chance to make and return it.
	/// Once returned the style is automatically cached.
	public var onDeferStyle: ((String) -> (StyleProtocol?, Bool))? = nil
	
	/// Registered styles.
	public private(set) var styles: [String: StyleProtocol] = [:]
	
	/// Register a new style with given name.
	///
	/// - Parameters:
	///   - name: unique identifier of style.
	///   - style: style to register.
	public func register(_ name: String, style: StyleProtocol) {
		self.styles[name] = style
	}

	/// Return a style registered with given name.
	///
	/// - Parameter name: name of the style
	public subscript(name: String?) -> StyleProtocol? {
		guard let name = name else { return nil }
		
		if let cachedStyle = self.styles[name] { // style is cached
			return cachedStyle
		} else {
			// check if user can provide a deferred creation for this style
			if let (deferredStyle,canCache) = self.onDeferStyle?(name) {
				// cache if requested
				if canCache, let dStyle = deferredStyle { self.styles[name] = dStyle }
				return deferredStyle
			}
			return nil // nothing
		}
	}
	
	/// Return a list of styles registered with given names.
	///
	/// - Parameter names: array of style's name to get.
	public subscript(names: [String]?) -> [StyleProtocol]? {
		guard let names = names else { return nil }
		return names.compactMap { self.styles[$0] }
	}
	
}
