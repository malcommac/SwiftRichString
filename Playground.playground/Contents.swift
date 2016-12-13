//: Playground - noun: a place where people can play

import UIKit
@testable import SwiftRichString

let bold = Style({
	$0.font = FontAttribute.bold(size: 25)
	$0.color = UIColor.red
})

let highlighted = Style({
	$0.font = FontAttribute.bold(size: 25)
	$0.color = UIColor.yellow
	$0.backColor = UIColor.red
})

let monospaced = Style({
	$0.font = FontAttribute(.CourierNewPS_ItalicMT, size: 14)
	$0.color = UIColor.darkGray
	$0.expansion = 0.5
})

let mixStyle1 = Style({
	$0.strike = StrikeAttribute(color: UIColor.red, style: NSUnderlineStyle.styleDouble)
})

let mixStyle2 = Style({
	$0.font = FontAttribute(FontName.Helvetica_Bold, size: 20)
	$0.color = UIColor.green
})

let mixStyle3 = Style({
	$0.font = FontAttribute(FontName.AvenirNext_Bold, size: 12)
	$0.color = UIColor.blue
})

// EXAMPLE #1
// CREATE ATTRIBUTED STRING FROM SIMPLE STRING
// ===========================================
// This example demostrate how you can easily mix simple String, apply styles and create a single
// NSMutableAttributedString instance.
// Create an Attributed String from two simple String combined with different styles
var test_1 = "Hello".set(style: bold) + "\n" + "World!".set(style: highlighted)

// EXAMPLE #2
// REMOVE ATTRIBUTES FROM AN EXISTING STRING
// =========================================
// In this example we want to remove a single attribute collection from an existing string
// at specified range.
var test_a = "Hello World".set(styles: mixStyle1,mixStyle2)
test_a.remove(style: mixStyle1, range: 0..<5)
test_a.add(style: mixStyle3, range: 0..<4)

// EXAMPLE #2
// REUSING ATTRIBUTED STRING BY APPENDING CONTENT
// ==============================================
// If you have already an NSMutableAttributedString you can avoid multiple instances and still working
// with the same by appending new content.
// In this example we are adding a simple String to an existing instance.
test_1.append(string: "\nHow old are you?", style: monospaced)

// EXAMPLE #3
// CREATE OR MIX ATTRIBUTED STRING WITH MULTIPLE STYLES
// ====================================================
// Combine different styles (attributes are "added")
var test_2 = "Hello".set(style: mixStyle1).add(styles: mixStyle2)
// Or
var test_3 = "Hello".set(styles: mixStyle1,mixStyle2)

// EXAMPLE #4
// CREATE ATTRIBUTED STRING USING REGULAR EXPRESSION PATTERN MATCHING
// ==================================================================
// You can also working with regular expressions.
// In this example we will apply a custom style using pattern matching:
let test_4 = "prefix12 aaa3 prefix45".set(styles: bold, pattern: "fix([0-9])([0-9])", options: .caseInsensitive)

// EXAMPLE #5
// CREATE ATTRIBUTED STRING USING REGULAR EXPRESSION PATTERN MATCHING WITH EMOJI SUPPORT
// =====================================================================================
// Create attributed string by setting styles using regular expression
// SwiftRichString fully supports unicode!
let sourceText2 = "👿🏅the winner"
let test_5 = sourceText2.set(styles: bold, pattern: "the winner", options: .caseInsensitive)

// EXAMPLE #6
// CREATE ATTRIBUTED STRING BY APPLYING STYLE AT GIVEN RANGE
// =========================================================
// Create attributed string and set style on substring with range
let test_6 = "Hello Man! Welcome".set(style: highlighted, range: 6..<10)

// EXAMPLE #7
// INCREMENTAL ATTRIBUTES
// =========================================================
// Create attributed string and set style on substring with range
let test_7 = "Hello Man! Welcome".set(style: highlighted)


// EXAMPLE #8
// RENDER SOURCE STRING (TAGGED-BASED STRING)
// ==========================================
// SwiftRichString can load a string written in an html-like syntax and produce an
// attributed string with all rendered styles.
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

let tag_default = Style.default {
	$0.shadow = ShadowAttribute(color: UIColor.lightGray, radius: 4, offset: CGSize(width: 2, height: 2))
}

let sourceTaggedString = "<center>The quick brown fox</center>\njumps over the lazy dog is an <italic>English-language</italic> pangram—a phrase that contains <italic>all</italic> of the letters of the alphabet. It is <extreme><underline>commonly</underline></extreme> used for touch-typing practice."
let test8_parser = try! MarkupString(source: sourceTaggedString)
// Render attributes string
// Result is parsed only upon requested, only first time (then it will be cached).
let test_8 = test8_parser.render(withStyles: [tag_center,tag_italic,tag_extreme,tag_underline,tag_default])


// EXAMPLE #9
// CREATE TAGGED STRINGS VIA CODE
// ==============================
let str = "Hello".tagged("test") + " world ".tagged(tag_default)
