/*===============================================================================================================================================================================*
 *     PROJECT: SwiftIConv
 *    FILENAME: IConvHandle.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: May 16, 2022
 *
 * Copyright © 2022. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *===============================================================================================================================================================================*/

import Foundation
import CoreFoundation
#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(WinSDK)
    import WinSDK
#endif

#if !os(Windows)
    #if os(Linux) || os(Android) || os(WASI)
        import iconv
    #endif

    @propertyWrapper public struct IConvHandle {
        public var  wrappedValue: iconv_t? {
            get { value }
            set { value = ((newValue == (iconv_t)(bitPattern: -1)) ? nil : newValue) }
        }
        private var value:        iconv_t? = nil

        public init(wrappedValue: iconv_t?) { self.wrappedValue = wrappedValue }
    }

#endif
