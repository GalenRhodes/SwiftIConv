/*===============================================================================================================================================================================*
 *     PROJECT: SwiftIConv
 *    FILENAME: Tools.swift
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

typealias RecursiveLock = NSRecursiveLock
typealias MutexLock = NSLock
typealias Conditional = NSCondition

extension RecursiveLock {
    @inlinable func tryLock() -> Bool { `try`() }

    @inlinable func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }

    @inlinable func withLock<T>(before date: Date, _ body: () throws -> T) rethrows -> T? {
        guard lock(before: date) else { return nil }
        defer { unlock() }
        return try body()
    }

    @inlinable func withTryLock<T>(_ body: () throws -> T) rethrows -> T? {
        guard tryLock() else { return nil }
        defer { unlock() }
        return try body()
    }
}

extension MutexLock {
    @inlinable func tryLock() -> Bool { `try`() }

    @inlinable func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }

    @inlinable func withLock<T>(before date: Date, _ body: () throws -> T) rethrows -> T? {
        guard lock(before: date) else { return nil }
        defer { unlock() }
        return try body()
    }

    @inlinable func withTryLock<T>(_ body: () throws -> T) rethrows -> T? {
        guard tryLock() else { return nil }
        defer { unlock() }
        return try body()
    }
}

extension Conditional {

    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { bcastUnlock() }
        return try body()
    }

    func withLockWait<T>(broadcastBeforeWait bcast: Bool = true, _ cond: () -> Bool, do body: () throws -> T) rethrows -> T {
        try withLock {
            while !cond() { bcastWait(willBroadcast: bcast) }
            return try body()
        }
    }

    func withLockWait(broadcastBeforeWait bcast: Bool = true, _ cond: () -> Bool) {
        withLock { while !cond() { bcastWait(willBroadcast: bcast) } }
    }

    func withLockWait<T>(until limit: Date, broadcastBeforeWait bcast: Bool = true, _ cond: () -> Bool, do body: () throws -> T) rethrows -> T? {
        try withLock { try (cond() ? body() : (bcastWait(until: limit, willBroadcast: bcast) ? (cond() ? body() : nil) : nil)) }
    }

    func withLockWait(until limit: Date, broadcastBeforeWait bcast: Bool = true, _ cond: () -> Bool) -> Bool {
        withLock { (cond() ? true : (bcastWait(until: limit, willBroadcast: bcast) ? cond() : false)) }
    }

    private func bcastUnlock() {
        broadcast()
        unlock()
    }

    @inlinable @discardableResult func broadcastWait(until limit: Date? = nil) -> Bool {
        bcastWait(until: limit, willBroadcast: true)
    }

    @discardableResult @usableFromInline func bcastWait(until limit: Date? = nil, willBroadcast bcast: Bool = true) -> Bool {
        if bcast { broadcast() }
        if let limit = limit { return wait(until: limit) }
        wait()
        return true
    }
}

/// Which
///
/// - Parameter names: The programs to look for.
/// - Returns: The paths to the programs. If any program couldn't be found then that entry is `nil`.
///
public func which(names: [String]) -> [String?] {
    let ncc: Int = names.count
    guard ncc > 0 else { return [] }

    var txt: String    = ""
    var err: String    = ""
    var out: [String?] = []

    for n in names {
        if n.hasPrefix("/") || n.hasPrefix("-") {
            out.append(nil)
        }
        else {
            #if os(Windows)
                let result: Int = execute(exec: "where", args: [ n ], stdout: &txt, stderr: &err)
            #else
                let result: Int = execute(exec: "/bin/bash", args: [ "-c", "which \"\(n)\"" ], stdout: &txt, stderr: &err)
            #endif
            if result == 0 {
                let item: String = txt.split(on: "(?:\\r\\n?|\\n)")[0]
                out.append(item.trimmed.isEmpty ? nil : item)
            }
            else {
                out.append(nil)
            }
        }
    }

    return out
}

/// Which
///
/// - Parameter name: The program to look for.
/// - Returns: The path to the program or `nil` if it couldn't be found.
///
@inlinable public func which(name: String) -> String? { which(names: [ name ])[0] }

extension String {
    var trimmed:   String { self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).trimmingCharacters(in: CharacterSet.controlCharacters) }
    var fullRange: Range<String.Index> { startIndex ..< endIndex }

    func split(on pattern: String) -> [String] {
        do {
            let rx:  NSRegularExpression = try NSRegularExpression(pattern: pattern)
            var idx: String.Index        = startIndex
            var arr: [String]            = []

            rx.enumerateMatches(in: self, range: NSRange(fullRange, in: self)) { r, _, _ in
                if let r = r {
                    if let rn: Range<String.Index> = Range<String.Index>(r.range, in: self) {
                        arr.append(String(self[idx ..< rn.lowerBound]))
                        idx = rn.upperBound
                    }
                }
            }

            arr.append(String(self[idx ..< endIndex]))
            return arr
        }
        catch {
            return [ self ]
        }
    }
}
