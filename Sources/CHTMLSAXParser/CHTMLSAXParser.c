//
//  CHTMLSAXParser.c
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

#include <stdio.h>
#include <stdarg.h>
#include "CHTMLSAXParser.h"

HTMLParserWrappedErrorSAXFunc htmlparser_global_error_sax_func;
HTMLParserWrappedWarningSAXFunc htmlparser_global_warning_sax_func;

static char* formatstr(const char *format, va_list args) {
    int consumed = 0;
    size_t buffer_size = 0;
    char *buffer = NULL;
    va_list vl;

    do {
        if (consumed > buffer_size) {
            buffer_size = consumed + 1; // Add 1 for the null character
        }
        else {
            buffer_size += 100;
        }
        buffer = realloc(buffer, buffer_size);

        // Check buffer is not null in case malloc / realloc failed.
        if (buffer != NULL) {
            va_copy(vl, args);
            consumed = vsnprintf(buffer, buffer_size, format, vl);
            va_end(vl);
        }
    } while (buffer != NULL && consumed > 0 && consumed >= buffer_size);

    if (buffer != NULL) {
        if (consumed > 0 && consumed < buffer_size) {
            return buffer;
        }

        free(buffer);
    }

    return NULL;
}

/**
 The global error handling function for the module. This function will format the
 message into a single string before calling the wrapped error function.
 */
static void htmlparser_error_sax_handler(void *ctx, const char *msg, ...) {
    va_list vl;
    char *formatted_msg = NULL;

    if (htmlparser_global_error_sax_func == NULL) {
        return;
    }

    va_start(vl, msg);
    formatted_msg = formatstr(msg, vl);
    va_end(vl);

    htmlparser_global_error_sax_func(ctx, formatted_msg);

    if (formatted_msg != NULL) {
        free(formatted_msg);
    }
}

static void htmlparser_warning_sax_handler(void *ctx, const char *msg, ...) {
    va_list vl;
    char *formatted_msg = NULL;

    if (htmlparser_global_warning_sax_func == NULL) {
        return;
    }

    va_start(vl, msg);
    formatted_msg = formatstr(msg, vl);
    va_end(vl);

    htmlparser_global_warning_sax_func(ctx, formatted_msg);

    if (formatted_msg != NULL) {
        free(formatted_msg);
    }
}

void htmlparser_set_global_error_handler(htmlSAXHandlerPtr sax_handler) {
    if (sax_handler != NULL) {
        sax_handler->error = htmlparser_error_sax_handler;
    }
}

void htmlparser_set_global_warning_handler(htmlSAXHandlerPtr sax_handler) {
    if (sax_handler != NULL) {
        sax_handler->warning = htmlparser_warning_sax_handler;
    }
}
