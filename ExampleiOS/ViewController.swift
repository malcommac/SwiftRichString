//
//  ViewController.swift
//  ExampleiOS
//
//  Created by Daniele Margutti on 05/05/2018.
//  Copyright © 2018 SwiftRichString. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet public var label: UILabel?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		
		let normal = Style {
			$0.font = SystemFonts.Helvetica_Light.font(size: 15)
		}
		
		let bold = Style {
			$0.font = SystemFonts.Helvetica_Bold.font(size: 20)
			$0.color = UIColor.red
			$0.backColor = UIColor.yellow
		}
		
		let italic = normal.byAdding {
			$0.traitVariants = .italic
		}
		
	
		let str = "Hello <bold>Daniele!</bold>. You're ready to <italic>play with us!</italic>"
		let styleGroup = StyleGroup(base: normal, ["bold": bold, "italic": italic])
		let text = str.set(style: styleGroup)
		self.label?.attributedText = text
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

