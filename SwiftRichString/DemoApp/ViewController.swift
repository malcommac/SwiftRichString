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

	override func viewDidLoad() {
		super.viewDidLoad()

//		let bold = Style("bold", {
//			$0.font = FontAttribute(.Copperplate, size: 50)
//			$0.color = UIColor.red
//		})
//		
//		let big = Style("italic", {
//			$0.font = FontAttribute(.CourierNewPS_ItalicMT, size: 80)
//		})
		
		//let c = "Hello".with(italic) + "Daniele".with(bold)
		//let c = "Hello".with(styles: bold,italic)
		
		//let c = "👿🏅pig"
		//let w = c.with(styles: big, pattern: "pig", options: .caseInsensitive)

//		let c = "prefix12 aaa3 prefix45"
		//let w = c.with(styles: big, pattern: "fix([0-9])([0-9])", options: .caseInsensitive)
		
		//let w = c.add(tag: big, pattern: "fix([0-9])([0-9])")
		
		
		let bold = Style("bold", {
			$0.font = FontAttribute(.AvenirNextCondensed_Medium, size: 50)
			$0.color = UIColor.red
		})
		let italic = Style("italic", {
			$0.font = FontAttribute(.HelveticaNeue_LightItalic, size: 20)
			$0.color = UIColor.green
			$0.backColor = UIColor.yellow
		})
		
		// Create and render text
		let userName = "Daniele"
		let text = "Hello <bold>\(userName)!</bold>, <italic>welcome here!</italic>"
		let renderedText = text.rich(bold,italic).text
		
	//	let c = "<bold>Hello</bold>".rich(bold).text
		print("\(renderedText)")
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

