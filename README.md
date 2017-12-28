<p align="center" >
<img src="https://raw.githubusercontent.com/malcommac/SwiftRichString/master/logo.png" width=530px alt="SwiftLocation" title="SwiftLocation">
</p>


# SwiftRichString
`SwiftRichString` is a lightweight library wich allows you to simplify your work  with attributed strings in UIKit. It provides convenient way to create and manage string with complex attributes, render tag-based string and manipulate styles at specified indexes.

Supported platforms:
* iOS 8.0+
* tvOS 9.0+
* macOS 10.10+
* watchOS 2.0+

And, best of all, it's fully compatible with unicode (who don't love emoji?).

<p align="center" >★★ <b>Star our github repository to help us!</b> ★★</p>


[![Build Status](https://travis-ci.org/oarrabi/SwiftRichString.svg?branch=master)](https://travis-ci.org/oarrabi/SwiftRichString)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://travis-ci.org/oarrabi/SwiftRichString)
[![Platform](https://img.shields.io/badge/platform-tvos-lightgrey.svg)](https://travis-ci.org/oarrabi/SwiftRichString)
[![Platform](https://img.shields.io/badge/platform-watchos-lightgrey.svg)](https://travis-ci.org/oarrabi/SwiftRichString)
[![Platform](https://img.shields.io/badge/platform-macos-lightgrey.svg)](https://travis-ci.org/oarrabi/SwiftRichString)
[![Language: Swift](https://img.shields.io/badge/language-swift-orange.svg)](https://travis-ci.org/oarrabi/SwiftRichString)
[![CocoaPods](https://img.shields.io/cocoapods/v/SwiftRichString.svg)](https://cocoapods.org/pods/SwiftRichString)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
## You also may like
-------

Do you like `SwiftRichString`? I'm also working on several other opensource libraries.

Take a look here:

## OTHER LIBRARIES YOU MAY LIKE

I'm also working on several other projects you may like.
Take a look below:

<p align="center" >

| Library         | Description                                      |
|-----------------|--------------------------------------------------|
| [**SwiftDate**](https://github.com/malcommac/SwiftDate)       | The best way to manage date/timezones in Swift   |
| [**Hydra**](https://github.com/malcommac/Hydra)           | Write better async code: async/await & promises  |
| [**Flow**](https://github.com/malcommac/Flow) | A new declarative approach to table managment. Forget datasource & delegates. |
| [**SwiftRichString**](https://github.com/malcommac/SwiftRichString) | Elegant & Painless NSAttributedString in Swift   |
| [**SwiftLocation**](https://github.com/malcommac/SwiftLocation)   | Efficient location manager                       |
| [**SwiftMsgPack**](https://github.com/malcommac/SwiftMsgPack)    | Fast/efficient msgPack encoder/decoder           |
</p>

On Medium
-------

I've just wrote an article which cover the basic concepts of SwiftRichString.
You can found it on Medium at [Attributed String in Swift: the right way](https://medium.com/breakfastcode/attributed-strings-in-swift-6d4b37db59a5#.gwdgbjzot).

Documentation
-------

* **[Introduction](#introduction)**
* **[Playground](#playground)**
* **[Define your own `Style`](#definestyle)**
* **[Apply style to a `String`](#applystyletostring)**
* **[Apply style on substring with `Range`](#applystylerange)**
* **[Apply style/s on substring with `NSRegularExpression`](#applystyleregexp)**
* **[Apply Multiple Styles with a set of Regular Expressions](#multipleregexp)**
* **[Combine `Strings` and `Attributed Strings`](#combinestrings)**
* **[Create tagged strings](#createtagbased)**
* **[Parse and render tag-based content](#rendertagbased)**
* **[Available text attributes in `Style`](#attributes)**
* **[API Documentation](#apidoc)**

Other Infos
-------
* **[Installation (via CocoaPods, Carthage or Swift PM)](#installation)**
* **[Credits & License](#credits)**

# Documentation

<a name="introduction" />

## Introduction

`SwiftRichString` integrate seamlessy into UIKit/AppKit by allowing you to manage, combine and apply styles directly on `NSMutableAttributedString` instances.
This library define only two main entities:

* `Style` is the central point of `SwiftRichString`: this class allows you to create easily and safety a collection of styles (align, text color, ligature, font etc.).
In fact the ideal use-case is to create your own set of styles for your app, then apply to your strings.

* `MarkupString` allows you to load a string which is pretty like a web page where your content can contain styles enclosed between classic html-style tags (`ie. "<bold>Hello</bold> <nameStyle>\(username)</nameStyle>`). `MarkupString` will parse data for your by generating a valid `NSMutableAttributedString` along your choosed `Styles`.

* Also there are several `NSMutableAttributedString` and `String` extensions allows you to play and combine strings and styles easily without introducing extra structures to your code and by mantaing readability.

<a name="playground" />

## Latest Version
Latest version of `SwiftRichString` is:
* **Swift 4.x**: 1.1.0
* **Swift 3.x**: Up to 0.9.10 release

A complete list of changes for each release is available in the [CHANGELOG](https://github.com/malcommac/SwiftRichString/blob/master/CHANGELOG.md) file.

## Playground

If you want to play with SwiftRichString we have also made a small Playground.
Take a look at `Playground.playground` file inside the `SwiftRichString.xcworkspace`.

<a name="definestyle" />

## Define your own `Style`
`Style` is a class which define attributes you can apply to strings in a type-safe swifty way.
Each style has a name and a set of attributes you can set.

Creating `Style` is pretty easy.
In this example we create a style which set a particular font with given size and color.

```swift 
let big = Style("italic", {
  $0.font = FontAttribute(.CourierNewPS_ItalicMT, size: 25)
  $0.color = UIColor.red
})
```

## Default `Style`

This is also a special style called `.default`.
Default - if present - is applied automatically before any other style to the entire sender string.
Other styles are applied in order just after it.

```swift
let def = Style.default {
  $0.font = FontAttribute(.GillSans_Italic, size: 20)
}
```

<a name="applystyletostring" />

## Apply Style to `String`
Styles can be applied directly to `String` instances (by generating `NSMutableAttributedString` automatically) or on existing `NSMutableAttributedString`.

In this example we can combine simple `String` instances and apply your own set of styles:

```swift
// Define your own used styles
let bold = Style("bold", {
  $0.font = FontAttribute(.CourierNewPS_BoldItalicMT, size: 30) // font + size
  $0.color = UIColor.red // text color 
  $0.align = .center // align on center
})

let italic = Style("italic", {
  $0.font = FontAttribute(.CourierNewPS_ItalicMT, size: 25)
  $0.color = UIColor.green
})

let attributedString = ("Hello " + userName).set(style: bold) + "\nwelcome here".set(style: italic)
```

Will produce:

![assets](https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/assets/assets_1.png)

<a name="applystylerange" />

## Apply style on substring with `Range`
You can also apply one or more styles to a substring by passing a valid range.
In this example we want to apply bold style to the "Man!" substring.

```swift
let style_bold = Style("bold", {
  $0.font = FontAttribute(.Futura_CondensedExtraBold, size: 20)
})
let renderText = "Hello Man! Welcome".set(style: style_bold, range: 6..<10)
```

Will produce:

![assets](https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/assets/assets_3.png)

<a name="applystyleregexp" />

## Apply style/s on substring with `NSRegularExpression`
Regular expressions are also supported; you can add your own style/s to matched strings.
`SwiftRichString` has fully unicode support.

```swift
let sourceText = "👿🏅the winner"
let attributedString = sourceText.set(styles: myStyle, pattern: "the winner", options: .caseInsensitive)

// another example
let sourceText = "prefix12 aaa3 prefix45"
let attributedText = sourceText.set(styles: myStyle, pattern: "fix([0-9])([0-9])", options: .caseInsensitive)
```

Since 0.9.9 you can also use `renderTags` function of `String`:

```
let taggedString = "<center>The quick brown fox</center>\njumps over the lazy dog is an <italic>English-language</italic> pangram—a phrase that contains <italic>all</italic> of the letters of the alphabet. It is <extreme><underline>commonly</underline></extreme> used for touch-typing practice."
let attributed = taggedString.renderTags(withStyles: [tag_center,tag_italic,tag_extreme,tag_underline])
```

Will produce:

![assets](https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/assets/assets_5.png)

![assets](https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/assets/assets_4.png)

<a name="multipleregexp" />

## Apply Multiple Styles with a set of Regular Expressions

Sometimes you may need to apply different `Style` by matching some regular expression rules.
In this case you can use `.set(regExpStyles:default:)` function and define your own matcher; each matcher is a `RegExpPatternStyles` struct which matches a particular regexp and apply a set of `[Style]`.

In the following example we have applied two regexp to colorize email (in red) and url (in blue).
The entire string is set to a base style (`baseStyle`) before all regexp are evaluated.

```swift
let regexp_url = "http?://([-\\w\\.]+)+(:\\d+)?(/([\\w/_\\.]*(\\?\\S+)?)?)?"
let regexp_email = "([A-Za-z0-9_\\-\\.\\+])+\\@([A-Za-z0-9_\\-\\.])+\\.([A-Za-z]+)"

let text_example = "My email is hello@danielemargutti.com and my website is http://www.danielemargutti.com"

let rule_email = RegExpPatternStyles(pattern: regexp_email) {
	$0.color = .red
}!

let rule_url = RegExpPatternStyles(pattern: regexp_url) {
	$0.color = .blue
}!

let baseStyle = Style("base", {
	$0.font = FontAttribute(.Georgia_Bold, size: 12)
})

var attributedString = text_example.set(regExpStyles: [rule_email, rule_url], default: baseStyle)
```
![assets](https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/assets/assets_6.png)

<a name="combinestrings" />

## Combine Strings and Attributed Strings
You can combine `String` and `NSMutableAttributedString` easily with `+` operator.

For example:
```swift
let part1 = "Hello"
let part2 = "Mario"
let part3 = "Welcome here!"

// You can combine simple String and `NSMutableAttributedString`
// Resulting is an `NSMutableAttributedString` instance.
let result = part1 + " " + part2.set(style: bold) + " " + part3
```

You can avoid creating new instances of `NSMutableAttributedString` and change directly your instance:

```swift
let attributedText = "Welcome".set(style: bold)
// Render a simple string with given style and happend it to the previous instance
attributedText.append(string: " mario! ", style: bold)
```

Is possible to append a `MarkupString` to an `NSMutableAttributedString` instance:

```swift
let sourceURL = URL(fileURLWithPath: "...")
let markUpObj = MarkupString(sourceURL, [bold,italic])!

let finalAttributed = "Welcome!".set(style: bold)
// Create an `NSMutableAttributedString` render from markUpObj and append it to the instance
finalAttributed.append(markup: markUpObj)
```
<a name="createtagbased" />

## Create tagged strings
Sometimes you may have a text you want to render with your own favorite application's styles, like HTML/CSS does with web page.
With `SwiftRichString` it's really easy; add your favourite tags to your source string, create associated `Style` and apply them.
Let me show an example:

```swift
// First of all we want to define all `Style` you want to use in your
// source string.
// Each style has its own name (any letter-based identifier) you should use in your source string
let tStyle1 = Style("style1", {
  $0.font = FontAttribute(.AvenirNextCondensed_Medium, size: 50)
  $0.color = UIColor.red
})

let tStyle2 = Style("style2", {
  $0.font = FontAttribute(.HelveticaNeue_LightItalic, size: 20)
  $0.color = UIColor.green
  $0.backColor = UIColor.yellow
})
		
// Create and render text
let text = "Hello <style1>\(userName)!</style1>, <style2>welcome here!</style2>"
let renderedText = text.parse(tStyle1,tStyle2).text
```
<a name="rendertagfile" />

## Parse and render tag-based content
`MarkupString` allows you to load an tags-based string (even from a file, a literals or content from url) and parse it by applying with your own styles.

Suppose you have this text:

```html
<center>The quick brown fox</center>\njumps over the lazy dogis an <italic>English-language</italic> pangram—a phrase that contains <italic>all</italic> of the letters of the alphabet. It is <extreme><bold>commonly</bold></extreme> used for touch-typing practice.
```

This text defines following styles: `"center", "bold", "italic" and "extreme"`.

So, in order to render your text you may want create `Style` instances which represent these tags:

```swift
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

let sourceTaggedString = "<center>The quick brown fox ..."
let parser = MarkupString(source: sourceTaggedString, [style_center,style_italic,style_exteme,style_bold])!
// Render attributes string
// Result is parsed only upon requested, only first time (then it will be cached).
let test_7 = parser.render(withStyles: [style_bold,style_center,style_italic,style_exteme])
```

Will produce:

![assets](https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/assets/assets_2.png)

Clearly you can load string also from file at specified `URL`:

```swift
let sourceURL = URL(fileURLWithPath: "...")
let renderedText = RichString(sourceURL, encoding: .utf8, [bold,italic])!.text
```
<a name="apidoc" />
## API Documentation

### Create `NSMutableAttributedString` from `String`

`func set(style: Style, range: Range<Int>? = nil) -> NSMutableAttributedString`
Create an `NSMutableAttributedString` from a simple `String` instance by applying given `style` at specified range.
If `range` is missing style will be applied to the entire string.

`func set(styles: Style...) -> NSMutableAttributedString`
Create an `NSMutableAttributedString` from a simple `String` instance by applying given `styles`.
Styles are applied in sequence as passed; the only exception is the `.default` `Style` if present; in this case `.default` style is applied in first place.

`func set(styles: Style..., pattern: String, options: NSRegularExpression.Options = .caseInsensitive) -> NSAttributedString`
Create an `NSMutableAttributedString` from a simple `String` instance by applying given `styles` with specified regular expression pattern.
Styles are applied in sequence as passed; the only exception is the `.default` `Style` if present; in this case `.default` style is applied in first place.

### Manage `NSMutableAttributedString`

`func append(string: String, style: Style)`
Append a `String` instance to an existing `NSMutableAttributedString` by applying given `style`.

`func append(markup string: MarkupString, styles: Style...)`
Append a `MarkupString` instance to an existing `NSMutableAttributedString` by applying given `styles`.

`func add(style: Style, range: Range<Int>? = nil) -> NSMutableAttributedString`
Append attributes defined by `style` at given `range` of existing `NSMutableAttributedString`
Return `self` for chain purpose.

`func add(styles: Style...) -> NSMutableAttributedString`
Append attributes defined by passed `styles` into current `NSMutableAttributedString`.
Return `self` for chain purpose.

`func set(style: Style, range: Range<Int>? = nil) -> NSMutableAttributedString`
Replace any exiting attribute into given `range` with the one passed in `style`.
Return `self` for chain purpose.

`func set(styles: Style...) -> NSMutableAttributedString`
Replace any existing attribute into current instance of the attributed string with styles passed.
Styles are applied in sequence as passed; the only exception is the `.default` `Style` if present; in this case `.default` style is applied in first place.
Return `self` for chain purpose.

`func remove(style: Style, range: Range<Int>? = nil) -> NSMutableAttributedString`
Remove attributes keys defined in passed `style` from the instance.

### Combine `String` and `NSMutableAttributedString`

Combine between simple `String` and `NSMutableAttributedString` is pretty straightforward using the Swift's standard `+` operator.
Just an example:

```swift
var test_1 = "Hello".set(style: bold) + "\n" + "World!".set(style: highlighted)
test_1.append(string: "\nHow old are you?", style: monospaced)
```

<a name="attributes" />
## Available Text Attributes

You can define your text attributes in type-safe Swift way.
This is the list of attributes you can customize:

<table border=0 cellpadding=0 cellspacing=0 width=1223 style='border-collapse:
 collapse;table-layout:fixed;width:917pt'>
 <col width=172 style='mso-width-source:userset;mso-width-alt:5504;width:129pt'>
 <col width=387 style='mso-width-source:userset;mso-width-alt:12373;width:290pt'>
 <col class=xl65 width=664 style='mso-width-source:userset;mso-width-alt:21248;
 width:498pt'>
 <tr height=21 style='height:16.0pt'>
  <td height=21 width=172 style='height:16.0pt;width:129pt'>PROPERTY</td>
  <td width=387 style='width:290pt'>DESCRIPTION</td>
  <td class=xl65 width=664 style='width:498pt'>ATTRIBUTES</td>
 </tr>
 <tr height=64 style='height:48.0pt'>
  <td height=64 style='height:48.0pt'>`.align`</td>
  <td>Text alignment</td>
  <td class=xl65 width=664 style='width:498pt'>Any value of
  NSTextAlignment.<br>
  <br>
  Example = `$0.align = .center`</td>
 </tr>
 <tr height=64 style='height:48.0pt'>
  <td height=64 style='height:48.0pt'>`.lineBreak`</td>
  <td>The mode that should be used to break lines</td>
  <td class=xl65 width=664 style='width:498pt'>Any value of
  NSLineBreakMode.<br>
  <br>
  Example = `$0.lineBreak = .byWordWrapping`</td>
 </tr>
 <tr height=171 style='height:128.0pt'>
  <td height=171 style='height:128.0pt'>`.paragraphSpacing`</td>
  <td>The space after the end of the paragraph.</td>
  <td class=xl65 width=664 style='width:498pt'>`Float`<br>
  Example:<br>
  * `$0.paragraphSpacing = 4`<br>
  <br>
  Space measured in pointsadded at the end of the paragraph to separate it
  from the following paragraph.<br>
  Always nonnegative. The space between paragraphs is determined by adding
  the previous paragraph�s paragraphSpacing.</td>
 </tr>
 <tr height=192 style='height:144.0pt'>
  <td height=192 style='height:144.0pt'>`.font`</td>
  <td>Font &amp; Font size to apply</td>
  <td class=xl65 width=664 style='width:498pt'>FontAttribute<br>
  <br>
  FontAttribute is an helper enum which allows you to define in type safe
  Swift way font attributes.<br>
  All system fonts are listed; you can however load a custom font from a
  string (classic mode) or extended FontAttribute enum to add your own custom
  font.<br>
  <br>
  Example:<br>
  * `$0.font = FontAttribute(.CourierNewPS_BoldItalicMT, size: 30)` (from
  enum)<br>
  * `$0.font = FontAttribute(&quot;MyCustomFontFamilyName&quot;, size: 40`
  (from raw string)</td>
 </tr>
 <tr height=107 style='height:80.0pt'>
  <td height=107 style='height:80.0pt'>`.color`</td>
  <td>Text color</td>
  <td class=xl65 width=664 style='width:498pt'>Any valid UIColor instance.
  `SwiftRichString` also accepts UIColor from HEX string (like
  &quot;#FF4555&quot;)<br>
  <br>
  Example:<br>
  * `$0.color = UIColor.red`<br>
  * `$0.color = UIColor(hex: &quot;#FF4555&quot;)</td>
 </tr>
 <tr height=21 style='height:16.0pt'>
  <td height=21 style='height:16.0pt'>`.backColor`</td>
  <td>Background text color</td>
  <td class=xl65 width=664 style='width:498pt'>Same of `.color`</td>
 </tr>
 <tr height=149 style='height:112.0pt'>
  <td height=149 style='height:112.0pt'>`.stroke`</td>
  <td>Stroke attributes of text</td>
  <td class=xl65 width=664 style='width:498pt'>`StrokeAttribute`<br>
  <br>
  `StrokeAttribute` is an helper class which also allows you to define a
  stroke's `.color` and `.width`.<br>
  * `.color` (`UIColor`) color of the stroke;<span
  style='mso-spacerun:yes'>&nbsp; </span>if not defined it is assumed to be the
  same as the value of color; otherwise, it describes the outline color.<br>
  * `.width` (`CGFloat`) Amount to change the stroke width and is specified as
  a percentage of the font point size. Specify 0 (the default) for no
  additional changes.</td>
 </tr>
 <tr height=128 style='height:96.0pt'>
  <td height=128 style='height:96.0pt'>`.underline`</td>
  <td>Underline attributes of text</td>
  <td class=xl65 width=664 style='width:498pt'>`UnderlineAttribute`<br>
  <br>
  `UnderlineAttribute` is an helper struct which allows you to define `.color`
  and `.style` of the underline attribute.<br>
  * `.color` (`UIColor`) Underline color, if missing<span
  style='mso-spacerun:yes'>&nbsp; </span>same as foreground color.<br>
  * `.style` (`NSUnderlineStyle`) The style of the underline, by default is
  `.styleNone`</td>
 </tr>
 <tr height=128 style='height:96.0pt'>
  <td height=128 style='height:96.0pt'>`.strike`</td>
  <td>Strike attributes of text</td>
  <td class=xl65 width=664 style='width:498pt'>`StrikeAttribute`<br>
  <br>
  `StrikeAttribute` is an helper struct which allows you to define strike
  attributes: `.color` and `.style`.<br>
  * `.color` (`UIColor`) Underline color, if missing<span
  style='mso-spacerun:yes'>&nbsp; </span>same as foreground color.<br>
  * `.style` (`NSUnderlineStyle`) This value indicates whether the text is
  underlined and corresponds to one of the constants described in
  NSUnderlineStyle.</td>
 </tr>
 <tr height=213 style='height:160.0pt'>
  <td height=213 style='height:160.0pt'>`.shadow`</td>
  <td>Shadow attributes of text (only for macOS and iOS)</td>
  <td class=xl65 width=664 style='width:498pt'>`ShadowAttribute`<br>
  <br>
  `ShadowAttribute` defines following properties:<br>
  * `.offset` (`CGSize`) horizontal and vertical offset values, specified
  using the width and height fields of the CGSize data type.<br>
  * `.blurRadius` (`CGFloat`) This
  property contains the blur radius, as measured in the default user coordinate
  space. A value of 0 indicates no blur, while larger values produce
  correspondingly larger blurring. This value must not be negative. The default
  value is 0.<br>
  * `.color` (`UIColor`) The default shadow color is black
  with an alpha of 1/3. If you set this property to nil, the shadow is not
  drawn.</td>
 </tr>
 <tr height=128 style='height:96.0pt'>
  <td height=128 style='height:96.0pt'>`.firstLineheadIntent`</td>
  <td>The indentation of the first line.</td>
  <td class=xl65 width=664 style='width:498pt'>`Float`<br>
  Example:<br>
  * `$0.firstLineHeadIntent = 0.5`<br>
  <br>
  The distance (in points) from the leading margin of a text container to the
  beginning of the paragraph�s first line.</td>
 </tr>
 <tr height=128 style='height:96.0pt'>
  <td height=128 style='height:96.0pt'>`.headIndent`</td>
  <td>The indentation of lines other than the first.</td>
  <td class=xl65 width=664 style='width:498pt'>`Float`<br>
  Example:<br>
  * `$0.headIdent = 4`<br>
  <br>
  The distance (in points) from the leading margin of a text container to the
  beginning of lines other than the first. This value is always nonnegative.</td>
 </tr>
 <tr height=149 style='height:112.0pt'>
  <td height=149 style='height:112.0pt'>`.tailIndent`</td>
  <td>The trailing indentation.</td>
  <td class=xl65 width=664 style='width:498pt'>`Float`<br>
  Example:<br>
  * `$0.tailIndent = 2`<br>
  <br>
  If positive, this value is the distance from the leading margin (for
  example, the left margin in left-to-right text).<br>
  If 0 or negative, it�s the distance from the trailing margin.</td>
 </tr>
 <tr height=192 style='height:144.0pt'>
  <td height=192 style='height:144.0pt'>`.maximumLineHeight`</td>
  <td>Maximum line height.</td>
  <td class=xl66 width=664 style='width:498pt'>`Float`<br>
  Example:<br>
  * `$0.maximumLineHeight = 2`<br>
  <br>
  This property contains the maximum height in points that any line in the
  receiver will occupy, regardless of the font size or size ofany attached
  graphic. This value is always nonnegative. The default value is 0. Glyphs and
  graphics exceeding this height will overlap neighboring lines; however, a
  maximum height of 0 implies no line height limit.<br>
  Although this limit applies to the line itself, line spacing adds extra
  space between adjacent lines.</td>
 </tr>
 <tr height=128 style='height:96.0pt'>
  <td height=128 style='height:96.0pt'>`.minimumLineHeight`</td>
  <td>Minimum line height.</td>
  <td class=xl65 width=664 style='width:498pt'>`Float`<br>
  Example:<br>
  * `$0.minimumLineHeight = 2`<br>
  <br>
  This property contains the minimum height in points that any line in the
  receiver will occupy, regardless of the font size or size of any attached
  graphic. This value is always nonnegative</td>
 </tr>
 <tr height=149 style='height:112.0pt'>
  <td height=149 style='height:112.0pt'>`.lineSpacing`</td>
  <td>Distance in points between the bottom of one line fragmen<span
  style='display:none'>t and the top of the next.</span></td>
  <td class=xl65 width=664 style='width:498pt'>`Float`<br>
  Example:<br>
  * `$0.lineSpacing = 1`<br>
  <br>
  The distance in points between the bottom of one line fragment and the top
  of the next.<br>
  This value is always nonnegative. This value is included in the line
  fragment heights in the layout manager.</td>
 </tr>
 <tr height=128 style='height:96.0pt'>
  <td height=128 style='height:96.0pt'>`.paragraphSpacingBefore<span
  style='display:none'>`</span></td>
  <td>Distance between the paragraph�s top and the beginning o<span
  style='display:none'>f its text content.</span></td>
  <td class=xl65 width=664 style='width:498pt'>`Float`<br>
  Example:<br>
  * `$0.paragraphSpacingBefore = 1`<br>
  <br>
  The space (measured in points) between the paragraph�s top and the beginning
  of its text content.<br>
  The default value of this property is 0.0.</td>
 </tr>
 <tr height=149 style='height:112.0pt'>
  <td height=149 style='height:112.0pt'>`.lineHeightMultiple`</td>
  <td>Line height multiple.</td>
  <td class=xl65 width=664 style='width:498pt'>`Float`<br>
  Example:<br>
  * `$0.lineHeightMultiple = 1`<br>
  <br>
  The natural line height of the receiver is multiplied by this factor (if
  positive) before being constrained by minimum and maximum line height.<br>
  The default value of this property
  is 0.0.</td>
 </tr>
 <tr height=192 style='height:144.0pt'>
  <td height=192 style='height:144.0pt'>`.hyphenationFactor`</td>
  <td>Paragraph�s threshold for hyphenation.</td>
  <td class=xl65 width=664 style='width:498pt'>`Float`<br>
  Example:<br>
  * `$0.hyphenationFactor = 1`<br>
  <br>
  Hyphenation is attempted when the ratio of the text width (as broken without
  hyphenation) to the width of the line fragment is less than<br>
  the hyphenation factor. When the paragraph�s
  hyphenation factor is 0.0, the layout manager�s hyphenation factor is used
  instead.<br>
  When both are 0.0, hyphenation is disabled.</td>
 </tr>
</table>

<a name="installation" />

## Installation
You can install Swiftline using CocoaPods, carthage and Swift package manager

* **Swift 4.x**: 1.1.0
* **Swift 3.x**: Up to 0.9.10 release

### CocoaPods
    use_frameworks!
    pod 'SwiftRichString'

### Carthage
    github "malcommac/SwiftRichString"

### Swift Package Manager
Add swiftline as dependency in your `Package.swift`

```
  import PackageDescription

  let package = Package(name: "YourPackage",
    dependencies: [
      .Package(url: "https://github.com/malcommac/SwiftRichString.git", majorVersion: 0),
    ]
  )
```

<a name="requirements" />

## Requirements

Current version (0.9.9+) is compatible with:

* Swift 3.x and Swift 4.x
* iOS 8.0+
* tvOS 9.0+
* macOS 10.10+
* watchOS 2.0+

<a name="credits" />

## Credits & License
SwiftRichString is owned and maintained by [Daniele Margutti](http://www.danielemargutti.com/).

As open source creation any help is welcome!

The code of this library is licensed under MIT License; you can use it in commercial products without any limitation.

The only requirement is to add a line in your Credits/About section with the text below:

```
This software uses open source SwiftRichString's library to manage rich attributed strings.
Web: http://github.com/malcommac/SwiftRichString
Created by Daniele Margutti and licensed under MIT License.
```
