//
//  URLConvertible.swift
//  SwiftRichString
//
//  Created by dan on 19/01/2019.
//  Copyright © 2019 SwiftRichString. All rights reserved.
//

import Foundation

/// Dynamic tag support protocol
public protocol DynamicTagComposable {
	func dynamicValueFromTag(_ tag: StyleGroup.TagAttribute?) -> Any?
}

/// Dynamic value for NSAttributedKey.Link and .linkURL attribute.
/// If link is wrong and cannot be transformed to `URL` instance style's `link` is not applied.
///
/// - url: fixed url value specified by URL instance.
/// - string: fixed url string specified by a simple string.
/// - tagAttribute: value of a specified tag in source html-tagged style.
public enum URLRepresentable: DynamicTagComposable {
	case url(URL)
	case string(String)
	case tagAttribute(String)

	public func dynamicValueFromTag(_ tag: StyleGroup.TagAttribute?) -> Any? {
		switch self {
		case .url(let url):
			return url
		case .string(let string):
			return URL(string: string)
		case .tagAttribute(let tagKey):
			guard let value = tag?.parameters?[tagKey] else {
				return nil
			}
			return URL(string: value)
		}
	}

}
