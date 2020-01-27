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

extension String {
    
    private static let escapeAmpRegExp = try! NSRegularExpression(pattern: "&(?!(#[0-9]{2,4}|[A-z]{2,6});)", options: NSRegularExpression.Options(rawValue: 0))

    public func escapeWithUnicodeEntities() -> String {
        let range = NSRange(location: 0, length: self.count)
        return String.escapeAmpRegExp.stringByReplacingMatches(in: self,
                                                               options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                                               range: range,
                                                               withTemplate: "&amp;")
    }
    
}

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

extension NSAttributedString {
    
    @nonobjc func mutableStringCopy() -> NSMutableAttributedString {
        guard let copy = mutableCopy() as? NSMutableAttributedString else {
            fatalError("Failed to mutableCopy() \(self)")
        }
        return copy
    }

}

public extension Array where Array.Element == StyleProtocol {
    
    /// Merge styles from array of `StyleProtocol` elements.
    /// Merge is made in order where each n+1 elements may replace existing keys defined by n-1 elements.
    ///
    /// - Returns: merged style
    func mergeStyle() -> Style {
        var attributes: [NSAttributedString.Key:Any] = [:]
        var textTransforms = [TextTransform]()
        self.forEach {
            attributes.merge($0.attributes, uniquingKeysWith: {
                (_, new) in
                return new
            })
            textTransforms.append(contentsOf: $0.textTransforms ?? [])
        }
        return Style(dictionary: attributes, textTransforms: (textTransforms.isEmpty ? nil : textTransforms))
    }
    
}

extension CGRect {
    
    init?(string: String?) {
        guard let string = string else {
            return nil
        }
        
        let components: [CGFloat] = string.components(separatedBy: ",").compactMap {
            guard let value = Float($0) else { return nil }
            return CGFloat(value)
        }
        
        guard components.count == 4 else {
            return nil
        }
        
        self =  CGRect(x: components[0],
                      y: components[1],
                      width: components[2],
                      height: components[3])
    }
    
}

#if os(OSX)

public extension NSImage {
    
    /// PNG data of the image.
    func pngData() -> Data? {
        self.lockFocus()
        let bitmap = NSBitmapImageRep(focusedViewRect: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        let pngData = bitmap!.representation(using: .png, properties: [:])
        self.unlockFocus()
        return pngData
    }
    
}

#endif
