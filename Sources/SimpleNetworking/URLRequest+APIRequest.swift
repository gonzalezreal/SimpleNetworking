//
// URLRequest+APIRequest.swift
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

    /// Initializes a `URLRequest` using a base URL and an API request.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL to which the API request path is appended.
    ///   - apiRequest: The API request that specifies the query parameters, headers and body for the request.
    ///
    public init<Output, Error>(baseURL: URL, apiRequest: APIRequest<Output, Error>) {
        let url = baseURL.appendingPathComponent(apiRequest.path)

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        if !apiRequest.parameters.isEmpty {
            components.queryItems = apiRequest.parameters.sorted { $0.key < $1.key }.map { name, value in
                URLQueryItem(name: name, value: value.description)
            }
        }

        self.init(url: components.url!)

        httpMethod = apiRequest.method.rawValue
        httpBody = apiRequest.body

        for (field, value) in apiRequest.headers {
            addValue(value, forHTTPHeaderField: field.rawValue)
        }
    }

    /// Returns a new URL request by adding the given query parameters to this request.
    public func addingParameters(_ parameters: [String: CustomStringConvertible]) -> URLRequest {
        guard !parameters.isEmpty else { return self }

        var components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!

        let queryItems = (components.queryItems ?? []) + parameters.map { name, value in
            URLQueryItem(name: name, value: value.description)
        }

        components.queryItems = queryItems.sorted { $0.name < $1.name }

        var result = self
        result.url = components.url

        return result
    }

    /// Returns a new URL request by adding the given headers to this request.
    public func addingHeaders(_ headers: [HeaderField: String]) -> URLRequest {
        guard !headers.isEmpty else { return self }

        var result = self

        for (field, value) in headers {
            result.addValue(value, forHTTPHeaderField: field.rawValue)
        }

        return result
    }
}
