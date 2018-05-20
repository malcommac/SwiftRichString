<p align="center" >
  <img src="https://raw.githubusercontent.com/malcommac/SwiftRichString/develop/logo.png" width=210px height=204px alt="SwiftRichString" title="SwiftRichString">
</p>

## CHANGELOG

* Version **[2.0.1](#201)**

* Version **[1.1.0](#101)** (for Swift 4)
* Version **[1.0.1](#101)** (for Swift 4)
* Version **[0.9.10](#0910)** (Latest Swift 3.x compatible version)
* Version **[0.9.9](#099)**
* Version **[0.9.8](#097)**
* Version **[0.9.5](#095)**

<a name="200" />

## SwiftRichString 2.0.1
---
- **Release Date**: 2018-05-20
- **Zipped Version**: [Download 2.0.1](https://github.com/malcommac/SwiftRichString/releases/tag/2.0.1)

This is a total rewrite of the library to simplify and consolidate the APIs functionalities. See documentation in README for detailed informations.


<a name="110" />

## SwiftRichString 1.1.0
---
- **Release Date**: 2017-12-28
- **Zipped Version**: [Download 1.1.0](https://github.com/malcommac/SwiftRichString/releases/tag/1.1.0)

* [#26](https://github.com/malcommac/SwiftRichString/issues/26) Fixed an issue when parsing `<br>` in `MarkupString` class
* [#29](https://github.com/malcommac/SwiftRichString/issues/29) Fixed several warnings coming to Swift 4

<a name="101" />

## SwiftRichString 1.0.1
---
- **Release Date**: 2017-09-14
- **Zipped Version**: [Download 1.0.0](https://github.com/malcommac/SwiftRichString/releases/tag/1.0.0)

This is the first version compatible with Swift 4.

<a name="0910" />

## SwiftRichString 0.9.10
---
- **Release Date**: 2017-09-18
- **Zipped Version**: [Download 0.9.10](https://github.com/malcommac/SwiftRichString/releases/tag/0.9.10)

Fix minor issue compiling with Xcode 9 and Swift 3.2

<a name="099" />

## SwiftRichString 0.9.9
---
- **Release Date**: 2017-07-06
- **Zipped Version**: [Download 0.9.9](https://github.com/malcommac/SwiftRichString/releases/tag/0.9.8)

- [#18](https://github.com/malcommac/SwiftRichString/issues/18) Added `renderTags(withStyles:)` func in `String` extension. It will a shortcut to parse an html-tagged string and return the `NSMutableAttributedString` instance.
- [#19](https://github.com/malcommac/SwiftRichString/issues/19) `MarkupString` classes does not `throws` anymore; when parsing fails to invalid strings it will return `nil`.
- [#5](https://github.com/malcommac/SwiftRichString/issues/5) A new function is added to parse multiple regular expressions and apply to each one one or more styles. It's called `func set(regExpStyles: [RegExpPatternStyles], default dStyle: Style? = nil) -> NSMutableAttributedString` and accepts an array of `RegExpPatternStyles` structs (which defines the regexp rule, options and and array of `Style` to apply on match). `default` parameter allows you to set a default style to apply before rules are evaluated.
- [#2](https://github.com/malcommac/SwiftRichString/issues/2) Resolved an issue with CocoaPods
- [#20](https://github.com/malcommac/SwiftRichString/issues/20) Added compatibility with `watchOS`, `tvOS` and `macOS`.


<a name="098" />

## SwiftRichString 0.9.8
---
- **Release Date**: 2017-04-02
- **Zipped Version**: [Download 0.9.8](https://github.com/malcommac/SwiftRichString/releases/tag/0.9.8)

- [#4] Added `set(stylesArray:)` with func in `String` extension

<a name="095" />

## SwiftRichString 0.9.5
---
- **Release Date**: 2017-03-01
- **Zipped Version**: [Download 0.9.5](https://github.com/malcommac/SwiftRichString/releases/tag/0.9.5)

- [#4](https://github.com/malcommac/SwiftRichString/pull/4) Added support for `.writingDirection`
