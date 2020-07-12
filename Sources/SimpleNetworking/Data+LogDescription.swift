//
// Data+LogDescription.swift
//
// Copyright (c) 2020 Guille Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

public extension Data {
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
    var logDescription: String {
        String(data: prettyPrintedJSON ?? self, encoding: .utf8).map {
            $0.components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
                .map { "  \($0)" }
                .joined(separator: "\n")
        } ?? ""
    }
}

private extension Data {
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
    var prettyPrintedJSON: Data? {
        (try? JSONSerialization.jsonObject(with: self, options: [])).flatMap {
            try? JSONSerialization.data(withJSONObject: $0, options: [.prettyPrinted, .sortedKeys])
        }
    }
}
