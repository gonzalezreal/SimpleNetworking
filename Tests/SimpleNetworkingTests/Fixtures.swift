//
// Fixtures.swift
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

struct User: Equatable, Codable {
    let name: String
}

struct Error: Equatable, Codable {
    let message: String
}

enum Fixtures {
    static let anyBaseURL = URL(string: "https://example.com")!
    static let anyUser = User(name: "gonzalezreal")
    static let anyValidResponse = try! JSONEncoder().encode(anyUser)
    static let anyError = Error(message: "The resource you requested could not be found.")

    static func anyURLWithPath(_ path: String, query: String? = nil) -> URL {
        let url = anyBaseURL.appendingPathComponent(path)

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.query = query

        return components.url!
    }
}
