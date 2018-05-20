SwiftRichString is a lightweight library which allows to create and manipulate attributed strings easily both in iOS, macOS, tvOS and even watchOS.
It provides convenient way to store styles you can reuse in your app's UI lements, allows complex tag-based strings rendering and also includes integration with Interface Builder.

If you manipulate `NSAttributedString` in Swift, SwiftRichString allows you to keep your code manteniable, readable and easy to evolve.

## Features Highlights

### Easy Styling
The main concept behind this lib is the `Style`: a style is just a collection of text attributes you can apply to a string. The following example show how to create a style an produce an attributed string with it:

```swift
let style = Style {
	$0.font = SystemFonts.AmericanTypewriter.font(size: 25) // just pass a string, one of the SystemFonts or an UIFont
	$0.color = "#0433FF" // you can use UIColor or HEX string!
	$0.underline = (.patternDot, UIColor.red)
	$0.alignment = .center
}
let attributedText = "Hello World!".set(style: style) // et voilà!
```

### Global Styles & Interface Builder Integration
Styles can be also registered globally and reused in your app.
Just define your own style and register using `Styles.register()` function:

```swift
let myStyle = Style { // define style's attributes... }
Styles.register("MyStyle", style: style)
```

Now you can reuse it everything in your app; SwiftRichString exposes a `styleName` property for the most common text containers and you can set it directly in Interface Builder:

<img src="Documentation_Assests/image_1.png" alt="" style="width: 500px;"/>

### Complex Rendering with tag-based strings
SwiftRichString allows you to render complex strings by parsing text's tags: each style will be identified by an unique name (used inside the tag) and you can create a `StyleGroup` which allows you to encapsulate all of them and reuse as you need (clearly you can register it globally).

```swift
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
self.label?.attributedText = str.set(style: myGroup)
```

That's the result!

<img src="Documentation_Assests/image_2.png" alt="" style="width: 300px;"/>

## Latest Version

Latest version of SwiftRichString is [2.0.0](https://github.com/malcommac/SwiftRichString/releases/tag/2.0.0).
Full changelog is available in [CHANGELOG.md](CHANGELOG.md) file.

## Migration from 1.x


## Documentation

- `Style` & `StyleGroup`
	- Introduction
	- String & Attributed String concatenation
	- Fonts & Colors in `Style`
	- Derivating a `Style`
- The `StyleManager`
	- Register globally available styles
	- Defer style creation on demand
- Assign style using Interface Builder
- All properties of `Style`

Other info:

- Requirements
- Installation
- Copyright

## `Style` & `StyleGroup`

### Introduction

A `Style` is a class which encapsulate all the attributes you can apply to a string. The vast majority of the attributes of both AppKit/UIKit are currently available via type-safe properties by this class.

Creating a `Style` instance is pretty simple; using a builder pattern approach the init class require a callback where the self instance is passed and allows you to configure your properties by keeping the code clean and readable:

```swift
let style = Style {
	$0.font = SystemFonts.Helvetica_Bold.font(size: 20)
	$0.color = UIColor.green
	// ... set any other attribute
}
```

`Style` instances are anonymous; if you want to use a style instance to render a tag-based plain string you need to include it inside a `StyleGroup`. You can consider a `StyleGroup` as a container of `Styles` (but, in fact, thanks to the conformance to a common `StyleProtocol`'s protocol your group may contains other sub-groups too).

```swift
let bodyStyle: Style = ...
let h1Style: Style = ...
let h2Style: Style = ...
let group = StyleGroup(base: bodyStyle, ["h1": h1Style, "h2": h2Style])
```

The following code defines a group where:

- we have defined a base style. Base style is the style applied to the entire string and can be used to provide a base ground of styles you want to apply to the string.
- we have defined two other styles named `h1` and `h2`; these styles are applied to the source string when parser encounter some text enclosed by these tags.

### String & Attributed String concatenation
SwiftRichString allows you to simplify string concatenation by providing custom `+` operator between `String`,`AttributedString` (typealias of `NSMutableAttributedString`) and `Style`.

This a an example:

```swift
let body: Style = Style { ... }
let big: Style = Style { ... }
let attributed: AttributedString = "hello ".set(style: body)

// the following code produce an attributed string by
// concatenating an attributed string and two plain string
// (one styled and another plain).
let attStr = attributed + "\(username)!".set(style:big) + ". You are welcome!"
```

You can also use `+` operator to add a style to a plain or attributed string:

```swift
// This produce an attributed string concatenating a plain
// string with an attributed string created via + operator
// between a plain string and a style
let attStr = "Hello" + ("\(username)" + big)
```

### Manually apply style to `String` and `Attributed String`

Both `String` and `Attributed String` (aka `NSMutableAttributedString`) has a come convenience methods you can use to create an manipulate attributed text easily via code:

#### Strings Instance Methods

- `set(style: String, range: NSRange? = nil)`: apply a globally registered style to the string (or a substring) by producing an attributed string.
- `set(styles: [String], range: NSRange? = nil)`: apply an ordered sequence of globally registered styles to the string (or a substring) by producing an attributed string.
- `set(style: StyleProtocol, range: NSRange? = nil)`: apply an instance of `Style` or `StyleGroup` (to render tag-based text) to the string (or a substring) by producting an attributed string.
- `set(styles: [StyleProtocol], range: NSRange? = nil)`: apply a sequence of `Style`/`StyleGroup` instance in order to produce a single attributes collection which will be applied to the string (or substring) to produce an attributed string.

Some examples:

```swift
// apply a globally registered style named MyStyle to the entire string
let a1: AttributedString = "Hello world".set(style: "MyStyle")

// apply a style group to the entire string
// commonStyle will be applied to the entire string as base style
// styleH1 and styleH2 will be applied only for text inside that tags.
let styleH1: Style = ...
let styleH2: Style = ...
let styleGroup = StyleGroup(base: commonStyle, ["h1" : styleH1, "h2" : styleH2])
let a2: AttributedString = "Hello <h1>world</h1>, <h2>welcome here</h2>".set(style: styleGroup)

// Apply a style defined via closure to a portion of the string
let a3 = "Hello Guys!".set(Style({ $0.font = SystemFonts.Helvetica_Bold.font(size: 20) }), range: NSMakeRange(0,4))
```

#### AttributedString Instance Methods

Similar methods are also available to attributed strings.

There are three categories of methods:

- `set` methods replace any existing attributes already set on target.
- `add` add attributes defined by style/styles list to the target
- `remove` remove attributes defined from the receiver string.

Each of this method alter the receiver instance of the attributed string and also return the same instance in output (so chaining is allowed).

**Add**

- `add(style: String, range: NSRange? = nil)`: add to existing style of string/substring a globally registered style with given name.
- `add(styles: [String], range: NSRange? = nil)`: add to the existing style of string/substring a style which is the sum of ordered sequences of globally registered styles with given names.
- `add(style: StyleProtocol, range: NSRange? = nil)`: append passed style instance to string/substring by altering the receiver attributed string.
- `add(styles: [StyleProtocol], range: NSRange? = nil)`: append passed styles ordered sequence to string/substring by altering the receiver attributed string.

**Set**

- `set(style: String, range: NSRange? = nil)`: replace any existing style inside string/substring with the attributes defined inside the globally registered style with given name.
- `set(styles: [String], range: NSRange? = nil)`: replace any existing style inside string/substring with the attributes merge of the ordered sequences of globally registered style with given names.
- `set(style: StyleProtocol, range: NSRange? = nil)`: replace any existing style inside string/substring with the attributes of the passed style instance.
- `set(styles: [StyleProtocol], range: NSRange? = nil)`: replace any existing style inside string/substring with the attributes of the passed ordered sequence of styles.

**Remove**

- `removeAttributes(_ keys: [NSAttributedStringKey], range: NSRange)`: remove attributes specified by passed keys from string/substring.
- `remove(_ style: StyleProtocol)`: remove attributes specified by the style from string/substring.

Example:

```swift
let a = "hello".set(style: styleA)
let b = "world!".set(style: styleB)
let ab = (a + b).add(styles: [coupondStyleA,coupondStyleB]).remove([.foregroundColor,.font])
```

### Derivating a `Style`

Sometimes you may need to infer properties of a new style from an existing one. In this case you can use `byAdding()` function of `Style` to produce a new style with all the properties of the receiver and the chance to configure additional/replacing attributes.

```swift
let initialStyle = Style {
	$0.font = SystemFonts.Helvetica_Light.font(size: 15)
	$0.alignment = right
}

// The following style contains all the attributes of initialStyle
// but also override the alignment and add a different foreground color.
let subStyle = bold.byAdding {
	$0.alignment = center
	$0.color = UIColor.red
}
``` 

## The `StyleManager`

### Register globally available styles
Styles can be created as you need or registered globally to be used once you need.
This second approach is strongly suggested because allows you to theme your app as you need and also avoid duplication of the code.

To register a `Style` or a `StyleGroup` globally you need to assign an unique identifier to it and call `register()` function via `Styles` shortcut (which is equal to call `StylesManager.shared`).

In order to keep your code type-safer you can use a non-instantiable struct to keep the name of your styles, then use it to register style:

```swift
// Define a struct with your styles names
public struct StyleNames {
	public static let body: String = "body"
	public static let h1: String = "h1"
	public static let h2: String = "h2"
	
	private init { }
}
```

Then you can:

```swift
let bodyStyle: Style = ...
Styles.register(StyleNames.body, bodyStyle)
```

Now you can use it everywhere inside the app; you can apply it to a text just using its name:

```swift
let text = "hello world".set(StyleNames.body)
```

or you can assign `body` string to the `styledText` via Interface Builder designable property.

### Defer style creation on demand
Sometimes you may need to return a particular style used only in small portion of your app; while you can still set it directly you can also defer its creation in `StylesManager`.

By implementing `onDeferStyle()` callback you have an option to create a new style once required: you will receive the identifier of the style.

```swift
Styles.onDeferStyle = { name in
			
	if name == "MyStyle" {
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
				
		return (StyleGroup(base: normal, ["bold": bold, "italic": italic]), true)
	}
			
	return (nil,false)
}
```
The following code return a valid style for `myStyle` identifier and cache it; if you don't want to cache it just return `false` along with style instance.

Now you can use your style to render, for example, a tag based text into an `UILabel`: just set the name of the style to use.

<img src="Documentation_Assests/image_3.png" alt="" style="width: 400px;"/>

## Fonts & Colors in `Style`
All colors and fonts you can set for a `Style` are wrapped by `FontConvertible` and `ColorConvertible` protocols.

SwiftRichString obviously implements these protocols for `UIColor`/`NSColor`, `UIFont`/`NSFont` but also for `String`.
For Fonts this mean you can assign a font by providing directly its PostScript name and it will be translated automatically to a valid instance:

```swift
let firaLight: UIFont = "FiraCode-Light".font(ofSize: 14)
...
...
let style = Style {
	$0.font = "Jura-Bold"
	$0.size = 24
	...
}
```

On UIKit you can also use the `SystemFonts` enum to pick from a type-safe auto-complete list of all available iOS fonts:

```swift
let font1 = SystemFonts.Helvetica_Light.font(size: 15)
let font2 = SystemFonts.Avenir_Black.font(size: 24)
```

For Color this mean you can create valid color instance from HEX strings:

```swift
let color: UIColor = "#0433FF".color
...
...
let style = Style {
	$0.color = "#0433FF"
	...
}
```

Clearly you can still pass instances of both colors/fonts.


## Assign style using Interface Builder
SwiftRichString can be used also via Interface Builder; `UILabel`, `UITextView` and `UIButton` has a `styleName` property you can set with a globally registered style.

Assigned style can be a `Style` or a `StyleGroup`:

- if style is a `Style` the entire text of the control is set with the attributes defined by the style.
- if style is a `StyleGroup` a base attribute is set (if `base` is set) and other attributes are applied once each tag is found.

## Properties available via `Style` class
The following properties are available:

| PROPERTY                      | TYPE                                  | DESCRIPTION                                                                                                                                | 
|-------------------------------|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------| 
| size                          | CGFloat                               | font size in points                                                                                                                        | 
| font                          | FontConvertible                       | font used in text                                                                                                                          | 
| color                         | ColorConvertible                      | foreground color of the text                                                                                                               | 
| backColor                     | ColorConvertible                      | background color of the text                                                                                                               | 
| underline                     | (NSUnderlineStyle?,ColorConvertible?) | underline style and color (if color is nil foreground is used)                                                                             | 
| strikethrough                 | (NSUnderlineStyle?,ColorConvertible?) | strikethrough style and color (if color is nil foreground is used)                                                                         | 
| baselineOffset                | Float                                 | character’s offset from the baseline, in point                                                                                             | 
| paragraph                     | NSMutableParagraphStyle               | paragraph attributes                                                                                                                       | 
| lineSpacing                   | CGFloat                               | distance in points between the bottom of one line fragment and the top of the next                                                         | 
| paragraphSpacingBefore        | CGFloat                               | distance between the paragraph’s top and the beginning of its text content                                                                 | 
| paragraphSpacingAfter         | CGFloat                               | space (measured in points) added at the end of the paragraph                                                                               | 
| alignment                     | NSTextAlignment                       | text alignment of the receiver                                                                                                             | 
| firstLineHeadIndent           | CGFloat                               | distance (in points) from the leading margin of a text container to the beginning of the paragraph’s first line.                           | 
| headIndent                    | CGFloat                               | The distance (in points) from the leading margin of a text container to the beginning of lines other than the first.                       | 
| tailIndent                    | CGFloat                               | this value is the distance from the leading margin, If 0 or negative, it’s the distance from the trailing margin.                          | 
| lineBreakMode                 | LineBreak                             | mode that should be used to break lines                                                                                                    | 
| minimumLineHeight             | CGFloat                               | minimum height in points that any line in the receiver will occupy regardless of the font size or size of any attached graphic             | 
| maximumLineHeight             | CGFloat                               | maximum height in points that any line in the receiver will occupy regardless of the font size or size of any attached graphic             | 
| baseWritingDirection          | NSWritingDirection                    | initial writing direction used to determine the actual writing direction for text                                                          | 
| lineHeightMultiple            | CGFloat                               | natural line height of the receiver is multiplied by this factor (if positive) before being constrained by minimum and maximum line height | 
| hyphenationFactor             | Float                                 | threshold controlling when hyphenation is attempted                                                                                        | 
| ligatures                     | Ligatures                             | Ligatures cause specific character combinations to be rendered using a single custom glyph that corresponds to those characters            | 
| speaksPunctuation             | Bool                                  | Enable spoken of all punctuation in the text                                                                                               | 
| speakingLanguage              | String                                | The language to use when speaking a string (value is a BCP 47 language code string).                                                       | 
| speakingPitch                 | Double                                | Pitch to apply to spoken content                                                                                                           | 
| speakingPronunciation         | String                                |                                                                                                                                            | 
| shouldQueueSpeechAnnouncement | Bool                                  | Spoken text is queued behind, or interrupts, existing spoken content                                                                       | 
| headingLevel                  | HeadingLevel                          | Specify the heading level of the text                                                                                                      | 
| numberCase                    | NumberCase                            | "Configuration for the number case, also known as ""figure style"""                                                                        | 
| numberSpacing                 | NumberSpacing                         | "Configuration for number spacing, also known as ""figure spacing"""                                                                       | 
| fractions                     | Fractions                             | Configuration for displyaing a fraction                                                                                                    | 
| superscript                   | Bool                                  | Superscript (superior) glpyh variants are used, as in footnotes_.                                                                          | 
| `subscript`                   | Bool                                  | Subscript (inferior) glyph variants are used: v_.                                                                                          | 
| ordinals                      | Bool                                  | Ordinal glyph variants are used, as in the common typesetting of 4th.                                                                      | 
| scientificInferiors           | Bool                                  | Scientific inferior glyph variants are used: H_O                                                                                           | 
| smallCaps                     | Set<SmallCaps>                        | Configure small caps behavior.                                                                                                             | 
| stylisticAlternates           | StylisticAlternates                   | Different stylistic alternates available for customizing a font.                                                                           | 
| contextualAlternates          | ContextualAlternates                  | Different contextual alternates available for customizing a font.                                                                          | 
| kerning                       | Kerning                               | Tracking to apply.                                                                                                                         | 
| traitVariants                 | TraitVariant                          | Describe trait variants to apply to the font                                                                                               | 


## Requirements

Repeat is compatible with Swift 4.x.
All Apple platforms are supported:

* iOS 8.0+
* macOS 10.9+
* watchOS 2.0+
* tvOS 9.0+

## Installation

<a name="cocoapods" />

### Install via CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like Repeat in your projects. You can install it with the following command:

```bash
$ sudo gem install cocoapods
```

> CocoaPods 1.0.1+ is required to build Repeat.

#### Install via Podfile

To integrate Repeat into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
use_frameworks!
pod 'SwiftRichString'
end
```

Then, run the following command:

```bash
$ pod install
```

<a name="carthage" />

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate SwiftRichString into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "malcommac/SwiftRichString"
```

Run `carthage` to build the framework and drag the built `SwiftRichString.framework` into your Xcode project.




