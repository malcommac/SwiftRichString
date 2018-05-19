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

Now you can reuse it everything in your app; SwiftRichString exposes a `styleText` property for the most common text containers and you can set it directly in Interface Builder:

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

## Documentation

- What's `Style`/`StyleGroup` and how to use them
- Properties available via `Style` class
- How to use styles globally with `StyleManager`
- Operation with styles
- Concatenation of strings & attributed strings
- Integration with Interface Builder
- Fonts & Colors
- Other tips
- Compatibility
- Installation
- Copyright

### What's `Style`/`StyleGroup` and how to use them

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



