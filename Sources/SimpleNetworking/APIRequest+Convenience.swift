//
// APIRequest+Convenience.swift
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

public extension APIRequest where Output: Decodable, Error: Decodable {
    /// Creates a `GET` request.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - parameters: The parameters that are passed with the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode valid and error responses.
    /// - Returns: A `GET` API request.
    ///
    /// This method uses the provided JSON decoder to decode valid and error responses for the request,
    /// making possible to create API requests in a much nicer way:
    ///
    ///     let popularMovies = APIRequest<Page, Status>.get(
    ///         "/movie/popular",
    ///         parameters: ["page": 1]
    ///     )
    ///
    /// Notice that this initializer automatically adds the `"Accept: application/json"` header to
    /// the request.
    ///
    static func get(
        _ path: String,
        headers: [HeaderField: String] = [:],
        parameters: [String: CustomStringConvertible] = [:],
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> APIRequest {
        APIRequest(
            method: .get,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            parameters: parameters,
            body: nil,
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `POST` request.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - parameters: The parameters that are passed with the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode valid and error responses.
    /// - Returns: A `POST` API request.
    ///
    /// This method uses the provided JSON decoder to decode valid and error responses for the request.
    ///
    /// Notice that this initializer automatically adds the `"Accept: application/json"` header to
    /// the request.
    ///
    static func post(
        _ path: String,
        headers: [HeaderField: String] = [:],
        parameters: [String: CustomStringConvertible] = [:],
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> APIRequest {
        APIRequest(
            method: .post,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            parameters: parameters,
            body: nil,
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `POST` request with a body payload.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - body: The `Encodable` body payload for the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode valid and error responses.
    ///   - jsonEncoder: The JSON encoder that is  used to encode the `body` parameter.
    /// - Returns: A `POST` API request.
    ///
    /// Notice that this initializer automatically adds the `"Content-Type: application/json"`
    /// and `"Accept: application/json"` headers to the request.
    ///
    static func post<Body>(
        _ path: String,
        headers: [HeaderField: String] = [:],
        body: Body,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws -> APIRequest where Body: Encodable {
        APIRequest(
            method: .post,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            parameters: [:],
            body: try jsonEncoder.encode(body),
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `PUT` request.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - parameters: The parameters that are passed with the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode valid and error responses.
    /// - Returns: A `PUT` API request.
    ///
    /// This method uses the provided JSON decoder to decode valid and error responses for the request.
    ///
    /// Notice that this initializer automatically adds the `"Accept: application/json"` header to
    /// the request.
    ///
    static func put(
        _ path: String,
        headers: [HeaderField: String] = [:],
        parameters: [String: CustomStringConvertible] = [:],
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> APIRequest {
        APIRequest(
            method: .put,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            parameters: parameters,
            body: nil,
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `PUT` request with a body payload.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - body: The `Encodable` body payload for the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode valid and error responses.
    ///   - jsonEncoder: The JSON encoder that is  used to encode the `body` parameter.
    /// - Returns: A `PUT` API request.
    ///
    /// Notice that this initializer automatically adds the `"Content-Type: application/json"`
    /// and `"Accept: application/json"` headers to the request.
    ///
    static func put<Body>(
        _ path: String,
        headers: [HeaderField: String] = [:],
        body: Body,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws -> APIRequest where Body: Encodable {
        APIRequest(
            method: .put,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            parameters: [:],
            body: try jsonEncoder.encode(body),
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `DELETE` request.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - parameters: The parameters that are passed with the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode valid and error responses.
    /// - Returns: A `DELETE` API request.
    ///
    /// This method uses the provided JSON decoder to decode valid and error responses for the request.
    ///
    /// Notice that this initializer automatically adds the `"Accept: application/json"` header to
    /// the request.
    ///
    static func delete(
        _ path: String,
        headers: [HeaderField: String] = [:],
        parameters: [String: CustomStringConvertible] = [:],
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> APIRequest {
        APIRequest(
            method: .delete,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            parameters: parameters,
            body: nil,
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `DELETE` request with a body payload.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - body: The `Encodable` body payload for the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode valid and error responses.
    ///   - jsonEncoder: The JSON encoder that is  used to encode the `body` parameter.
    /// - Returns: A `DELETE` API request.
    ///
    /// Notice that this initializer automatically adds the `"Content-Type: application/json"`
    /// and `"Accept: application/json"` headers to the request.
    ///
    static func delete<Body>(
        _ path: String,
        headers: [HeaderField: String] = [:],
        body: Body,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws -> APIRequest where Body: Encodable {
        APIRequest(
            method: .delete,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            parameters: [:],
            body: try jsonEncoder.encode(body),
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }
}

public extension APIRequest where Output == Void, Error: Decodable {
    /// Creates a `POST` request.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - parameters: The parameters that are passed with the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode error responses.
    /// - Returns: A `POST` API request.
    ///
    /// This method uses the provided JSON decoder to decode error responses for the request.
    ///
    static func post(
        _ path: String,
        headers: [HeaderField: String] = [:],
        parameters: [String: CustomStringConvertible] = [:],
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> APIRequest {
        APIRequest(
            method: .post,
            path: path,
            headers: headers,
            parameters: parameters,
            body: nil,
            output: { _ in () },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `POST` request with a body payload.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - body: The `Encodable` body payload for the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode error responses.
    ///   - jsonEncoder: The JSON encoder that is  used to encode the `body` parameter.
    /// - Returns: A `POST` API request.
    ///
    /// This method automatically adds the `"Content-Type: application/json"` header to the request.
    ///
    static func post<Body>(
        _ path: String,
        headers: [HeaderField: String] = [:],
        body: Body,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws -> APIRequest where Body: Encodable {
        APIRequest(
            method: .post,
            path: path,
            headers: [
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            parameters: [:],
            body: try jsonEncoder.encode(body),
            output: { _ in () },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `PUT` request.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - parameters: The parameters that are passed with the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode error responses.
    /// - Returns: A `PUT` API request.
    ///
    /// This method uses the provided JSON decoder to decode error responses for the request.
    ///
    static func put(
        _ path: String,
        headers: [HeaderField: String] = [:],
        parameters: [String: CustomStringConvertible] = [:],
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> APIRequest {
        APIRequest(
            method: .put,
            path: path,
            headers: headers,
            parameters: parameters,
            body: nil,
            output: { _ in () },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `PUT` request with a body payload.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - body: The `Encodable` body payload for the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode valid and error responses.
    ///   - jsonEncoder: The JSON encoder that is  used to encode the `body` parameter.
    /// - Returns: A `PUT` API request.
    ///
    /// This method automatically adds the `"Content-Type: application/json"` header to the request.
    ///
    static func put<Body>(
        _ path: String,
        headers: [HeaderField: String] = [:],
        body: Body,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws -> APIRequest where Body: Encodable {
        APIRequest(
            method: .put,
            path: path,
            headers: [
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            parameters: [:],
            body: try jsonEncoder.encode(body),
            output: { _ in () },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `DELETE` request.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - parameters: The parameters that are passed with the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode error responses.
    /// - Returns: A `DELETE` API request.
    ///
    /// This method uses the provided JSON decoder to decode error responses for the request.
    ///
    static func delete(
        _ path: String,
        headers: [HeaderField: String] = [:],
        parameters: [String: CustomStringConvertible] = [:],
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> APIRequest {
        APIRequest(
            method: .delete,
            path: path,
            headers: headers,
            parameters: parameters,
            body: nil,
            output: { _ in () },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Creates a `DELETE` request with a body payload.
    ///
    /// - Parameters:
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - body: The `Encodable` body payload for the request.
    ///   - jsonDecoder: The JSON decoder that will be used to decode error responses.
    ///   - jsonEncoder: The JSON encoder that is  used to encode the `body` parameter.
    /// - Returns: A `DELETE` API request.
    ///
    /// This method automatically adds the `"Content-Type: application/json"` header to the request.
    ///
    static func delete<Body>(
        _ path: String,
        headers: [HeaderField: String] = [:],
        body: Body,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws -> APIRequest where Body: Encodable {
        APIRequest(
            method: .delete,
            path: path,
            headers: [
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            parameters: [:],
            body: try jsonEncoder.encode(body),
            output: { _ in () },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }
}
