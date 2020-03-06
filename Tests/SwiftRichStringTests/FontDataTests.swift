//
//  FontDataTests.swift
//  SwiftRichString-iOS Tests
//
//  Created by Rolandas Razma on 06/03/2020.
//  Copyright © 2020 SwiftRichString. All rights reserved.
//

import XCTest
@testable import SwiftRichString

class FontDataTests: XCTestCase {
    
    private func fontAttributes<T>(for fontData: FontData, attribute: UIFontDescriptor.AttributeName) -> T? {
        super.setUp()
        
        let attributes: [NSAttributedString.Key: Any] = fontData.attributes(currentFont: UIFont.systemFont(ofSize: 12), size: 12)
        XCTAssertFalse(attributes.isEmpty, "empty attributes")
        
        let font: UIFont? = attributes[.font] as? UIFont
        XCTAssertNotNil(font, "font attribute missing")
        
        let fontAttributes: [UIFontDescriptor.AttributeName : Any]? = font?.fontDescriptor.fontAttributes
        XCTAssertNotNil(fontAttributes, "font has no attributes")
        
        return fontAttributes?[attribute] as? T
    }
    
    private func featureSettings<T: Equatable>(for fontData: FontData, featureIdentifier: T) -> [[UIFontDescriptor.FeatureKey: Any]]? {
        let featureSettings: [[UIFontDescriptor.FeatureKey: Any]]? = self.fontAttributes(for: fontData, attribute: .featureSettings)
        return featureSettings?.filter({ $0[.featureIdentifier] as? T == featureIdentifier })
    }
    
    func testNumberSpacingMonospaced() {
        
        var fontData = FontData()
        fontData.numberSpacing = .monospaced
        
        let features: [[UIFontDescriptor.FeatureKey: Any]]? = self.featureSettings(for: fontData, featureIdentifier: kNumberSpacingType)
        XCTAssertEqual(features?.count, 1, "expected to have 1 and only one feature for kNumberSpacingType")
        XCTAssertEqual(features?.first?[.typeIdentifier] as? Int, kMonospacedNumbersSelector)
        
    }
    
    func testNumberSpacingProportional() {
        
        var fontData = FontData()
        fontData.numberSpacing = .proportional
        
        let features: [[UIFontDescriptor.FeatureKey: Any]]? = self.featureSettings(for: fontData, featureIdentifier: kNumberSpacingType)
        XCTAssertEqual(features?.count, 1, "expected to have 1 and only one feature for kNumberSpacingType")
        XCTAssertEqual(features?.first?[.typeIdentifier] as? Int, kProportionalNumbersSelector)
        
    }
    
    func testKerning() {
        
        var fontData = FontData()
        fontData.kerning = .point(99)

        let attributes: [NSAttributedString.Key: Any] = fontData.attributes(currentFont: UIFont.systemFont(ofSize: 12), size: 12)
        XCTAssertFalse(attributes.isEmpty, "empty attributes")
        
        XCTAssertEqual(attributes[.kern] as? CGFloat, 99)
        
    }
    
}

extension FontDataTests {
    
    static var allTests = [
        ("testNumberSpacing", testNumberSpacingMonospaced),
        ("testNumberSpacingProportional", testNumberSpacingProportional),
        ("testKerning", testKerning)
    ]
    
}
