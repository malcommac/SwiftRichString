//
//  ViewController.swift
//  ExampleiOS
//
//  Created by Daniele Margutti on 05/05/2018.
//  Copyright © 2018 SwiftRichString. All rights reserved.
//

import UIKit

extension UIFont {
    
    /// Return the same font with given weight.
    ///
    /// - Parameter weight: weight you want to get
    public func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: descriptor, size: 0) // size 0 means keep the size as it is
    }
    
}


class ViewController: UIViewController {
	
	@IBOutlet public var textView: UITextView?

	let baseFontSize: CGFloat = 16

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let bodyHTML = try! String(contentsOfFile: Bundle.main.path(forResource: "file", ofType: "txt")!)
		
        // Create a set of styles
        
		let headerStyle = Style {
			$0.font = UIFont.boldSystemFont(ofSize: self.baseFontSize * 1.15)
			$0.lineSpacing = 1
			$0.kerning = Kerning.adobe(-20)
		}
		let boldStyle = Style {
			$0.font = UIFont.boldSystemFont(ofSize: self.baseFontSize)
            if #available(iOS 11.0, *) {
                $0.dynamicText = DynamicText {
                    $0.style = .body
                    $0.maximumSize = 35.0
                    $0.traitCollection = UITraitCollection(userInterfaceIdiom: .phone)
                }
            }
		}
		let italicStyle = Style {
			$0.font = UIFont.italicSystemFont(ofSize: self.baseFontSize)
		}
        
        // And a group of them
		let styleGroup = StyleGroup(base: Style {
			$0.font = UIFont.systemFont(ofSize: self.baseFontSize)
			$0.lineSpacing = 2
			$0.kerning = Kerning.adobe(-15)
			}, [
				"h3": headerStyle,
				"h4": headerStyle,
				"h5": headerStyle,
				"strong": boldStyle,
				"b": boldStyle,
				"em": italicStyle,
				"i": italicStyle,
				"li": Style {
					$0.paragraphSpacingBefore = self.baseFontSize / 2
					$0.firstLineHeadIndent = self.baseFontSize
					$0.headIndent = self.baseFontSize * 1.71
				},
				"sup": Style {
					$0.font = UIFont.systemFont(ofSize: self.baseFontSize / 1.2)
					$0.baselineOffset = Float(self.baseFontSize) / 3.5
        }])

        // Apply a custom xml attribute resolver
        styleGroup.xmlAttributesResolver = MyXMLDynamicAttributesResolver()

        // Render
		self.textView?.attributedText = bodyHTML.set(style: styleGroup)
        
        // Accessibility support
        if #available(iOS 10.0, *) {
            self.textView?.adjustsFontForContentSizeCategory = true
        }
        
	}
}

public class MyXMLDynamicAttributesResolver: StandardXMLAttributesResolver {
    
    public override func styleForUnknownXMLTag(_ tag: String, to attributedString: inout AttributedString, attributes: [String : String]?) {
        super.styleForUnknownXMLTag(tag, to: &attributedString, attributes: attributes)
        
        if tag == "rainbow" {
            let colors = UIColor.randomColors(attributedString.length)
            for i in 0..<attributedString.length {
                attributedString.add(style: Style({
                    $0.color = colors[i]
                }), range: NSMakeRange(i, 1))
            }
        }
        
    }
    
}

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
