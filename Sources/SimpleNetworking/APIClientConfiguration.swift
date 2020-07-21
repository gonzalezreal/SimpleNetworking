//
// APIClientConfiguration.swift
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

/// Defines additional headers and query parameters for an `APIClient`.
///
/// An `APIClientConfiguration` instance contains additional headers and query
/// parameters that will be appended to each request made by an `APIClient`.
///
/// For example, a configuration that contains `"api_key"`and `"language"` parameters
/// can be created like this:
///
///     let configuration = APIClientConfiguration(
///         additionalParameters: [
///             "api_key": "20495f04-1a8c-4fd0-a9a5-aac8752afc86",
///             "language": "es",
///         ]
///     )
public struct APIClientConfiguration {
    public var additionalHeaders: [HeaderField: String]
    public var additionalParameters: [String: CustomStringConvertible]

    public init(
        additionalHeaders: [HeaderField: String] = [:],
        additionalParameters: [String: CustomStringConvertible] = [:]
    ) {
        self.additionalHeaders = additionalHeaders
        self.additionalParameters = additionalParameters
    }
}
