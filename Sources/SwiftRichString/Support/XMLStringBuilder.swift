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

// MARK: - XMLStringBuilderError

public struct XMLStringBuilderError: Error {
    public let parserError: Error
    public let line: Int
    public let column: Int
}

// MARK: - XMLParsingOptions

public struct XMLParsingOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Do not wrap the fragment with a top-level element. Wrapping the XML will
    /// cause a copy of the entire XML string, so for very large strings, it is
    /// recommended that you include a root node yourself and pass this option.
    public static let doNotWrapXML = XMLParsingOptions(rawValue: 1)
    
    /// Perform string escaping to replace all characters which is not supported by NSXMLParser
    /// into the specified encoding with decimal entity.
    /// For example if your string contains '&' character parser will break the style.
    /// This option is active by default.
    public static let escapeString = XMLParsingOptions(rawValue: 2)
    
}

// MARK: - XMLStringBuilder

public class XMLStringBuilder: NSObject, XMLParserDelegate {
        
    // MARK: Private Properties
    private static let topTag = "source"
    
    /// Parser engine.
    private var xmlParser: XMLParser
    
    /// Parsing options.
    private var options: XMLParsingOptions {
        return styleXML.xmlParsingOptions
    }
    
    /// Produced final attributed string
    private var attributedString: AttributedString
    
    /// Base style to apply as common style of the entire string.
    private var baseStyle: StyleProtocol? {
        return styleXML.baseStyle
    }
    
    /// Styles to apply.
    private var styles: [String: StyleProtocol] {
        return styleXML.styles
    }
    
    /// Styles applied at each fragment.
    private var xmlStylers = [XMLDynamicStyle]()
    
    /// XML Attributes resolver
    public var xmlAttributesResolver: XMLDynamicAttributesResolver {
        return styleXML.xmlAttributesResolver
    }

    // The XML parser sometimes splits strings, which can break localization-sensitive
    // string transforms. Work around this by using the currentString variable to
    // accumulate partial strings, and then reading them back out as a single string
    // when the current element ends, or when a new one is started.
    var currentString: String?
    
    /// StyleXML instance.
    private weak var styleXML: StyleXML!
        
    // MARK: - Initialization

    public init(styleXML: StyleXML, string: String) {
        self.styleXML = styleXML

        let xmlString = (styleXML.xmlParsingOptions.contains(.escapeString) ? string.escapeWithUnicodeEntities() : string)
        let xml = (styleXML.xmlParsingOptions.contains(.doNotWrapXML) ? xmlString : "<\(XMLStringBuilder.topTag)>\(xmlString)</\(XMLStringBuilder.topTag)>")
        guard let data = xml.data(using: String.Encoding.utf8) else {
            fatalError("Unable to convert to UTF8")
        }
        
        self.attributedString = NSMutableAttributedString()
        self.xmlParser = XMLParser(data: data)
        
        if let baseStyle = styleXML.baseStyle {
            self.xmlStylers.append( XMLDynamicStyle(tag: XMLStringBuilder.topTag, style: baseStyle) )
        }
        
        super.init()
        
        xmlParser.shouldProcessNamespaces = false
        xmlParser.shouldReportNamespacePrefixes = false
        xmlParser.shouldResolveExternalEntities = false
        xmlParser.delegate = self
    }
    
    /// Parse and generate attributed string.
    public func parse() throws -> AttributedString {
        guard xmlParser.parse() else {
            let line = xmlParser.lineNumber
            let shiftColumn = (line == 1 && options.contains(.doNotWrapXML) == false)
            let shiftSize = XMLStringBuilder.topTag.lengthOfBytes(using: String.Encoding.utf8) + 2
            let column = xmlParser.columnNumber - (shiftColumn ? shiftSize : 0)
            
            throw XMLStringBuilderError(parserError: xmlParser.parserError!, line: line, column: column)
        }
        
        return attributedString
    }
    
    // MARK: XMLParserDelegate
    
    @objc public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        foundNewString()
        enter(element: elementName, attributes: attributeDict)
    }
    
    @objc public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        foundNewString()
        guard elementName != XMLStringBuilder.topTag else {
            return
        }
        
        exit(element: elementName)
    }
    
    @objc public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentString = (currentString ?? "").appending(string)
    }
    
    // MARK: Support Private Methods
    
    func enter(element elementName: String, attributes: [String: String]) {
        guard elementName != XMLStringBuilder.topTag else {
            return
        }
        
        if elementName != XMLStringBuilder.topTag {
            xmlStylers.append( XMLDynamicStyle(tag: elementName, style: styles[elementName], xmlAttributes: attributes) )
        }
    }
    
    func exit(element elementName: String) {
        xmlStylers.removeLast()
    }
    
    func foundNewString() {
       /*guard let newString = currentString else {
            return // to support images tags
        }
       */
        var newAttributedString = AttributedString(string: currentString ?? "")
        for xmlStyle in xmlStylers {
            // Apply
            if let style = xmlStyle.style {
                // it's a know style
                newAttributedString = newAttributedString.add(style: style)
                // Also apply the xml attributes if needed
                if xmlStyle.xmlAttributes != nil {
                    xmlAttributesResolver.applyDynamicAttributes(to: &newAttributedString, xmlStyle: xmlStyle, fromStyle: styleXML)
                }
            } else {
                // it's an unknown tag, we can call the resolver for unknown tags
                xmlAttributesResolver.styleForUnknownXMLTag(xmlStyle.tag, to: &newAttributedString, attributes: xmlStyle.xmlAttributes, fromStyle: styleXML)
            }

        }
        attributedString.append(newAttributedString)
        currentString = nil
    }
    
}

// MARK: - XMLDynamicStyle

public class XMLDynamicStyle {
    
    // MARK: - Public Properties
    
    /// Tag read for this style.
    public let tag: String
    
    /// Style found in receiver `StyleXML` instance.
    public let style: StyleProtocol?
    
    /// Attributes found into the xml tag.
    public let xmlAttributes: [String: String]?
    
    // MARK: - Initialization
    
    internal init(tag: String, style: StyleProtocol?, xmlAttributes: [String: String]? = nil) {
        self.tag = tag
        self.style = style
        self.xmlAttributes = ((xmlAttributes?.keys.isEmpty ?? true) == false ? xmlAttributes : nil)
    }
    
    // MARK: - Public function
    
    /// Shortcut to enumarate attributes found in tags along with their respective values.
    ///
    /// - Parameter handler: handler function.
    public func enumerateAttributes(_ handler: ((_ key: String, _ value: String) -> Void)) {
        guard let xmlAttributes = xmlAttributes else {
            return
        }
        
        xmlAttributes.keys.forEach {
            handler($0, xmlAttributes[$0]!)
        }
    }
    
}
