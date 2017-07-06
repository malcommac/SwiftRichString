//
//  StringScanner.swift
//  SwiftRichString
//  Elegant & Painless Attributed Strings Management Library in Swift
//
//  Created by Daniele Margutti.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
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
#if os(iOS) || os(tvOS) || os(watchOS)
	import UIKit
#elseif os(OSX)
	import AppKit
#endif

/// Throwable errors of the scanner
///
/// - eof: end of file is reached
/// - invalidInput: invalid input passed to caller function
/// - notFound: failed to match or search value into the scanner's source string
/// - invalidInt: invalid int found, not the expected format
/// - invalidFloat: invalid float found, not the expected format
/// - invalidHEX: invalid HEX found, not the expected format
public enum StringScannerError: Error {
	case eof
	case notFound
	case invalidInput
	case invalidInt
	case invalidFloat
	case invalidHEX
}

/// Bit digits representation for HEX values
public enum BitDigits: Int {
	case bit8	= 8
	case bit16	= 16
	case bit32	= 32
	case bit64	= 64
	
	var length: Int {
		switch self {
		case .bit8:		return 2
		case .bit16:	return 4
		case .bit32:	return 8
		case .bit64:	return 16
		}
	}
}

public class StringScanner {
	
	public typealias SIndex = String.UnicodeScalarView.Index
	public typealias SString = String.UnicodeScalarView
	
	//---------------
	//MARK: Variables
	//---------------
	
	/// Thats the current data of the scanner.
	/// Internally it's represented by `String.UnicodeScalarView`
	public fileprivate(set) var string: SString
	
	/// Current scanner's index position
	public fileprivate(set) var position: SIndex
	
	/// Get the first index of the source string
	public var startIndex: SIndex {
		return self.string.startIndex
	}
	
	/// Get the last index of the source string
	public var endIndex: SIndex {
		return self.string.endIndex
	}
	
	/// Number of scalars consumed up to `position`
	/// Since String.UnicodeScalarView.Index is not a RandomAccessIndex,
	/// this makes determining the position *much* easier)
	public fileprivate(set) var consumed: Int
	
	/// Return true if scanner reached the end of the string
	public var isAtEnd: Bool {
		return (self.position == string.endIndex)
	}
	
	/// Returns the content of scanner's string from current value of the position till the end
	/// `position` its not updated by the operation.
	///
	/// - Returns: remainder string till the end of source's data
	public var remainder: String {
		var remString: String = ""
		var idx = self.position
		while idx != self.string.endIndex {
			remString.unicodeScalars.append(self.string[idx])
			idx = self.string.index(after:idx)
		}
		return remString
	}
	
	//-----------------
	//MARK: Init
	//-----------------
	
	/// Initialize a new scanner instance from given source string
	///
	/// - Parameter string: source string
	public init(_ string: String) {
		self.string = string.unicodeScalars
		self.position = self.string.startIndex
		self.consumed = 0
	}
	
	//-----------------
	//MARK: Scan Values
	//-----------------
	
	/// If the current scanner position is not at eof return the next scalar at position and move `position` to the next index
	/// Otherwise it throws with .eof and `position` is not updated.
	///
	/// - Returns: the next scalar
	/// - Throws: throw .eof if reached
	@discardableResult
	public func scanChar() throws -> UnicodeScalar {
		guard self.position != self.string.endIndex else {
			throw StringScannerError.eof
		}
		let char = self.string[self.position]
		self.position = self.string.index(after: self.position)
		self.consumed += 1
		return char
	}
	
	/// Scan the next integer value after the current scalar position; consume scalars from {0..9} until a non numeric
	/// value is encountered. Return the integer representation in base 10.
	/// `position` index is advanced to the end of the number.
	/// Throws .invalidInt if scalar at the current `position` is not in the range `"0"` to `"9"`
	///
	/// - Returns: read integer in base 10
	/// - Throws: throw .invalidInt if non numeric value is encountered
	public func scanInt() throws -> Int {
		var parsedInt = 0
		try self.session(peek: true, accumulate: false, block: { i,c in
			while i != self.string.endIndex && self.string[i] >= "0" && self.string[i] <= "9" {
				parsedInt = parsedInt * 10 + Int(self.string[i].value - UnicodeScalar("0").value )
				i = self.string.index(after: i)
				c += 1
			}
			if i == self.position {
				throw StringScannerError.invalidInt
			}
			// okay valid, store changes to index
			self.position = i
			self.consumed = c
		})
		return parsedInt
	}
	
	/// Scan for float value (xx.xx) and convert it into Float.
	/// Return the float representation in base 10.
	/// `position` index is advanced to the end of the number only if conversion works, otherwise it will be not updated and
	/// .invalidFloat is thrown.
	///
	/// - Returns: parsed float value
	/// - Throws: throw an exception .invalidFloat or .eof according to the error
	public func scanFloat() throws -> Float {
		let prevConsumed = self.consumed
		
		func throwAndBackBy(length: Int) {
			self.position = self.string.index(self.position, offsetBy: -length)
			self.consumed -= length
		}
		
		guard let strValue = try self.scan(untilIn: CharacterSet(charactersIn: "-+0123456789.")) else {
			throw StringScannerError.invalidFloat
		}
		guard let value = Float(strValue) else {
			throw StringScannerError.invalidFloat
		}
		return value
	}
	
	/// Scan an HEX digit expressed as 0x/0X<number> or #<number> where number is the value expressed with according bit number
	/// If scan succeded it return parsed value and `position` is updated at the end of the value.
	/// If scan fail function throws and no values are updated
	///
	/// - Parameter digits: type of digits to parse (8,16,32 or 64 bits)
	/// - Returns: the int value in base 10 converted from HEX base
	/// - Throws: throw .hexExpected if value is not expressed in HEX string according to specified digits
	public func scanHexInt(_ digits: BitDigits = .bit16) throws -> Int {

		func parseHexInt(_ digits: BitDigits, _ consumed: inout Int) throws -> Int {
			let strValue = try self.scan(length: digits.length)
			consumed += digits.length
			guard let parsedInt = Int(strValue, radix: 16) else {
				throw StringScannerError.invalidHEX
			}
			return parsedInt
		}
		
		var value: Int = 0
		var consumed: Int = 0
		if self.string[self.position] == "#" { // the format start with #, numbers is following
			try self.move(1, accumulate: false)
			consumed += 1 // move on to digits and parse them
			value = try parseHexInt(digits, &consumed)
		} else {
			do {
				let prefix = try self.scan(length: 2).uppercased()
				consumed += 2
				guard prefix == "0X" else { // hex is in 0x or 0X format followed by values
					throw StringScannerError.invalidHEX
				}
				value = try parseHexInt(digits, &consumed)
			} catch {
				// something went wrong and value cannot be parsed,
				// go back with the `position` index and throw an errro
				try! self.back(length: consumed)
				throw StringScannerError.invalidHEX
			}
		}
		return value
	}
	
	/// Scan until given character is found starting from current scanner `position` till the end of the source string.
	/// Scanner's `position` is updated only if character is found and set just before it.
	/// Throw an exception if .eof is reached or .notFound if char was not found (in this case scanner's position is not updated)
	///
	/// - Parameter char: scalar to search
	/// - Returns: the string until the character (excluded)
	/// - Throws: throw an exception on .eof or .notFound
	public func scan(upTo char: UnicodeScalar) throws -> String? {
		return try self.move(peek: false, upTo: char).string
	}
	
	/// Scan until given character's is found.
	/// Index is reported before the start of the sequence, scanner's `position` is updated only if sequence is found.
	/// Throw an exception if .eof is reached or .notFound if sequence was not found
	///
	/// - Parameter charSet: character set to search
	/// - Returns: found index
	/// - Throws: throw .eof or .notFound
	public func scan(upTo charSet: CharacterSet) throws -> String? {
		return try self.move(peek: false, accumulate: true, upToCharSet: charSet).string
	}
	
	/// Scan until the next character of the scanner is contained into given character set
	/// Scanner's position is updated automatically at the end of the sequence if validated, otherwise it will not touched.
	///
	/// - Parameter charSet: chracters set
	/// - Returns: the string accumulated scanning until chars set is evaluated
	/// - Throws: throw .eof or .notFound
	public func scan(untilIn charSet: CharacterSet) throws -> String? {
		return try self.move(peek: false, accumulate: true, untilIn: charSet).string
	}
	
	/// Scan until specified string is encountered and update indexes if found
	/// Throw an exception if .eof is reached or string is not found
	///
	/// - Parameter string: string to search
	/// - Returns: string up to search string (excluded)
	/// - Throws: throw .eof or .notFound
	@discardableResult
	public func scan(upTo string: String) throws -> String? {
		return try self.move(peek: false, upTo: string).string
	}
	
	///  Scan and consume at the scalar starting from current position, testing it with function test.
	///  If test returns `true`, the `position` increased. If `false`, the function returns.
	///
	/// - Parameter test: test to pass
	/// - Returns: accumulated string
	@discardableResult
	public func scan(untilTrue test: ((UnicodeScalar) -> (Bool)) ) -> String {
		return self.move(peek: false, accumulate: true, untilTrue: test).string!
	}
	
	/// Read next length characters and accumulate it
	/// If operation is succeded scanner's `position` are updated according to consumed scalars.
	/// If fails an exception is thrown and `position` is not updated
	///
	/// - Parameter length: number of scalar to ad
	/// - Returns: captured string
	/// - Throws: throw an .eof exception
	@discardableResult
	public func scan(length: Int = 1) throws -> String {
		return try self.move(length, accumulate: true).string!
	}
	
	//-----------------
	//MARK: Peek Values
	//-----------------
	
	/// Peek until chracter is found starting from current scanner's `position`.
	/// Scanner's position is never updated.
	/// Throw an exception if .eof is reached or .notFound if char was not found.
	///
	/// - Parameter char: scalar to search
	/// - Returns: the index found
	/// - Throws: throw an exception on .eof or .notFound
	public func peek(upTo char: UnicodeScalar) throws -> SIndex {
		return try self.move(peek: true, upTo: char).index
	}
	
	/// Peek until one the characters specified by set is encountered
	/// Index is reported before the start of the sequence, but scanner's `position` is never updated.
	/// Throw an exception if .eof is reached or .notFound if sequence was not found
	///
	/// - Parameter charSet: scalar set to search
	/// - Returns: found index
	/// - Throws: throw .eof or .notFound
	public func peek(upTo charSet: CharacterSet) throws -> SIndex {
		return try self.move(peek: true, accumulate: false, upToCharSet: charSet).index
	}
	
	/// Peek until the next character of the scanner is contained into given.
	/// Scanner's `position` is never updated.
	///
	/// - Parameter charSet: characters set to evaluate
	/// - Returns: the index at the end of the sequence
	/// - Throws: throw .eof or .notFound
	public func peek(untilIn charSet: CharacterSet) throws -> SIndex {
		let (endIndex,_) = try self.move(peek: true, accumulate: false, untilIn: charSet)
		return endIndex
	}
	
	/// Iterate until specified string is encountered without updating indexes.
	/// Scanner's `position` is never updated but it's reported the index just before found occourence.
	///
	/// - Parameter string: string to search
	/// - Returns: index where found string was found
	/// - Throws: throw .eof or .notFound
	public func peek(upTo string: String) throws -> SIndex {
		return try self.move(peek: true, upTo: string).index
	}
	
	///  Peeks at the scalar at the current position, testing it with function test.
	///  It only peeks so current scanner's `position` is not increased at the end of the operation
	///
	/// - Parameter test: test to pass
	public func peek(untilTrue test: ((UnicodeScalar) -> (Bool)) ) -> SIndex {
		return self.move(peek: true, accumulate: false, untilTrue: test).index
	}
	
	//-----------
	//MARK: Match
	//-----------
	
	/// Throw if the scalar at the current position don't match given scalar.
	/// Advance scanner's `position` to the end of the match.
	///
	/// - Parameter char: scalar to match
	/// - Throws: throw if does not match or index reaches eof
	@discardableResult
	public func match(_ char: UnicodeScalar) -> Bool {
		guard self.position != self.string.endIndex else {
			return false
		}
		if self.string[self.position] != char {
			return false
		}
		// Advance by one scalar, the one we matched
		self.position = self.string.index(after: self.position)
		self.consumed += 1
		return true
	}
	
	/// Throw if scalars starting at the current position don't match scalars in given string.
	/// Advance scanner's `position` to the end of the match string.
	///
	/// - Parameter string: string to match
	/// - Throws: throw if does not match or index reaches eof
	public func match(_ match: String) -> Bool {
		var result: Bool = true
		try! self.session(peek: false, accumulate: false, block: { i,c in
			for char in match.unicodeScalars {
				if i == self.string.endIndex {
					result = false
					break
				}
				if self.string[i] != char {
					result = false
					break
				}
				i = self.string.index(after: i)
				c += 1
			}
		})
		return result
	}
	
	//------------
	//MARK: Others
	//------------
	
	/// Move scanner's `position` to the start of the string
	public func reset() {
		self.position = self.string.startIndex
		self.consumed = 0
	}
	
	/// Move to the index's end index
	public func peekAtEnd() {
		self.position = self.string.endIndex
		let distance = self.string.distance(from: self.string.startIndex, to: self.position)
		self.consumed = distance
	}
	
	/// Attempt to advance scanner's  by length
	/// If operation is not possible (reached the end of the string) it throws and current scanner's `position` of the index did not change
	/// If operation succeded scanner's `position` is updated.
	///
	/// - Parameter length: length to advance
	/// - Throws: throw if .eof
	public func skip(length: Int = 1) throws {
		try self.move(length, accumulate: false)
	}

	/// Attempt to advance the position back by length
	/// If operation fails scanner's `position` is not touched
	/// If operation succeded scaner's`position` is modified according to new value
	///
	/// - Parameter length: length to move
	/// - Throws: throw if .eof
	public func back(length: Int = 1) throws {
		guard length <= self.consumed else { // more than we can go back
			throw StringScannerError.invalidInput
		}
		if length == 1 {
			self.position = self.string.index(self.position, offsetBy: -1)
			self.consumed -= 1
			return
		}
		
		var l = length
		while l > 0 {
			self.position = self.string.index(self.position, offsetBy: -1)
			self.consumed -= 1
			l -= 1
		}
	}
	
	//--------------------
	//MARK: Private Funcs
	//--------------------
	
	@discardableResult
	private func move(_ length: Int = 1, accumulate: Bool) throws -> (index: SIndex, string: String?) {
		
		if length == 1 && self.position != self.string.endIndex {
			// Special case if proposed length is a single character
			self.position = self.string.index(after: self.position)
			self.consumed += 1
			return (self.position, String(self.string[self.string.index(before: self.position)]))
		}
		
		// Use temporary indexes and don't touch the real ones until we are
		// sure the operation succeded
		var proposedIdx = self.position
		var initialPosition = self.position
		var proposedConsumed = 0
		
		var remaining = length
		while remaining > 0 {
			if proposedIdx == self.string.endIndex {
				throw StringScannerError.eof
			}
			proposedIdx = self.string.index(after: proposedIdx)
			proposedConsumed += 1
			remaining -= 1
		}
		
		var result: String? = nil
		if accumulate == true { // if user need accumulate string we want to provide it
			result = ""
			result!.reserveCapacity( (proposedConsumed - self.consumed) ) // just an optimization
			while initialPosition != proposedIdx {
				result!.unicodeScalars.append(self.string[initialPosition])
				initialPosition = self.string.index(after: initialPosition)
			}
		}
		// Write changes only if skip operation succeded
		self.position = proposedIdx
		self.consumed = proposedConsumed
		return (self.position,result)
	}
	
	
	/// Move the index until scalar at given index is part of passed char set, then return the index til it and accumulated string (if requested)
	///
	/// - Parameters:
	///   - peek: peek to perform a non destructive operation to scanner's `position`
	///   - accumulate: accumulate return a valid string in output sum of the scan operation
	///   - charSet: character set target of the operation
	/// - Returns: index and content of the string
	/// - Throws: throw .notFound if string is not found or .eof if end of file is reached
	private func move(peek: Bool, accumulate: Bool, untilIn charSet: CharacterSet) throws -> (index: SIndex, string: String?) {
		if charSet.contains(self.string[self.position]) == false { // ops
			throw StringScannerError.notFound
		}
		
		return try self.session(peek: peek, accumulate: accumulate, block: { i,c in
			while i != self.string.endIndex && charSet.contains(self.string[i]) {
				i = self.string.index(after: i)
				c += 1
			}
		})
	}
	
	
	/// Move up to passed scalar is found
	///
	/// - Parameters:
	///   - peek: peek to perform a non destructive operation to scanner's `position`
	///   - char: given scalar to search
	/// - Returns: index til found character and accumulated string
	/// - Throws: throw .notFound or .eof
	@discardableResult
	private func move(peek: Bool, upTo char: UnicodeScalar) throws -> (index: SIndex, string: String?) {
		return try self.session(peek: peek, accumulate: true, block: { i,c in
			// continue moving forward until we reach the end of scanner's string
			// or current character at scanner's string current position differs from we are searching for
			while i != self.string.endIndex && self.string[i] != char {
				i = self.string.index(after: i)
				c += 1
			}
		})
	}
	
	/// Move next scalar until a character specified in character set is found and return the index and accumulated string (if requested)
	///
	/// - Parameters:
	///   - peek: peek to perform a non destructive operation to scanner's `position`
	///   - accumulate: true to get accumulated string til found index
	///   - charSet: character set target of the operation
	/// - Returns: index and accumulated string
	/// - Throws: throw .eof or .notFound
	@discardableResult
	private func move(peek: Bool, accumulate: Bool, upToCharSet charSet: CharacterSet) throws -> (index: SIndex, string: String?) {
		return try self.session(peek: peek, accumulate: accumulate, block: { i,c in
			// continue moving forward until we reach the end of scanner's string
			// or current character at scanner's string current position differs from we are searching for
			while i != self.string.endIndex && charSet.contains(self.string[i]) == false {
				i = self.string.index(after: i)
				c += 1
			}
		})
	}

	/// Move next scalar until specified test for current scalar return true, then get the index and accumulated string
	///
	/// - Parameters:
	///   - peek: peek to perform a non destructive operation to scanner's `position`
	///   - accumulate: true to get accumulated string until test return true
	///   - test: test
	/// - Returns: throw .eof or .notFound
	@discardableResult
	private func move(peek: Bool, accumulate: Bool, untilTrue test: ((UnicodeScalar) -> (Bool)) ) -> (index: SIndex, string: String?) {
		return try! self.session(peek: peek, accumulate: accumulate, block: { i,c in
			while i != self.string.endIndex {
				if test(self.string[i]) == false { // test is not passed, we return
					return
				}
				i = self.string.index(after: i)
				c += 1
			}
		})
	}
	
	
	/// Move next scalar until specified string is found, then get the index and accumulated string
	///
	/// - Parameters:
	///   - peek: peek to perform a non destructive operation to scanner's `position`
	///   - string: string to search
	/// - Returns: index and string
	/// - Throws: throw .eof or .notFound
	@discardableResult
	private func move(peek: Bool, upTo string: String) throws -> (index: SIndex, string: String?) {
		let search = string.unicodeScalars
		guard let firstSearchChar = search.first else { // Invalid search string
			throw StringScannerError.invalidInput
		}
		if search.count == 1 { // If we are searching for a single char we want to forward call to the specific func
			return try self.move(peek: peek, upTo: firstSearchChar)
		}
		
		return try self.session(peek: peek, accumulate: true, block: { i,c in
			
			let remainderSearch = search[search.index(after: search.startIndex)..<search.endIndex]
			let endStringIndex = self.string.endIndex
			
			// Candidates allows us to store the position of index for any candidate string
			// A candidate session happens when we found the first char of search string (firstSearchChar)
			// into our scanner string.
			// We will use these indexes to switch back position of the scanner if the entire searchString will found
			// in order to exclude searchString itself from resulting string/indexes
			var candidateStartIndex = i
			var candidateConsumed = c
			
			mainLoop : while i != endStringIndex {
				// Iterate all over the strings searching for first occourence of the first char of the string to search
				while self.string[i] != firstSearchChar {
					i = self.string.index(after: i) // move to the next item
					c += 1 // increment consumed chars
					if i == endStringIndex { // we have reached the end of the scanner's string
						throw StringScannerError.eof
					}
				}
				// Okay we have found first char of our search string into our data
				
				// First of all we store in proposedIndex and proposedConsumed the position were we have found
				// this candidate. If validated we adjust back the indexes in of c,i in order to exclude found string itself
				candidateStartIndex = i
				candidateConsumed = c
				
				// We need to validate the remaining characters and see if are the same
				i = self.string.index(after: i) // scan from second character of the search string
				c += 1 // (clearly also increments consumed chars)
				
				// now we want to compare the reamining chars of the search (remainderSearch) with the
				// next chars of our current position in scanner's string
				for searchCChar in remainderSearch {
					if i == endStringIndex { // we have reached the end of the scanner's string
						throw StringScannerError.eof
					}
					if self.string[i] != searchCChar {
						continue mainLoop
					}
					// Go the next char
					i = self.string.index(after: i)
					c += 1
				}
				// Wow the string is that!
				// Adjust back the indexes
				i = candidateStartIndex
				c = candidateConsumed
				break
			}
		})
	}
	
	
	/// Initiate a scan or peek session. This func allows you to keep changes in index and consumed
	/// chars; moreover it returns the string accumulated during the move session.
	///
	/// - Parameters:
	///   - peek: if true it will update both consumed and position indexes of the scanner at the end with sPosition and sConsumed values
	///	  - accumulate: true to return the string from initial position till the end of reached index
	///   - block: block with the operation to execute
	/// - Returns: return the new proposed position for scanner's index and accumulated string
	/// - Throws: throw if block throws
	@discardableResult
	private func session(peek: Bool, accumulate: Bool = true,
	                     block: (_ sPosition: inout SIndex, _ sConsumed: inout Int) throws -> (Void) )
		throws -> (index: SIndex, string: String?) {
		// Keep in track with status of the position and consumed indexes before anything change
		var initialPosition = self.position
		let initialConsumed = self.consumed
		
		var sessionPosition = self.position
		var sessionConsumed = 0
		
		// execute the real code into block
		try block(&sessionPosition,&sessionConsumed)
		
		if sessionConsumed == 0 {
			return (sessionPosition,nil)
		}
			
		var result: String? = nil
		if accumulate == true {
			result = ""
			result!.reserveCapacity( (sessionConsumed - initialConsumed) ) // just an optimization
			while initialPosition != sessionPosition {
				result!.unicodeScalars.append(self.string[initialPosition])
				initialPosition = self.string.index(after: initialPosition)
			}
		}
			
		if peek == false { // Write changes to the main scanner's indexes
			self.position = sessionPosition
			self.consumed += sessionConsumed
		}
		return (sessionPosition,result)
	}
	
}
