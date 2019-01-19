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

		let patternText = "[A-Z0-9a-z._%+]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,4}"
		let bodyHTML = "daniele hello@danielemargutti.com ciao ciao"

		let baseStyle = Style {
			$0.font = UIFont.boldSystemFont(ofSize: 12)
		}

		let highlightedStyle: StyleRegEx = StyleRegEx(base: baseStyle, pattern: patternText) {
			$0.font = UIFont.systemFont(ofSize: 40, weight: .bold)
			$0.color = UIColor.red
		}!
		self.textView?.attributedText = bodyHTML.set(style: highlightedStyle)

		
		/*let bodyHTML = try! String(contentsOfFile: Bundle.main.path(forResource: "file", ofType: "txt")!)
		
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
		
		let style = StyleGroup(base: Style {
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
		
		self.textView?.attributedText = bodyHTML.set(style: style)
        if #available(iOS 10.0, *) {
            self.textView?.adjustsFontForContentSizeCategory = true
        }*/
	}
}
