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
    
    #if os(iOS)

    /// Initialize a new text attachment with a remote image resource.
    /// Image will be loaded asynchronously after the text appear inside the control.
    ///
    /// - Parameters:
    ///   - imageURL: url of the image. If url is not valid resource will be not downloaded.
    ///   - bounds: set a non `nil` value to express set the rect of attachment.
    convenience init?(imageURL: String?, bounds: String? = nil) {
        guard let imageURL = imageURL, let url = URL(string: imageURL) else {
            return nil
        }
                
        let attachment = AsyncTextAttachment()
        attachment.imageURL = url
        
        if let bounds = CGRect(string: bounds) {
            attachment.bounds = bounds
        }
    
        self.init(attachment: attachment)
    }
    
    #endif
    
    #if os(iOS) || os(OSX)

    /// Initialize a new text attachment with local image contained into the assets.
    ///
    /// - Parameters:
    ///   - imageNamed: name of the image into the assets; if `nil` resource will be not loaded.
    ///   - bounds: set a non `nil` value to express set the rect of attachment.
    convenience init?(imageNamed: String?, bounds: String? = nil) {
        guard let imageNamed = imageNamed else {
            return nil
        }
        
        let image = Image(named: imageNamed)
        self.init(image: image, bounds: bounds)
    }
    
    /// Initialize a new attributed string from an image.
    ///
    /// - Parameters:
    ///   - image: image to use.
    ///   - bounds: location and size of the image, if `nil` the default bounds is applied.
    convenience init?(image: Image?, bounds: String? = nil) {
        guard let image = image else {
            return nil
        }
        
        #if os(OSX)
        let attachment = NSTextAttachment(data: image.pngData()!, ofType: "png")
        #else
        var attachment: NSTextAttachment!
        if #available(iOS 13.0, *) {
            // Due to a bug (?) in UIKit we should use two methods to allocate the text attachment
            // in order to render the image as template or original. If we use the
            // NSTextAttachment(image: image) with a .alwaysOriginal rendering mode it will be
            // ignored.
            if image.renderingMode == .alwaysTemplate {
                attachment = NSTextAttachment(image: image)
            } else {
                attachment =  NSTextAttachment()
                attachment.image = image.withRenderingMode(.alwaysOriginal)
            }
        } else {
            // It does not work on iOS12, return empty set.s
            // attachment = NSTextAttachment(data: image.pngData()!, ofType: "png")
            attachment =  NSTextAttachment()
            attachment.image = image.withRenderingMode(.alwaysOriginal)
        }
        #endif
        
        if let boundsRect = CGRect(string: bounds) {
            attachment.bounds = boundsRect
        }
        
        self.init(attachment: attachment)
    }
    
    #endif
        
}
