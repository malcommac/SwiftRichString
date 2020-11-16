//
//  CHTMLSAXParser.h
//  HTMLSAXParser
//
//  Created by Raymond Mccrae on 31/07/2017.
//  Copyright © 2017 Raymond McCrae.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <libxml/SAX2.h>
#import <libxml/HTMLparser.h>
#import <libxml/xmlerror.h>

#ifndef CHTMLSAXParser_h
#define CHTMLSAXParser_h

typedef void(*HTMLParserWrappedErrorSAXFunc)(void *ctx, const char *msg);
typedef void(*HTMLParserWrappedWarningSAXFunc)(void *ctx, const char *msg);

/**
 htmlparser_global_error_sax_func is a global function pointer to a wrapper for a variadic c function
 for handling libxml2 parsing error. This is used since Swift does not support C variadic fuctions,
 (only va_list fuctions are supported). This global variable is used in conjuction with the function
 htmlparser_set_global_error_handler to install the global paser error function which forwards to
 the function this global variable points to.

 This global is only intended to ever be set once and before any parsing has been initiated.
 */
extern HTMLParserWrappedErrorSAXFunc htmlparser_global_error_sax_func;

/**
 htmlparser_global_warning_sax_func is a global function pointer to a wrapper for a variadic c function
 for handling libxml2 parsing warnings. This is used since Swift does not support C variadic fuctions,
 (only va_list fuctions are supported). This global variable is used in conjuction with the function
 htmlparser_set_global_warning_handler to install the global paser warning function which forwards to
 the function this global variable points to.

 This global is only intended to ever be set once and before any parsing has been initiated.
 */
extern HTMLParserWrappedWarningSAXFunc htmlparser_global_warning_sax_func;

/**
 Sets the error handler for the htmlSAXHander struct to a global error handling function that
 in turn forwards to the function pointed to by htmlparser_global_error_sax_func.
 This layer of indirections is used to overcome Swifts lack of handling for C variadic fuctions.

 The global error handling function will process the format string and variable arguments into
 a single string for the wrapped error function.
 */
void htmlparser_set_global_error_handler(htmlSAXHandlerPtr sax_handler);

/**
 Sets the warning handler for the htmlSAXHander struct to a global warning handling function that
 in turn forwards to the function pointed to by htmlparser_global_warning_sax_func.
 This layer of indirections is used to overcome Swifts lack of handling for C variadic fuctions.

 The global warning handling function will process the format string and variable arguments into
 a single string for the wrapped warning function.
 */
void htmlparser_set_global_warning_handler(htmlSAXHandlerPtr sax_handler);

#endif /* CHTMLSAXParser_h */
