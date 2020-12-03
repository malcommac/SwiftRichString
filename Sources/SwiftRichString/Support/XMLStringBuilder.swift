//
//  SwiftRichString
//  https://github.com/malcommac/SwiftRichString
//  Copyright (c) 2020 Daniele Margutti (hello@danielemargutti.com).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

#if canImport(CHTMLSAXParser)
import CHTMLSAXParser
#endif

public enum RichStringError: LocalizedError {
    case xmlError(String)
}

// MARK: - XMLParsingOptions

public struct XMLParsingOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Perform string escaping to replace all characters which is not supported by NSXMLParser
    /// into the specified encoding with decimal entity.
    /// For example if your string contains '&' character parser will break the style.
    /// This option is active by default.
    public static let escapeString = XMLParsingOptions(rawValue: 2)
    
}

internal class XMLStringBuilder {
    
    // MARK: - Public Properties
    
    public private(set) var xmlWarnings = [(context: HTMLSAXParseContext, message: String)]()
    
    // MARK: - Private Properties

    private static let topTag = "source"

    private var styleXML: StyleXML!
    private var xmlParser = HTMLSAXParser()
    private var attributedString = NSMutableAttributedString()
    private var sourceString: String
    
    private var tags = [XMLDynamicStyle]()
    
    private var currentString: String = ""
    
    private var xmlAttributesResolver: XMLDynamicAttributesResolver {
        return styleXML.xmlAttributesResolver
    }
        
    private var styles: [String: StyleProtocol] {
        return styleXML.styles
    }
    
    // MARK: - Initialization

    public init(styleXML: StyleXML, string: String) {
        self.styleXML = styleXML
        
        let xmlString = (styleXML.xmlParsingOptions.contains(.escapeString) ? string.escapeWithUnicodeEntities() : string)
        self.sourceString = xmlString
    }
    
    // MARK: - Public Functions
    
    public func parse() throws -> AttributedString {
        do {
            try xmlParser.parse(string: sourceString, handler: xmlEventHandler)
            return attributedString
        } catch {
            throw RichStringError.xmlError(error.localizedDescription)
        }
    }
    
    // MARK: - Private Functions
    
    private func xmlEventHandler(_ context: HTMLSAXParseContext, _ event: HTMLSAXParser.Event) {
        switch event {
        case .startElement(let name, let attributes):
            didStartNewElementWithName(name, attributes: attributes)
        case .endElement(let name):
            didEndElementWithName(name)
        case .characters(let text):
            currentString += text
        case .warning(let message):
            xmlWarnings.append((context, message))
        case .error(let message):
            xmlWarnings.append((context, message))
        default:
            break
        }
    }
    
    private func didStartNewElementWithName(_ name: String, attributes: [String: String]) {
        guard name != XMLStringBuilder.topTag else {
            return
        }
        
        addNewTextFragment()

        // print("didStart [\(name)]")
        let tag = XMLDynamicStyle(tag: name, style: styles[name], xmlAttributes: attributes)
        tags.append(tag)
    }
    
    private func didEndElementWithName(_ name: String) {
        addNewTextFragment()
        tags = tags.dropLast()
    }
    
    private func addNewTextFragment() {
        var attributedFragment = AttributedString(string: currentString)
        tags.forEach { tag in
            guard let style = tag.style else {
                // tag is not part of the set you have passed to the function so we want to
                // fallback to the unknown xmltag function.
                xmlAttributesResolver.styleForUnknownXMLTag(tag.tag, to: &attributedFragment, attributes: tag.xmlAttributes, fromStyle: styleXML)
                return
            }
            
            _ = attributedFragment.add(style: style)
            // Also apply the xml attributes if needed
            if tag.xmlAttributes != nil {
                xmlAttributesResolver.applyDynamicAttributes(to: &attributedFragment, xmlStyle: tag, fromStyle: styleXML)
            }
        }
        
        attributedString.append(attributedFragment)
        currentString.removeAll()
    }
    
}

// MARK: - XMLDynamicStyle

public struct XMLDynamicStyle {
    
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
