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

#if os(OSX)
import AppKit
#else
import UIKit
import MobileCoreServices
#endif

#if os(iOS)

@objc public protocol AsyncTextAttachmentDelegate
{
    /// Called when the image has been loaded
    func textAttachmentDidLoadImage(textAttachment: AsyncTextAttachment, displaySizeChanged: Bool)
}

/// An image text attachment that gets loaded from a remote URL
public class AsyncTextAttachment: NSTextAttachment {
    /// Remote URL for the image
    public var imageURL: URL?
    
    /// To specify an absolute display size.
    public var displaySize: CGSize?
    
    /// if determining the display size automatically this can be used to specify a maximum width. If it is not set then the text container's width will be used
    public var maximumDisplayWidth: CGFloat?
    
    /// A delegate to be informed of the finished download
    public weak var delegate: AsyncTextAttachmentDelegate?
    
    /// Remember the text container from delegate message, the current one gets updated after the download
    weak var textContainer: NSTextContainer?
    
    /// The download task to keep track of whether we are already downloading the image
    private var downloadTask: URLSessionDataTask!
    
    /// The size of the downloaded image. Used if we need to determine display size
    private var originalImageSize: CGSize?
    
    /// Designated initializer
    public init(imageURL: URL? = nil, delegate: AsyncTextAttachmentDelegate? = nil) {
        self.imageURL = imageURL
        self.delegate = delegate
        
        super.init(data: nil, ofType: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var image: UIImage? {
        didSet {
            originalImageSize = image?.size
        }
    }
    
    // MARK: - Helpers
    
    private func startAsyncImageDownload() {
        guard let imageURL = imageURL, contents == nil, downloadTask == nil else {
            return
        }
        
        downloadTask = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            
            defer {
                // done with the task
                self.downloadTask = nil
            }
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            
            var displaySizeChanged = false
            
            self.contents = data
            
            let ext = imageURL.pathExtension as CFString
            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext, nil) {
                self.fileType = uti.takeRetainedValue() as String
            }
            
            if let image = UIImage(data: data) {
                let imageSize = image.size
                
                if self.displaySize == nil
                {
                    displaySizeChanged = true
                }
                
                self.originalImageSize = imageSize
            }
            
            DispatchQueue.main.async {
                // tell layout manager so that it should refresh
                if displaySizeChanged {
                    self.textContainer?.layoutManager?.setNeedsLayout(forAttachment: self)
                } else {
                    self.textContainer?.layoutManager?.setNeedsDisplay(forAttachment: self)
                }
                
                // notify the optional delegate
                self.delegate?.textAttachmentDidLoadImage(textAttachment: self, displaySizeChanged: displaySizeChanged)
            }
        }
        
        downloadTask.resume()
    }
    
    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        if let image = image { return image }
        
        guard let contents = contents, let image = UIImage(data: contents) else {
            // remember reference so that we can update it later
            self.textContainer = textContainer
            
            startAsyncImageDownload()
            
            return nil
        }
        
        return image
    }
    
    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        if let displaySize = displaySize {
            return CGRect(origin: CGPoint.zero, size: displaySize)
        }
        
        if let imageSize = originalImageSize {
            let maxWidth = maximumDisplayWidth ?? lineFrag.size.width
            let factor = maxWidth / imageSize.width
            
            return CGRect(origin: CGPoint.zero, size:CGSize(width: Int(imageSize.width * factor), height: Int(imageSize.height * factor)))
        }
        
        return CGRect.zero
    }
}


extension NSLayoutManager
{
    /// Determine the character ranges for an attachment
    private func rangesForAttachment(attachment: NSTextAttachment) -> [NSRange]?
    {
        guard let attributedString = self.textStorage else
        {
            return nil
        }
        
        // find character range for this attachment
        let range = NSRange(location: 0, length: attributedString.length)
        
        var refreshRanges = [NSRange]()
        
        attributedString.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: []) { (value, effectiveRange, nil) in
            
            guard let foundAttachment = value as? NSTextAttachment, foundAttachment == attachment else
            {
                return
            }
            
            // add this range to the refresh ranges
            refreshRanges.append(effectiveRange)
        }
        
        if refreshRanges.count == 0
        {
            return nil
        }
        
        return refreshRanges
    }
    
    /// Trigger a relayout for an attachment
    public func setNeedsLayout(forAttachment attachment: NSTextAttachment)
    {
        guard let ranges = rangesForAttachment(attachment: attachment) else
        {
            return
        }
        
        // invalidate the display for the corresponding ranges
        for range in ranges.reversed() {
            self.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
            
            // also need to trigger re-display or already visible images might not get updated
            self.invalidateDisplay(forCharacterRange: range)
        }
    }
    
    /// Trigger a re-display for an attachment
    public func setNeedsDisplay(forAttachment attachment: NSTextAttachment)
    {
        guard let ranges = rangesForAttachment(attachment: attachment) else
        {
            return
        }
        
        // invalidate the display for the corresponding ranges
        for range in ranges.reversed() {
            self.invalidateDisplay(forCharacterRange: range)
        }
    }
}

#endif
