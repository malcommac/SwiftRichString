//
//  ViewController.swift
//  DemoApp
//
//  Created by Daniele Margutti on 08/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import UIKit
import SwiftRichString

class ViewController: UIViewController {
	
	@IBOutlet public weak var textView: UITextView?

	override func viewDidLoad() {
		super.viewDidLoad()

//		let bold = Style("bold", {
//			$0.font = FontAttribute(.Copperplate, size: 50)
//			$0.color = UIColor.red
//		})
//		
//		let big = Style("italic", {
//			$0.font = FontAttribute(.CourierNewPS_ItalicMT, size: 25)
//			$0.strike = NSUnderlineStyle.patternDash
//			$0.strikeColor = UIColor.green
//			$0.color = UIColor.red
//		})
//		
//		let def = Style.default {
//			$0.font = FontAttribute(.GillSans_Italic, size: 20)
//		}
		
		//let c = "Hello".with(italic) + "Daniele".with(bold)
		//let c = "Hello".with(styles: bold,italic)
		
//		let c = "👿🏅the winner"
//		let w = c.with(styles: big, pattern: "the winner", options: .caseInsensitive)
//
////		let c = "prefix12 aaa3 prefix45"
		//let w = c.with(styles: big, pattern: "fix([0-9])([0-9])", options: .caseInsensitive)
		
		//let w = c.add(tag: big, pattern: "fix([0-9])([0-9])")
		
		
//		let bold = Style("bold", {
//			$0.font = FontAttribute(.AvenirNextCondensed_Medium, size: 50)
//			$0.color = UIColor.red
//		})
//		let italic = Style("italic", {
//			$0.font = FontAttribute(.HelveticaNeue_LightItalic, size: 20)
//			$0.color = UIColor.green
//			$0.backColor = UIColor.yellow
//		})

	//	let userName = "Daniele"
	//	let renderText = "Hello " + userName.with(bold) + "! " + "welcome here".with(italic)
		
		//let text = "Hello Man! Welcome".with(bold, range: 6..<10)
	
//		let text = "Hello".with(style: bold)
		
//		let sourceURL = URL(fileURLWithPath: "...")
//		let sourceText = RichString(sourceURL, encoding: .utf8, [bold,italic])!
//		let renderedText = sourceText.text
		
		let style_bold = Style("bold", {
			$0.font = FontAttribute(.Futura_CondensedExtraBold, size: 15)
		})
		let style_center = Style("center", {
			$0.font = FontAttribute(.Menlo_Regular, size: 15)
			$0.align = .center
		})
		let style_italic = Style("italic", {
			$0.font = FontAttribute(.HelveticaNeue_LightItalic, size: 15)
			$0.color = UIColor.red
		})
		let style_exteme = Style("extreme", {
			$0.font = FontAttribute(.TimesNewRomanPS_BoldItalicMT, size: 40)
			$0.underline = UnderlineAttribute(color: UIColor.blue, style: NSUnderlineStyle.styleSingle)
		})
		let s = "<center>The quick brown fox</center>\njumps over the lazy dogis an <italic>English-language</italic> pangram—a phrase that contains <italic>all</italic> of the letters of the alphabet. It is <extreme><bold>commonly</bold></extreme> used for touch-typing practice."
		
		let mk = MarkupString(s, [style_center,style_italic,style_exteme,style_bold])
//		let mk = MarkupString(s, [style_center])
		let att = mk.text
		textView?.attributedText = att
		
		// Create and render text
//		let text = "Hello <bold>\(userName)!</bold>, <italic>welcome here!</italic>"
//		let renderedText = text.rich(bold,italic).text
//		
//		let c = ("Hello " + userName.add(tag: "bold") + " welcome here".add(tag: italic)).rich(bold,italic).text
//		
	//	let c = "<bold>Hello</bold>".rich(bold).text
		print("")
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

