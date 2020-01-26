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

public typealias StyleGroup = StyleXML

public class StyleXML: StyleProtocol {
    
    // The following attributes are ignored for StyleXML because are read from the sub styles.
    public var attributes: [NSAttributedString.Key : Any] = [:]
    public var fontData: FontData? = nil
    public var textTransforms: [TextTransform]? = nil
    
    /// Ordered dictionary of the styles inside the group
    public private(set) var styles: [String : StyleProtocol]

    /// Style to apply as base. If set, before parsing the string style is applied (add/set)
    /// to the existing source.
    public var baseStyle: StyleProtocol?
    
    /// XML Parsing options.
    /// By default `escapeString` is applied.
    public var xmlParsingOptions: XMLParsingOptions = [.escapeString]
    
    /// Image provider is called to provide custom image when `StyleXML` encounter a `img` tag image.
    /// If not implemented the image is automatically searched inside any bundled `xcassets`.
    public var imageProvider: ((_ name: String, _ attributes: [String: String]?) -> Image?)? = nil
    
    /// Dynamic attributes resolver.
    /// By default the `StandardXMLAttributesResolver` instance is used.
    public var xmlAttributesResolver: XMLDynamicAttributesResolver = StandardXMLAttributesResolver()
    
    // MARK: - Initialization
    
    /// Initialize a new `StyleXML` with a dictionary of style and names.
    /// Note: Ordered is not guarantee, use `init(_ styles:[(String, StyleProtocol)]` if you
    /// need to keep the order of the styles.
    ///
    /// - Parameters:
    ///   - base: base style applied to the entire string.
    ///   - styles: styles dictionary used to map your xml tags to styles definitions.
    public init(base: StyleProtocol? = nil, _ styles: [String: StyleProtocol] = [:]) {
        self.styles = styles
        self.baseStyle = base
    }
    
    // MARK: - Public Methods
    
    /// Append a new style with given name inside the list.
    /// Order is preserved.
    ///
    /// - Parameters:
    ///   - style: style you want to add.
    ///   - name: unique name of the style.
    public func add(style: Style, as name: String) {
        return self.styles[name] = style
    }
    
    
    /// Remove the style with given name.
    ///
    /// - Parameter name: name of the style to remove.
    /// - Returns: removed style instance.
    @discardableResult
    public func remove(style name: String) -> StyleProtocol? {
        return styles.removeValue(forKey: name)
    }
    
    //MARK: - Rendering Methods
    
    /// Render given source with styles defined inside the receiver.
    /// Styles are added as sum to any existing
    ///
    /// - Parameters:
    ///   - source: source to render.
    ///   - range: range of characters to render, `nil` to apply rendering to the entire content.
    /// - Returns: attributed string
    public func set(to source: String, range: NSRange?) -> AttributedString {
        let attributed = NSMutableAttributedString(string: source)
        return self.apply(to: attributed, adding: true, range: range)
    }
    
    /// Render given source string by appending parsed styles to the existing attributed string.
    ///
    /// - Parameters:
    ///   - source: source attributed string.
    ///   - range: range of parse.
    /// - Returns: same istance of `source` with applied styles.
    public func add(to source: AttributedString, range: NSRange?) -> AttributedString {
        return self.apply(to: source, adding: true, range: range)
    }
    
    /// Render given source string by replacing existing styles to parsed tags.
    ///
    /// - Parameters:
    ///   - source: source attributed string.
    ///   - range: range of parse.
    /// - Returns: same istance of `source` with applied styles.
    public func set(to source: AttributedString, range: NSRange?) -> AttributedString {
        return self.apply(to: source, adding: false, range: range)
    }
    
    /// Parse tags and render the attributed string with the styles defined into the receiver.
    ///
    /// - Parameters:
    ///   - attrStr: source attributed string
    ///   - adding: `true` to add styles defined to existing styles, `false` to replace any existing style inside tags.
    ///   - range: range of operation, `nil` for entire string.
    /// - Returns: modified attributed string, same instance of the `source`.
    public func apply(to attrStr: AttributedString, adding: Bool, range: NSRange?) -> AttributedString {
        do {
            let xmlParser = XMLStringBuilder(styleXML: self, string: attrStr.string)
            return try xmlParser.parse()
        } catch {
            debugPrint("Failed to generate attributed string from xml: \(error)")
            return attrStr
        }
    }
    
}
