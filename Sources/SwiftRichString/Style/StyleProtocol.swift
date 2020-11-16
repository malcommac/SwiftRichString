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

public typealias AttributedString = NSMutableAttributedString

public protocol StyleProtocol {
	
	/// Return the attributes of the style in form of dictionary `NSAttributedStringKey`/`Any`.
	var attributes: [NSAttributedString.Key : Any] { get }
	
	/// Font unique attributes dictionary.
	var fontStyle: FontStyle? { get }
    
    var textTransforms: [TextTransform]? { get }
	
	func set(to source: String, range: NSRange?) -> AttributedString
	
	func add(to source: AttributedString, range: NSRange?) -> AttributedString
	
	@discardableResult
	func set(to source: AttributedString, range: NSRange?) -> AttributedString
	
	@discardableResult
	func remove(from source: AttributedString, range: NSRange?) -> AttributedString
}

public extension StyleProtocol {
	
	func set(to source: String, range: NSRange?) -> AttributedString {
		let attributedText = NSMutableAttributedString(string: source)
		fontStyle?.addAttributes(to: attributedText, range: nil)
		attributedText.addAttributes(attributes, range: (range ?? NSMakeRange(0, attributedText.length)))
        return applyTextTransform(textTransforms, to: attributedText)
	}
	
	func add(to source: AttributedString, range: NSRange?) -> AttributedString {
		fontStyle?.addAttributes(to: source, range: range)
		source.addAttributes(attributes, range: (range ?? NSMakeRange(0, source.length)))
        return applyTextTransform(textTransforms, to: source)
	}
	
	@discardableResult
	func set(to source: AttributedString, range: NSRange?) -> AttributedString {
		fontStyle?.addAttributes(to: source, range: range)
		source.addAttributes(attributes, range: (range ?? NSMakeRange(0, source.length)))
        return applyTextTransform(textTransforms, to: source)
	}
	
	@discardableResult
	func remove(from source: AttributedString, range: NSRange?) -> AttributedString {
		attributes.keys.forEach({
			source.removeAttribute($0, range: (range ?? NSMakeRange(0, source.length)))
		})
        return applyTextTransform(textTransforms, to: source)
	}
    
    private func applyTextTransform(_ transforms: [TextTransform]?, to string: AttributedString) -> AttributedString {
        guard let transforms = textTransforms else {
            return string
        }
        
        let mutable = string.mutableStringCopy()
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
