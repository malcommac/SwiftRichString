//
//  Imports.swift
//  SwiftRichString
//
//  Created by dan on 07/07/2017.
//  Copyright © 2017 SwiftRichString. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
	import UIKit
	public typealias SRColor = UIColor
	public typealias SRFont = UIFont
#elseif os(OSX)
	import AppKit
	public typealias SRColor = NSColor
	public typealias SRFont = NSFont
#endif
