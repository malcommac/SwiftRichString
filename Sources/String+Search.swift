//
//  String+Search.swift
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

public extension String {
	
	
	/// Search for all occurrences of passed string and return an array of ranges.
	/// Example: `String["search_string"]`
	///
	/// - Parameter string: string to search
	public subscript(string: String) -> [Range<String.Index>] {
		var foundOccurences = [Range<String.Index>]()
		var currentStartIdx = startIndex
		while currentStartIdx < endIndex {
			guard let range = self.range(of: string,
										 options: [],
										 range: currentStartIdx..<endIndex, locale: nil)
				else { break }
			foundOccurences.append(range)
			currentStartIdx = range.upperBound
		}
		return foundOccurences
	}
	
	/// Search all occurrences of text into the receiver enclosed between given
	/// range of strings and return it.
	/// Example: `String["begin"..."end"]`
	///
	/// - Parameter range: left and right search text.
	public subscript(range: ClosedRange<String>) -> [ClosedRange<String.Index>] {
		var foundOccurences = [ClosedRange<String.Index>]()
		var currentStartIdx = startIndex
		while currentStartIdx < endIndex {
			guard let beginRange = self.range(of: range.lowerBound, options: [], range: currentStartIdx..<endIndex, locale: nil) else { break }
			guard let endRange = self.range(of: range.upperBound, options: [], range: beginRange.upperBound..<endIndex, locale: nil) else { break }
			foundOccurences.append(beginRange.lowerBound...endRange.upperBound)
			currentStartIdx = endRange.upperBound
		}
		return foundOccurences
	}
	
	
	/// Search all occurrences of text into the receiver enclosed between given
	/// range of strings and return it minus the end range.
	/// Example: `String["begin"..<"end"]`
	///
	/// - Parameter range: left and right search text.
	public subscript(range: Range<String>) -> [Range<String.Index>] {
		var foundOccurences = [Range<String.Index>]()
		var currentStartIdx = startIndex
		while currentStartIdx < endIndex {
			guard let beginRange = self.range(of: range.lowerBound, options: [], range: currentStartIdx..<endIndex, locale: nil) else { break }
			guard let endRange = self.range(of: range.upperBound, options: [], range: beginRange.upperBound..<endIndex, locale: nil) else { break }
			foundOccurences.append(beginRange.upperBound..<endRange.lowerBound)
			currentStartIdx = endRange.upperBound
		}
		return foundOccurences
	}
	
	/// Search for first occurence inside the receiver of string
	/// which starts with left range and return the substring starting from it until the end of receiver.
	/// (left range included).
	/// Example: `String["begin"...]`
	///
	/// - Parameter range: range
	public subscript(range: PartialRangeFrom<String>) -> PartialRangeFrom<String.Index>? {
		guard self.offset(by: range.lowerBound.count) != nil else { return nil }
		guard let beginRange = self.range(of: range.lowerBound, options: [], range: startIndex..<endIndex, locale: nil) else { return nil }
		return beginRange.upperBound...
	}
	
	/// Search for first occurrence inside the receiver of string which ends with right side of
	/// passed partial range and return the substring from start of the receiver until occurrence
	/// (excluded).
	/// Example: `String[..."end"]`
	///
	/// - Parameter range: range
	public subscript(range: PartialRangeThrough<String>) -> PartialRangeThrough<String.Index>? {
		guard self.offset(by: range.upperBound.count) != nil else { return nil }
		guard let endRange = self.range(of: range.upperBound, options: [], range: startIndex..<endIndex, locale: nil) else { return nil }
		return ...endRange.lowerBound
	}
	
}
