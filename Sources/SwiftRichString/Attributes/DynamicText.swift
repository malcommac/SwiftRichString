//
//  SwiftRichString
//  Elegant Strings & Attributed Strings Toolkit for Swift
//
//  Created by Daniele Margutti.
//  Copyright © 2018 Daniele Margutti. All rights reserved.
//
//    Web: http://www.danielemargutti.com
//    Email: hello@danielemargutti.com
//    Twitter: @danielemargutti
//
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

#if os(tvOS) || os(watchOS) || os(iOS)
import UIKit

/// DynamicText encapsulate the attributes for fonts to automatically scale to match the current Dynamic Type settings. It uses UIFontMetrics.
public class DynamicText {
    
    /// Set the dynamic size text style.
    /// You can pass any `UIFont.TextStyle` value, if nil UIFontMetrics.default will be used,
    /// which uses the body text style.
    public var style: UIFont.TextStyle?
    
    #if os(OSX) || os(iOS) || os(tvOS)
    /// The trait collection to use when determining compatibility. The returned
    /// font is appropriate for use in an interface that adopts the specified traits.
    public var traitCollection: UITraitCollection?
    #endif
    
    /// Set the maximum size
    /// allowed for the font/text. Use this value to constrain the font to
    /// the specified size when your interface cannot accommodate text that is any larger.
    public var maximumSize: CGFloat?
    
    public typealias InitHandler = ((DynamicText) -> (Void))
    
    //MARK: - INIT
    
    /// Initialize a new dynamic text with optional configuration handler callback.
    ///
    /// - Parameter handler: configuration handler callback.
    public init(_ handler: InitHandler? = nil) {
        handler?(self)
    }
}

#endif
