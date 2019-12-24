//
//  SwiftRichString
//  Elegant Strings & Attributed Strings Toolkit for Swift
//
//  Created by Daniele Margutti.
//  Copyright © 2018 Daniele Margutti. All rights reserved.
//
//    Web: http://www.danielemargutti.com
//    Email: hello@danielemargutti.com
//    Twitter: @danielemargutti
//
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

import Foundation

public enum TextTransform {
    public typealias TransformFunction = (String) -> String
    
    case lowercase
    case uppercase
    case capitalized
    
    case lowercaseWithLocale(Locale)
    case uppercaseWithLocale(Locale)
    case capitalizedWithLocale(Locale)
    case custom(TransformFunction)
    
    var transformer: TransformFunction {
        switch self {
            case .lowercase:
                return { string in
                    if #available(iOS 9.0, iOSApplicationExtension 9.0, *) {
                        return string.localizedLowercase
                    } else {
                        return string.lowercased(with: Locale.current)
                    }
                }
            
            case .uppercase:
                return { string in
                    if #available(iOS 9.0, iOSApplicationExtension 9.0, *) {
                        return string.localizedUppercase
                    } else {
                        return string.uppercased(with: Locale.current)
                    }
                }
            
            case .capitalized:
                return { string in
                    if #available(iOS 9.0, iOSApplicationExtension 9.0, *) {
                        return string.localizedCapitalized
                    } else {
                        return string.capitalized(with: Locale.current)
                    }
                }
            
            case .lowercaseWithLocale(let locale):
                return { string in
                    string.lowercased(with: locale)
                }
            
            case .uppercaseWithLocale(let locale):
                return { string in
                    string.uppercased(with: locale)
                }
            
            case .capitalizedWithLocale(let locale):
                return { string in
                    string.capitalized(with: locale)
                }
            
            case .custom(let transform):
                return transform
        }
    }
    
}
