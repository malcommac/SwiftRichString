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

#if os(OSX)
#if swift(>=4.2)
#else
public typealias NSLineBreakMode = NSParagraphStyle.LineBreakMode
#endif
#endif

// Helper function inserted by Swift 4.2 migrator.
func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}


#if swift(>=4.2)
#else
extension NSAttributedString {
	public typealias Key = NSAttributedStringKey
}
#endif

#if os(iOS) || os(tvOS) || os(watchOS)

extension NSAttributedString.Key {
	#if swift(>=4.2)
	#else
	static let accessibilitySpeechPunctuation = NSAttributedString.Key(UIAccessibilitySpeechAttributePunctuation)
	static let accessibilitySpeechLanguage = NSAttributedString.Key(UIAccessibilitySpeechAttributeLanguage)
	static let accessibilitySpeechPitch = NSAttributedString.Key(UIAccessibilitySpeechAttributePitch)
	
	@available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)
	static let accessibilitySpeechIPANotation = NSAttributedString.Key(UIAccessibilitySpeechAttributeIPANotation)
	
	@available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)
	static let accessibilitySpeechQueueAnnouncement = NSAttributedString.Key(UIAccessibilitySpeechAttributeQueueAnnouncement)
	
	@available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)
	static let accessibilityTextHeadingLevel = NSAttributedString.Key(UIAccessibilityTextAttributeHeadingLevel)
	#endif
}

#endif
