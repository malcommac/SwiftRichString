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

public struct OrderedDictionary<K: Hashable, V> {
	var keys = [K]()
	var dict = [K:V]()
	
	public var count: Int {
		return self.keys.count
	}
	
	public subscript(key: K) -> V? {
		get {
			return self.dict[key]
		}
		set(newValue) {
			if newValue == nil {
				self.dict.removeValue(forKey:key)
				self.keys = self.keys.filter {$0 != key}
			} else {
				let oldValue = self.dict.updateValue(newValue!, forKey: key)
				if oldValue == nil {
					self.keys.append(key)
				}
			}
		}
	}
	
	public mutating func remove(key: K) -> V? {
		guard let idx = self.keys.index(of: key) else { return nil }
		self.keys.remove(at: idx)
		return self.dict.removeValue(forKey: key)
	}
}

extension OrderedDictionary: Sequence {
	public func makeIterator() -> AnyIterator<V> {
		var counter = 0
		return AnyIterator {
			guard counter<self.keys.count else {
				return nil
			}
			let next = self.dict[self.keys[counter]]
			counter += 1
			return next
		}
	}
}

extension OrderedDictionary: CustomStringConvertible {
	public var description: String {
		let isString = type(of: self.keys[0]) == String.self
		var result = "["
		for key in keys {
			result += isString ? "\"\(key)\"" : "\(key)"
			result += ": \(self[key]!), "
		}
		result = String(result.dropLast(2))
		result += "]"
		return result
	}
}

extension OrderedDictionary: ExpressibleByDictionaryLiteral {
	public init(dictionaryLiteral elements: (K, V)...) {
		self.init()
		for (key, value) in elements {
			self[key] = value
		}
	}
}
