//
//  UIKit+Extensions.swift
//  ExampleiOS
//
//  Created by daniele on 21/12/2019.
//  Copyright © 2019 SwiftRichString. All rights reserved.
//

import UIKit

extension UIColor {
    
    public static func randomColors(_ count: Int) -> [UIColor] {
        return (0..<count).map { _ -> UIColor in
            randomColor()
        }
    }
    
    public static func randomColor() -> UIColor {
        let redValue = CGFloat.random(in: 0...1)
        let greenValue = CGFloat.random(in: 0...1)
        let blueValue = CGFloat.random(in: 0...1)
        
        let randomColor = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
        return randomColor
    }
    
}

extension UIFont {
    
    /// Return the same font with given weight.
    ///
    /// - Parameter weight: weight you want to get
    public func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: descriptor, size: 0) // size 0 means keep the size as it is
    }
    
}
