//
//  StyleTests.swift
//  SwiftRichString-iOS Tests
//
//  Created by Rolandas Razma on 06/03/2020.
//  Copyright © 2020 SwiftRichString. All rights reserved.
//

import XCTest
@testable import SwiftRichString

class StyleTests: XCTestCase {

    func testAlignment() {
        
        XCTAssertEqual(Style({ $0.alignment = .left }).paragraph.alignment, NSTextAlignment.left)
        XCTAssertEqual(Style({ $0.alignment = .center }).paragraph.alignment, NSTextAlignment.center)
        XCTAssertEqual(Style({ $0.alignment = .right }).paragraph.alignment, NSTextAlignment.right)
        XCTAssertEqual(Style({ $0.alignment = .justified }).paragraph.alignment, NSTextAlignment.justified)
        XCTAssertEqual(Style({ $0.alignment = .natural }).paragraph.alignment, NSTextAlignment.natural)
        
    }
    
    func testBaselineOffset() {
        XCTAssertEqual(Style({ $0.baselineOffset = -6 }).attributes[.baselineOffset] as? Int, -6)
        XCTAssertEqual(Style({ $0.baselineOffset = 11 }).attributes[.baselineOffset] as? Int, 11)
    }

    func testColor() {
        XCTAssertEqual(Style({ $0.color = UIColor.red }).attributes[.foregroundColor] as? UIColor, UIColor.red)
        XCTAssertEqual(Style({ $0.color = UIColor.blue }).attributes[.foregroundColor] as? UIColor, UIColor.blue)
    }
    
    func testLineBreakMode() {
        
        XCTAssertEqual(Style({ $0.lineBreakMode = .byWordWrapping }).paragraph.lineBreakMode, NSLineBreakMode.byWordWrapping)
        XCTAssertEqual(Style({ $0.lineBreakMode = .byCharWrapping }).paragraph.lineBreakMode, NSLineBreakMode.byCharWrapping)
        XCTAssertEqual(Style({ $0.lineBreakMode = .byClipping }).paragraph.lineBreakMode, NSLineBreakMode.byClipping)
        XCTAssertEqual(Style({ $0.lineBreakMode = .byTruncatingHead }).paragraph.lineBreakMode, NSLineBreakMode.byTruncatingHead)
        XCTAssertEqual(Style({ $0.lineBreakMode = .byTruncatingTail }).paragraph.lineBreakMode, NSLineBreakMode.byTruncatingTail)
        XCTAssertEqual(Style({ $0.lineBreakMode = .byTruncatingMiddle }).paragraph.lineBreakMode, NSLineBreakMode.byTruncatingMiddle)
        
    }
    
    func testMaximumLineHeight() {
        XCTAssertEqual(Style({ $0.maximumLineHeight = -6 }).paragraph.maximumLineHeight, -6.0)
        XCTAssertEqual(Style({ $0.maximumLineHeight = 11 }).paragraph.maximumLineHeight, 11.0)
    }

    func testMinimumLineHeight() {
        XCTAssertEqual(Style({ $0.minimumLineHeight = -6 }).paragraph.minimumLineHeight, -6.0)
        XCTAssertEqual(Style({ $0.minimumLineHeight = 11 }).paragraph.minimumLineHeight, 11.0)
    }
    
    func testLineSpacing() {
        XCTAssertEqual(Style({ $0.lineSpacing = -6 }).paragraph.lineSpacing, -6.0)
        XCTAssertEqual(Style({ $0.lineSpacing = 11 }).paragraph.lineSpacing, 11.0)
    }
    
    func testUnderlineStyle() {
        
        XCTAssertEqual(Style({ $0.underline = (style: NSUnderlineStyle.single, color: nil) }).attributes[.underlineStyle] as? Int, NSUnderlineStyle.single.rawValue)
        XCTAssertEqual(Style({ $0.underline = (style: NSUnderlineStyle.double, color: nil) }).attributes[.underlineStyle] as? Int, NSUnderlineStyle.double.rawValue)
        
    }
    
    func testUnderlineColor() {
        
        XCTAssertEqual(Style({ $0.underline = (style: nil, color: UIColor.red) }).attributes[.underlineColor] as? UIColor, UIColor.red)
        XCTAssertEqual(Style({ $0.underline = (style: nil, color: UIColor.blue) }).attributes[.underlineColor] as? UIColor, UIColor.blue)
        
    }
    
}

extension StyleTests {
    
    static var allTests = [
        ("testAlignment", testAlignment),
        ("testBaselineOffset", testBaselineOffset),
        ("testColor", testColor),
        ("testLineBreakMode", testLineBreakMode),
        ("testMaximumLineHeight", testMaximumLineHeight),
        ("testMinimumLineHeight", testMinimumLineHeight),
        ("testLineSpacing", testLineSpacing),
        ("testUnderlineStyle", testUnderlineStyle),
        ("testUnderlineColor", testUnderlineColor)
    ]
    
}
