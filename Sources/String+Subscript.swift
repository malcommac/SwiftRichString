//
//  String+Subscript.swift
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

// MARK: - String Search
public extension String {
	
}

// MARK: - Subrange Subscript
public extension String {
	
	/// Allows to get a single character at index.
	/// `String[1]`
	///
	/// - Parameter index: index of the character
	/// - Returns: `Character` instance at passed index, `nil` if range is out of bounds.
	public subscript(index: Int) -> Character? {
		guard !self.isEmpty, let stringIndex = self.index(startIndex, offsetBy: index, limitedBy: self.index(before: endIndex)) else { return nil }
		return self[stringIndex]
	}
	

	/// Allows to get a substring at specified range.
	/// `String[0..<1]`
	///
	/// - Parameter value: substring
	public subscript(range: Range<Int>) -> Substring? {
		guard let left = offset(by: range.lowerBound) else { return nil }
		guard let right = index(left, offsetBy: range.upperBound - range.lowerBound,
								limitedBy: endIndex) else { return nil }
		return self[left..<right]
	}
	
	/// Allows to get a substring for a specified closed partial subrange.
	/// `String[..<1]`
	///
	/// - Parameter value: substring
	public subscript(value: PartialRangeUpTo<Int>) -> Substring? {
		if value.upperBound < 0 {
			guard abs(value.upperBound) <= count else { return nil }
			return self[..<(count - abs(value.upperBound))]
		}
		guard let right = offset(by: value.upperBound) else { return nil }
		return self[..<right]
	}
	
	/// Allows to get a substring for a specified closed subrange.
	/// `String[...1]`
	///
	/// - Parameter range: closed subrange.
	public subscript(range: ClosedRange<Int>) -> Substring? {
		if range.upperBound < 0 {
			guard abs(range.lowerBound) <= count else { return nil }
			return self[(count - abs(range.lowerBound))...]
		}
		guard let left = offset(by: range.lowerBound) else { return nil }
		guard let right = index(left, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else { return nil }
		return self[left...right]
	}
	
	/// Allows to get a substring for a specified partial range.
	/// `String[1...]`
	///
	/// - Parameter value: substring
	public subscript(value: PartialRangeFrom<Int>) -> Substring? {
		guard let left = self.offset(by: value.lowerBound) else { return nil }
		return self[left...]
	}
	
	internal func offset(by distance: Int) -> String.Index? {
		return index(startIndex, offsetBy: distance, limitedBy: endIndex)
	}
}

public extension Substring {
	
	/// Convert a `Substring` to a valid `String`
	var string: String {
		return String(self)
	}
}
