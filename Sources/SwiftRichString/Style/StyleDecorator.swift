//
//  File.swift
//  
//
//  Created by daniele on 17/11/20.
//

import Foundation

public protocol StylableString {
    
    func attributedString(_ attributes: [NSAttributedString.Key: Any]?) -> AttributedString
    
}

extension String: StylableString {
    
    public func attributedString(_ attributes: [NSAttributedString.Key : Any]? = nil) -> AttributedString {
        AttributedString(string: self, attributes: attributes)
    }
    
}

extension AttributedString: StylableString {
    
    public func attributedString(_ attributes: [NSAttributedString.Key : Any]? = nil) -> AttributedString {
        if let attributes = attributes {
            self.addAttributes(attributes, range: NSMakeRange(0, length))
        }
        return self
    }
    
}

internal enum StyleDecorator {
    
    static func set(regexStyle style: StyleRegEx, to str: StylableString, add: Bool, range: NSRange?) -> AttributedString {
        let attributedSource = str.attributedString(style.baseStyle?.attributes)
        let rangeValue = (range ?? NSMakeRange(0, attributedSource.length))
        
        let matchOpts = NSRegularExpression.MatchingOptions(rawValue: 0)
        style.regex.enumerateMatches(in: attributedSource.string, options: matchOpts, range: rangeValue) {
            (result : NSTextCheckingResult?, _, _) in
            if let r = result {
                if add {
                    attributedSource.addAttributes(style.attributes, range: r.range)
                } else {
                    attributedSource.setAttributes(style.attributes, range: r.range)
                }
            }
        }
        
        return attributedSource
    }
    
    static func set(style: StyleProtocol?, to source: StylableString, range: NSRange?) -> AttributedString {
        let attributedSource = source.attributedString(nil)
        guard let style = style else { return attributedSource }

        style.fontStyle?.addAttributes(to: attributedSource, range: nil)
        attributedSource.addAttributes(style.attributes, range: (range ?? NSMakeRange(0, attributedSource.length)))
        return StyleDecorator.applyTextTransform(style.textTransforms, to: attributedSource)
    }
    
    static func add(style: StyleProtocol?, to source: StylableString, range: NSRange?) -> AttributedString {
        let attributedSource = source.attributedString(nil)
        guard let style = style else { return attributedSource }

        style.fontStyle?.addAttributes(to: attributedSource, range: range)
        attributedSource.addAttributes(style.attributes, range: (range ?? NSMakeRange(0, attributedSource.length)))
        return StyleDecorator.applyTextTransform(style.textTransforms, to: attributedSource)
    }
    
    @discardableResult
    static func remove(style: StyleProtocol?, from source: StylableString, range: NSRange?) -> AttributedString {
        /*let attributedSource = source.attributedString(nil)
        guard let style = style else { return attributedSource }

        style.attributes.keys.forEach({
            attributedSource.removeAttribute($0, range: (range ?? NSMakeRange(0, attributedSource.length)))
        })*/
        
        let allKeys = (style?.attributes.keys != nil ? Array(style!.attributes.keys) : nil)
        let attributedSource = StyleDecorator.remove(attributes: allKeys, from: source, range: range)
        return StyleDecorator.applyTextTransform(style?.textTransforms, to: attributedSource)
    }
    
    @discardableResult
    static func remove(attributes keys: [NSAttributedString.Key]?, from source: StylableString, range: NSRange?) -> AttributedString {
        let attributedSource = source.attributedString(nil)
        keys?.forEach({
            attributedSource.removeAttribute($0, range: (range ?? NSMakeRange(0, attributedSource.length)))
        })
        return attributedSource
    }
    
    static func applyTextTransform(_ transforms: [TextTransform]?, to source: AttributedString) -> AttributedString {
        guard let transforms = transforms else {
            return source
        }
        
        let mutable = source.mutableStringCopy()
        let fullRange = NSRange(location: 0, length: mutable.length)
        mutable.enumerateAttributes(in: fullRange, options: [], using: { (_, range, _) in
            var substring = mutable.attributedSubstring(from: range).string
            transforms.forEach {
                substring = $0.transformer(substring)
            }
            mutable.replaceCharacters(in: range, with: substring)
        })
        
        return mutable
    }
    
}
