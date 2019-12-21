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

public extension AttributedString {
    
    #if os(OSX) || os(iOS)
    
    convenience init?(imageNamed: String?, bounds: String? = nil) {
        guard let imageNamed = imageNamed else {
            return nil
        }
        
        let boundsRect = CGRect(string: bounds)
        self.init(image: Image(named: imageNamed), bounds: boundsRect)
    }
    
    /// Initialize a new attributed string from an image.
    ///
    /// - Parameters:
    ///   - image: image to use.
    ///   - bounds: location and size of the image, if `nil` the default bounds is applied.
    convenience init?(image: Image?, bounds: CGRect? = nil) {
        guard let image = image else {
            return nil
        }
        
        var attachment: NSTextAttachment!
        if #available(iOS 13.0, *) {
            attachment = NSTextAttachment(image: image)
        } else {
            attachment = NSTextAttachment(data: image.pngData()!, ofType: "png")
        }
        
        if let bounds = bounds {
            attachment.bounds = bounds
        }
        
        self.init(attachment: attachment)
    }
    #endif
    
}
