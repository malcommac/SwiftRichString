<p align="center" >
  <img src="https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/swiftrichstring.png" width=400px height=172px alt="SwiftRichString" title="SwiftRichString">
</p>

[![Build Status](https://travis-ci.org/oarrabi/SwiftRichString.svg?branch=master)](https://travis-ci.org/oarrabi/SwiftRichString)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://travis-ci.org/oarrabi/SwiftRichString)
[![Language: Swift](https://img.shields.io/badge/language-swift-orange.svg)](https://travis-ci.org/oarrabi/SwiftRichString)
[![CocoaPods](https://img.shields.io/cocoapods/v/SwiftRichString.svg)](https://cocoapods.org/pods/SwiftRichString)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


# SwiftRichString
`SwiftRichString` is a lightweight library wich allows you to simplify your work  with attributed strings in UIKit. It provides convenient way to create and manage string with complex attributes, render tag-based string and manipulate styles at specified indexes.

And, best of all, it's fully compatible with unicode (who don't love emoji?).

<p align="center" >★★ <b>Star our github repository to help us!</b> ★★</p>

Features Documentation
-------

* **[Introduction](#introduction)**
* **[Define your own `Style`](#definestyle)**
* **[Apply Style to `String`](#applystyletostring)**
* **[Apply style on substring with `Range`](#applystylerange)**
* **[Apply style/s on substring with `NSRegularExpression`](#applystyleregexp)**
* **[Combine `Strings` and `Attributed Strings`](#combinestrings)**
* **[Create Tag-Based Strings](#createtagbased)**
* **[Render Tag-Based Strings](#rendertagbased)**

Other
-------
* **[Installation (via CocoaPods, Carthage or Swift PM)](#installation)**
* **[Requirements](#requirements)**
* **[Credits & License](#credits)**

<a name="introduction" />

# Introduction

`SwiftRichString` integrate seamlessy into UIKit by allowing you to manage, combine and apply styles directly on `NSMutableAttributedString` instances.
Our framework define only two main entities:

* `Style` is the central point of `SwiftRichString`: this class allows you to create easily and safety a collection of styles (align, text color, ligature, font etc.).
In fact the ideal use-case is to create your own set of styles for your app, then apply to your strings.

* `MarkupString` allows you to load a string which is pretty like a web page where your content can contain styles enclosed between classic html-style tags (`ie. "<bold>Hello</bold> <nameStyle>\(username)</nameStyle>`). `MarkupString` will parse data for your by generating a valid `NSMutableAttributedString` along your choosed `Styles`.

* Several `NSMutableAttributedString` and `String` extensions allows you to play and combine strings and styles easily without introducing extra structures to your code and by mantaing readability.

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
// Define your own Style
let bold: Style: = // ...
let italic: Style = // ...
// Combine simple string and apply styles to each
let attributedString = "Hello " + userName.with(style: bold) + ".welcome here".with(style: italic)
```

![assets](https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/assets/assets_2.png)

<a name="applystylerange" />

## Apply style on substring with `Range`
You can also apply one or more styles to a substring by passing a valid range.
In this example we want to apply bold style to the "Man!" substring.

```swift
let renderText = "Hello Man! Welcome".with(style: bold, range: 6..<10)
```

<a name="applystyleregexp" />

## Apply style/s on substring with `NSRegularExpression`
Regular expressions are also supported; you can add your own style/s to matched strings.
`SwiftRichString` has fully unicode support.

```swift
let sourceText = "👿🏅the winner"
let attributedString = sourceText.with(styles: myStyle, pattern: "the winner", options: .caseInsensitive)

// another example
let sourceText = "prefix12 aaa3 prefix45"
let attributedText = c.with(styles: myStyle, pattern: "fix([0-9])([0-9])", options: .caseInsensitive)
```
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
let result = part1 + " " + part2.with(style: bold) + " " + part3
```

You can avoid creating new instances of `NSMutableAttributedString` and change directly your instance:

```swift
let attributedText = "Welcome".with(style: bold)
// Render a simple string with given style and happend it to the previous instance
attributedText.append(string: " mario! ", style: bold)
```

Is possible to append a `MarkupString` to an `NSMutableAttributedString` instance:

```swift
let sourceURL = URL(fileURLWithPath: "...")
let markUpObj = RichString(sourceURL, encoding: .utf8, [bold,italic])!

let finalAttributed = "Welcome!".with(style: bold)
// Create an `NSMutableAttributedString` render from markUpObj and append it to the instance
finalAttributed.append(markup: markUpObj)
```
<a name="createtagbased" />

## Create Tag-Based Strings
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

## Render Tag-Based Strings
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

let sourceTaggedString = "<center>The quick brown fox ...
let parser = MarkupString(sourceTaggedString, [style_center,style_italic,style_exteme,style_bold])
// Render attributes string
// Result is parsed only upon requested, only first time (then it will be cached).
let att = parser.text
```

Clearly you can load string also from file at specified `URL`:

```swift
let sourceURL = URL(fileURLWithPath: "...")
let renderedText = RichString(sourceURL, encoding: .utf8, [bold,italic])!.text
```

<a name="installation" />

## Installation
You can install Swiftline using CocoaPods, carthage and Swift package manager

### CocoaPods
    use_frameworks!
    pod 'SwiftRichString'

### Carthage
    github 'malcommac/SwiftRichString'

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

<a name="tests" />

## Tests
Tests can be found [here](https://github.com/malcommac/SwiftRichString/tree/master/Tests). 

Run them with 
```
swift test
```

<a name="requirements" />

## Requirements

Current version is compatible with:

* Swift 3.0+
* iOS 7 or later
* macOS 10.10 or later
* watchOS 2.0 or later
* tvOS 9.0 or later
* ...and virtually any platform which is compatible with Swift 3 and implements the Swift Foundation Library


<a name="credits" />

## Credits & License
SwiftRichString is owned and maintained by [Daniele Margutti](http://www.danielemargutti.com/).

As open source creation any help is welcome!

The code of this library is licensed under MIT License; you can use it in commercial products without any limitation.

The only requirement is to add a line in your Credits/About section with the text below:

```
Portions SwiftRichString - http://github.com/malcommac/SwiftRichString
Created by Daniele Margutti and licensed under MIT License.
```
