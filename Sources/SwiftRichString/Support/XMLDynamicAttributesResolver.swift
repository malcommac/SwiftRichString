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

import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

// MARK: - XMLDynamicAttributesResolver

public protocol XMLDynamicAttributesResolver {
    
    /// You are receiving this event when SwiftRichString correctly render an existing tag but the tag
    /// contains extra attributes you may want to handle.
    /// For example you can pass a specific tag `<bold color="#db13f2">text/<bold>` and you want to override
    /// the color with passed value in tags.
    ///
    /// - Parameters:
    ///   - attributedString: attributed string. You will receive it after the style is applied.
    ///   - xmlStyle: xml style information with tag, applied style and the dictionary with extra attributes.
    func applyDynamicAttributes(to attributedString: inout AttributedString, xmlStyle: XMLDynamicStyle)
    
    /// You will receive this event when SwiftRichString can't found a received style name into provided group tags.
    /// You can decide to handle it. The default receiver for example uses the `a` tag to render passed url if `href`
    /// attribute is alo present.
    ///
    /// - Parameters:
    ///   - tag: tag name received.
    ///   - attributedString: attributed string received.
    ///   - attributes: attributes of the tag received.
    func styleForUnknownXMLTag(_ tag: String, to attributedString: inout AttributedString, attributes: [String: String]?)

}

// MARK: - StandardXMLAttributesResolver

open class StandardXMLAttributesResolver: XMLDynamicAttributesResolver {
    
    public func applyDynamicAttributes(to attributedString: inout AttributedString, xmlStyle: XMLDynamicStyle) {
        let finalStyleToApply = Style()
        xmlStyle.enumerateAttributes { key, value  in
            switch key {
                case "color": // color support
                    finalStyleToApply.color = Color(hexString: value)
                
                default:
                    break
            }
        }
        
        attributedString.add(style: finalStyleToApply)
    }
    
    public func styleForUnknownXMLTag(_ tag: String, to attributedString: inout AttributedString, attributes: [String: String]?) {
        let finalStyleToApply = Style()
        switch tag {
            case "a": // href support
                finalStyleToApply.linkURL = URL(string: attributes?["href"])
            
            case "img":
                #if os(iOS)
                // Remote Image URL support
                if let url = attributes?["url"] {
                    if let image = AttributedString(imageURL: url, bounds: attributes?["rect"]) {
                        attributedString.append(image)
                    }
                }
                #endif
                
                #if os(iOS) || os(OSX)
                // Local Image support
                if let imageName = attributes?["named"] {
                    if let image = AttributedString(imageNamed: imageName, bounds: attributes?["rect"]) {
                        attributedString.append(image)
                    }
                }
                #endif
            
            default:
                break
        }
        attributedString.add(style: finalStyleToApply)
    }
    
}
