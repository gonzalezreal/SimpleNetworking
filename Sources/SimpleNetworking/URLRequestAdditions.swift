//
// URLRequestAdditions.swift
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

extension URLRequest {
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
    internal var logDescription: String {
        var result = "[REQUEST] \(httpMethod!) \(url!)"

        if let logDescription = allHTTPHeaderFields?.logDescription, !logDescription.isEmpty {
            result += "\n ├─ Headers\n\(logDescription)"
        }

        if let logDescription = httpBody?.logDescription, !logDescription.isEmpty {
            result += "\n ├─ Body\n\(logDescription)"
        }

        return result
    }

    public init<Output>(baseURL: URL, endpoint: Endpoint<Output>) {
        let url = baseURL.appendingPathComponent(endpoint.path)

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        if !endpoint.queryParameters.isEmpty {
            components.queryItems = endpoint.queryParameters.sorted { $0.key < $1.key }.map(URLQueryItem.init)
        }

        self.init(url: components.url!)

        httpMethod = endpoint.method.rawValue
        httpBody = endpoint.body

        for (field, value) in endpoint.headers {
            addValue(value, forHTTPHeaderField: field.rawValue)
        }
    }

    public func addingQueryParameters(_ parameters: [String: String]) -> URLRequest {
        guard !parameters.isEmpty else { return self }

        var components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!

        let queryItems = (components.queryItems ?? []) + parameters.map(URLQueryItem.init)
        components.queryItems = queryItems.sorted { $0.name < $1.name }

        var result = self
        result.url = components.url

        return result
    }

    public func addingHeaders(_ headers: [HeaderField: String]) -> URLRequest {
        guard !headers.isEmpty else { return self }

        var result = self

        for (field, value) in headers {
            result.addValue(value, forHTTPHeaderField: field.rawValue)
        }

        return result
    }
}
