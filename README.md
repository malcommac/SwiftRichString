<p align="center" >
  <img src="https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/swiftrichstring.png" width=400px height=172px alt="SwiftRichString" title="SwiftRichString">
</p>

[![Build Status](https://travis-ci.org/oarrabi/SwiftRichString.svg?branch=master)](https://travis-ci.org/oarrabi/SwiftRichString)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://travis-ci.org/oarrabi/SwiftRichString)
[![Language: Swift](https://img.shields.io/badge/language-swift-orange.svg)](https://travis-ci.org/oarrabi/SwiftRichString)
[![CocoaPods](https://img.shields.io/cocoapods/v/SwiftRichString.svg)](https://cocoapods.org/pods/SwiftRichString)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


# SwiftRichString
`SwiftRichString` is a tiny lightweight library wich allows you to simplify working with `NSAttributedString`. It provides convenient way to create and manage string with complex attributes.

And, best of all, it's fully compatible with unicode (who don't love emoji?).


<p align="center" >★★ <b>Star our github repository to help us!</b> ★★</p>

## Documentation
You can work with `SwiftRichString` in two ways:
* working directly with `NSAttributedString` by extending exisisting Cocoa types.
* by creating `RichString` objects from a tag-based formatted source `Strings`, apply your favorite `Styles` and render them as `NSAttributedString`.

### Create Attributed String from tag-based markup language
Sometimes you may have a text you want to render with your own favorite application's styles, like HTML/CSS does with web page.
With `SwiftRichString` it's really easy; add your favourite tags to your source string, create associated `Style` and apply them.
Let me show an example:

```swift
// Define your own style
// Each style has its own name (any letter-based identifier) you should use in your source string
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
let text = "Hello <bold>\(userName)!</bold>, <italic>welcome here!</italic>"
let renderedText = text.rich(bold,italic).text
```

You got your `NSAttributedString` easily!

![assets](https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/assets/assets_1.png)

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
* iOS 8 or later
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