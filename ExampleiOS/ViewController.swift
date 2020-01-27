//
//  ViewController.swift
//  ExampleiOS
//
//  Created by Daniele Margutti on 05/05/2018.
//  Copyright © 2018 SwiftRichString. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet public var textView: UITextView?

	let baseFontSize: CGFloat = 16

	override func viewDidLoad() {
		super.viewDidLoad()
        
//        let text = """
//- <img named="check" att="5"/> Performed!
//"""
//        let base = Style {
//            $0.font = UIFont.boldSystemFont(ofSize: 14)
//            $0.color = UIColor(hexString: "#8E8E8E")
//        }
//
//        let xmlStyle = StyleXML(base: base)
//        xmlStyle.imageProvider = { imageName, attributes in
//            fatalError()
//        }
//
//        self.textView?.attributedText = text.set(style: xmlStyle)
        
//        return
        
//        self.textView?.attributedText = "ciao ciao " + AttributedString(image: UIImage(named: "rocket")!,
//                                                                        bounds: CGRect(x: 0, y: -20, width: 25, height: 25)) + "ciao ciao"
//
//
//        return
//
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
        
        let uppercasedRed = Style {
            $0.font = UIFont.italicSystemFont(ofSize: self.baseFontSize)
            $0.color = UIColor.red
            $0.textTransforms = [
                .uppercase
            ]
        }
                
        // And a group of them
		let styleGroup = StyleGroup(base: Style {
			$0.font = UIFont.systemFont(ofSize: self.baseFontSize)
			$0.lineSpacing = 2
			$0.kerning = Kerning.adobe(-15)
			}, [
                "ur": uppercasedRed,
				"h3": headerStyle,
				"h4": headerStyle,
				"h5": headerStyle,
				"strong": boldStyle,
				"b": boldStyle,
				"em": italicStyle,
				"i": italicStyle,
                "a": uppercasedRed,
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
    
    public override func styleForUnknownXMLTag(_ tag: String, to attributedString: inout AttributedString, attributes: [String : String]?, fromStyle forStyle: StyleXML) {
        super.styleForUnknownXMLTag(tag, to: &attributedString, attributes: attributes, fromStyle: forStyle)
        
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
