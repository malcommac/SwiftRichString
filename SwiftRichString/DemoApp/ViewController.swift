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
		
//		let style_bold = Style("bold", {
//			$0.font = FontAttribute(.Futura_CondensedExtraBold, size: 15)
//		})
//		let style_center = Style("center", {
//			$0.font = FontAttribute(.Menlo_Regular, size: 15)
//			$0.align = .center
//		})
//		let style_italic = Style("italic", {
//			$0.font = FontAttribute(.HelveticaNeue_LightItalic, size: 15)
//			$0.color = UIColor.red
//		})
//		let style_exteme = Style("extreme", {
//			$0.font = FontAttribute(.TimesNewRomanPS_BoldItalicMT, size: 40)
//			$0.underline = UnderlineAttribute(color: UIColor.blue, style: NSUnderlineStyle.styleSingle)
//		})
//		let s = "<center>The quick brown fox</center>\njumps over the lazy dogis an <italic>English-language</italic> pangram—a phrase that contains <italic>all</italic> of the letters of the alphabet. It is <extreme><bold>commonly</bold></extreme> used for touch-typing practice."
//		
//		let mk = MarkupString(s, [style_center,style_italic,style_exteme,style_bold])
//		let att = mk.text
//		textView?.attributedText = att
		
		let myStyle = Style("bold", {
			$0.font = FontAttribute(.Futura_CondensedExtraBold, size: 20)
		})
//		let renderText = "Hello Man! Welcome".with(style: style_bold, range: 6..<10)
//		textView?.attributedText = renderText

		
//		let sourceText = "👿🏅the winner"
//		let attributedString = sourceText.with(styles: myStyle, pattern: "the winner", options: .caseInsensitive)
//		textView?.attributedText = attributedString

//		// another example
//		let sourceText = "prefix12 aaa3 prefix45"
//		let attributedString = sourceText.with(styles: myStyle, pattern: "fix([0-9])([0-9])", options: .caseInsensitive)
//		textView?.attributedText = attributedString

		
		let bold = Style {
			$0.align = .center
			$0.color = UIColor.red
		}
		
		let highlighted = Style {
			$0.backColor = UIColor.yellow
			$0.font = FontAttribute.system(size: 30)
		}
		
		var str = "Hello, playground"
		
		let style = Style({
			$0.font = FontAttribute.bold(size: 25)
			$0.color = UIColor.green
		})
		
		let str2 = str.set(style: style)
		
		
		// TEST #7
		// Parse tagged string and apply style, then get the attributed string
		let tag_center = Style("center", {
			$0.align = .center
			$0.color = UIColor.blue
		})
		
		let tag_italic = Style("italic", {
			$0.font = FontAttribute(.GillSans_LightItalic, size: 14)
			$0.color = UIColor.purple
			$0.backColor = UIColor.yellow
		})
		
		let tag_extreme = Style("extreme", {
			$0.font = FontAttribute(.Georgia_Bold, size: 12)
			$0.color = UIColor.red
		})
		
		let tag_underline = Style("underline", {
			$0.strike = StrikeAttribute(color: UIColor.purple, style: NSUnderlineStyle.patternDot)
		})
		
		let sourceTaggedString = "<center>The quick brown fox</center>\njumps over the lazy dog is an <italic>English-language</italic> pangram—a phrase that contains <italic>all</italic> of the letters of the alphabet. It is <extreme><underline>commonly</underline></extreme> used for touch-typing practice."
		let parser = try! MarkupString(source: sourceTaggedString)
		// Render attributes string
		// Result is parsed only upon requested, only first time (then it will be cached).
		let parseredAttributedText = parser.render(withStyles: [tag_center,tag_italic,tag_extreme,tag_underline])
		// Create and render text
//		let text = "Hello <bold>\(userName)!</bold>, <italic>welcome here!</italic>"
//		let renderedText = text.rich(bold,italic).text
//		
//		let c = ("Hello " + userName.add(tag: "bold") + " welcome here".add(tag: italic)).rich(bold,italic).text
//		
	//	let c = "<bold>Hello</bold>".rich(bold).text

//		let userName = "Daniele!"
//		let bold = Style("bold", {
//			$0.font = FontAttribute(.CourierNewPS_BoldItalicMT, size: 30)
//			$0.color = UIColor.red
//			$0.align = .center
//		})
//		let italic = Style("italic", {
//			$0.font = FontAttribute(.CourierNewPS_ItalicMT, size: 25)
//			$0.color = UIColor.green
//		})
//		let attributedString = ("Hello " + userName).with(style: bold) + "\nwelcome here".with(style: italic)
//		textView?.attributedText = attributedString

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

