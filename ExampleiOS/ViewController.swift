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
        
       /* let baseStyle = Style {
            $0.font =  SystemFonts.AmericanTypewriter.font(size: 17)//UIFont.systemFont(ofSize: 17)
            $0.color = UIColor.darkGray
        }
        
        let redStyle = Style {
            $0.font =  SystemFonts.Futura_Bold.font(size: 32)//UIFont.systemFont(ofSize: 17)
            $0.color = UIColor.red
        }
        
        let strikeStyle = baseStyle.byAdding {
            $0.strikethrough = (style: .single, color: UIColor.blue)
            $0.textTransforms = [.custom({
                return "**\($0)**"
            })]
        }
        
        let source = "Hello <b>wor<r>ld</r></b> my name"//is <i type='1 px'>Daniele</i>"
        let x = XMLStringBuilder(string: source, options: [], baseStyle: baseStyle, styles: ["b": strikeStyle, "r": redStyle])
        let att = try! x.parse()
        debugPrint("ciao")
        */
    /*
        
        let strikeStyle = baseStyle.byAdding {
            $0.strikethrough = (style: .single, color: UIColor.blue)
            $0.textTransform = .custom({
                return "**\($0)**"
            })
        }
        
         let redBodyStyle = baseStyle.byAdding {
            $0.color = UIColor.red
            $0.font = SystemFonts.Zapfino.font(size: 32)//UIFont.systemFont(ofSize: 32).withWeight(.medium)
        }
        
        let g = StyleGroup(base: baseStyle, [("s", strikeStyle), ("r", redBodyStyle)])*/
        
        /*
        
        let boldStyle = Style {
           // $0.font = UIFont.boldSystemFont(ofSize: self.baseFontSize)
            $0.font = SystemFonts.AmericanTypewriter.font(size: self.baseFontSize)
            $0.color = UIColor.blue
            /*if #available(iOS 11.0, *) {
                $0.dynamicText = DynamicText {
                    $0.style = .body
                    $0.maximumSize = 35.0
                    $0.traitCollection = UITraitCollection(userInterfaceIdiom: .phone)
                }
            }*/
        }
        
        let headerStyle = Style {
            $0.font = SystemFonts.ArialHebrew.font(size: 22)
            $0.color = UIColor.red
        }
        
        let g = StyleGroup(base: headerStyle, ["c" : boldStyle])
        */
       //self.textView?.attributedText = "ciao ciao <s>altro</s> merda <r>test</r>".set(style: g)
    //    self.textView?.attributedText = "ciao ciao <s>altro</s> merda <r>test</r>".set(style: strikeStyle)


		
		let bodyHTML = try! String(contentsOfFile: Bundle.main.path(forResource: "file", ofType: "txt")!)
		

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
		
		let style = StyleGroup2(base: Style {
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
        }
        
        
        
	}
}
