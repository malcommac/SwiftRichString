
import UIKit
import SwiftRichString
import PlaygroundSupport

// Create your own styles

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

// Create a group which contains your style, each identified by a tag.
let myGroup = StyleGroup(base: normal, ["bold": bold, "italic": italic])

// Use tags in your plain string
let str = "Hello <bold>Daniele!</bold>. You're ready to <italic>play with us!</italic>"

let attributedStringController = AttributedStringController()
PlaygroundPage.current.liveView = attributedStringController

attributedStringController.attributedString = str.set(style: myGroup)


