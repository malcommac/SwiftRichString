//
//  ViewController.swift
//  SwiftRichStringPlayground
//
//  Created by daniele on 12/11/2020.
//

import UIKit
import SwiftRichString


class ViewController: UIViewController {

    var str = NSAttributedString()
    @IBOutlet public var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        /*do {
            
            let base = Style {
                $0.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
            }
            
            let rTag  = Style {
                $0.color = UIColor.darkGray
            }
            
            let bTag = Style {
                $0.underline = (NSUnderlineStyle.double,UIColor.red)
            }
            
            let iTag = Style {
                $0.color = UIColor.yellow
            }
            
            let style = StyleXML(base: base, styles: [
                "r": rTag,
                "b": bTag,
                "i": iTag
            ])
            let string = "<r>Ciao come <b>sta andando <i>il cazzo</i></b><i>di</i> progetto?</r>"
            let x = XMLStringBuilder(styleXML: style, string: string)
            let attributed = try x.parse()
            textView.attributedText = attributed
        } catch {
            print(error.localizedDescription)
        }*/
    }


}

