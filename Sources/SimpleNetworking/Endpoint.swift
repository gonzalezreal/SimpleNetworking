//
// Endpoint.swift
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

public struct Endpoint<Output> {
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    public let method: Method
    public let path: String
    public let headers: [HeaderField: String]
    public let queryParameters: [String: String]
    public let body: Data?
    public let output: (Data) throws -> Output
}

public extension Endpoint where Output: Decodable {
    init(
        method: Method,
        path: String,
        headers: [HeaderField: String] = [:],
        queryParameters: [String: String] = [:],
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) {
        self.init(
            method: method,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            queryParameters: queryParameters,
            body: nil,
            output: decode(with: dateDecodingStrategy)
        )
    }

    init<Input>(
        method: Method,
        path: String,
        headers: [HeaderField: String] = [:],
        body: Input,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) where Input: Encodable {
        self.init(
            method: method,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            queryParameters: [:],
            body: try! encode(body, with: dateEncodingStrategy),
            output: decode(with: dateDecodingStrategy)
        )
    }
}

public extension Endpoint where Output == Void {
    init<Input>(
        method: Method,
        path: String,
        headers: [HeaderField: String] = [:],
        body: Input,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate
    ) where Input: Encodable {
        self.init(
            method: method,
            path: path,
            headers: [.contentType: ContentType.json.rawValue].merging(headers) { _, new in new },
            queryParameters: [:],
            body: try! encode(body, with: dateEncodingStrategy),
            output: { _ in () }
        )
    }
}

private func decode<Output: Decodable>(
    with dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
) -> (Data) throws -> Output {
    { data in
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        return try decoder.decode(Output.self, from: data)
    }
}

private func encode<Input: Encodable>(
    _ body: Input, with dateEncodingStrategy: JSONEncoder.DateEncodingStrategy
) throws -> Data {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = dateEncodingStrategy

    return try encoder.encode(body)
}
