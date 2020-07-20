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

/// The `Endpoint` type encapsulates an API request, as well as how to decode its response.
///
/// To define an `Endpoint`, you model the **response** and **error response**, preferably as types
/// conforming to `Decodable`.
///
/// For example, consider the
/// [/genre/movie/list](https://developers.themoviedb.org/3/genres/get-movie-list)
/// endpoint in [The Movie Database API](https://developers.themoviedb.org/3).
///
/// We implement the response and error response types as follows:
///
///     struct GenreList: Decodable {
///         var genres: [Genre]
///     }
///
///     struct Status: Decodable {
///         var code: Int
///         var message: String
///     }
///
/// Then, we can create the endpoint as follows:
///
///     let endpoint = Endpoint<GenreList, Status>(method: .get, path: "/genre/movie/list")
///
/// Alternatively, if we are going to reuse the endpoint elsewhere, we can create an extension of `Endpoint` that implements
/// a static property or a factory method:
///
///     extension Endpoint where Output == GenreList, Error == Status {
///         static let movieGenres = Endpoint(method: .get, path: "/genre/movie/list")
///     }
///
public struct Endpoint<Output, Error> {
    /// Represents an HTTP method.
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    /// The HTTP method that will be used to call the endpoint.
    public let method: Method

    /// The route to the endpoint.
    ///
    /// API clients append the path to their base URL.
    public let path: String

    /// The headers that are passed to the API endpoint.
    public let headers: [HeaderField: String]

    /// Optional parameters for the request.
    public let queryParameters: [String: String]

    /// Payload for the request.
    ///
    /// The `body` property is normally used as a payload for `.post`, `.put` and `.patch` requests.
    public let body: Data?

    /// A closure that decodes a valid response into a value of type `Output`.
    public let output: (Data) throws -> Output

    /// A closure that decodes an error response into a value of type `Error`.
    public let error: (Data) throws -> Error

    /// Intializes an endpoint.
    ///
    /// - Parameters:
    ///   - method: The HTTP method that will be used to call the endpoint.
    ///   - path: The route to the endpoint.
    ///   - headers: The headers that are passed as part of the request to this endpoint.
    ///   - queryParameters: The parameters that are passed as part of the request to this endpoint.
    ///   - body: An optional payload that is passed as part of the request to this endpoint.
    ///   - output: A closure that decodes a valid response into a value of type `Output`.
    ///   - error: A closure that decodes an error response into a value of type `Error`.
    public init(
        method: Method,
        path: String,
        headers: [HeaderField: String],
        queryParameters: [String: String],
        body: Data?,
        output: @escaping (Data) throws -> Output,
        error: @escaping (Data) throws -> Error
    ) {
        self.method = method
        self.path = path
        self.headers = headers
        self.queryParameters = queryParameters
        self.body = body
        self.output = output
        self.error = error
    }
}

public extension Endpoint where Output: Decodable, Error: Decodable {
    /// Initializes an endpoint where `Output` and `Error` are `Decodable` types.
    ///
    /// - Parameters:
    ///   - method: The HTTP method that will be used to call the endpoint.
    ///   - path: The route to the endpoint.
    ///   - headers: The headers that are passed as part of the request to this endpoint.
    ///   - queryParameters: The parameters that are passed as part of the request to this endpoint.
    ///   - jsonDecoder: The JSON decoder that will be used to decode valid and error responses.
    ///
    /// This initializer uses the provided or the default JSON decoder to decode valid and error responses
    /// for this endpoint, making possible to declare endpoints in a much nicer way:
    ///
    ///     let popularMovies = Endpoint<MovieResultPage, Status>(
    ///         method: .get,
    ///         path: "/movie/popular",
    ///         queryParameters: ["page": "1"]
    ///     )
    ///
    /// Notice that this initializer automatically adds the `"Accept: application/json"` header to
    /// the request.
    ///
    init(
        method: Method,
        path: String,
        headers: [HeaderField: String] = [:],
        queryParameters: [String: String] = [:],
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.init(
            method: method,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            queryParameters: queryParameters,
            body: nil,
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }

    /// Initializes an endpoint using an `Encodable` body payload.
    ///
    /// - Parameters:
    ///   - method: The HTTP method that will be used to call the endpoint.
    ///   - path: The route to the endpoint.
    ///   - headers: The headers that are passed as part of the request to this endpoint.
    ///   - body: An `Encodable` value that represents the payload of the request to this endpoint.
    ///   - jsonDecoder: The JSON decoder that will be used to decode valid and error responses.
    ///   - jsonEncoder: The JSON encoder that is  used to encode the `body` parameter.
    /// - Throws: `EncodingError`
    ///
    /// This initializer is useful to define `.post`, `.put` and `.patch` operations that include a
    /// body payload:
    ///
    ///     let session = try Endpoint<Session, ErrorResponse>(
    ///         method: .post,
    ///         path: "authentication/session/new",
    ///         body: token
    ///     )
    ///
    /// Notice that this initializer automatically adds the `"Content-Type: application/json"`
    /// and `"Accept: application/json"` headers to the request.
    ///
    init<Input>(
        method: Method,
        path: String,
        headers: [HeaderField: String] = [:],
        body: Input,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws where Input: Encodable {
        self.init(
            method: method,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            queryParameters: [:],
            body: try jsonEncoder.encode(body),
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }
}

public extension Endpoint where Output == Void, Error: Decodable {
    init<Input>(
        method: Method,
        path: String,
        headers: [HeaderField: String] = [:],
        body: Input,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws where Input: Encodable {
        self.init(
            method: method,
            path: path,
            headers: [
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            queryParameters: [:],
            body: try jsonEncoder.encode(body),
            output: { _ in () },
            error: { try jsonDecoder.decode(Error.self, from: $0) }
        )
    }
}

public extension Endpoint where Output: Decodable, Error == Void {
    init(
        method: Method,
        path: String,
        headers: [HeaderField: String] = [:],
        queryParameters: [String: String] = [:],
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.init(
            method: method,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            queryParameters: queryParameters,
            body: nil,
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { _ in () }
        )
    }

    init<Input>(
        method: Method,
        path: String,
        headers: [HeaderField: String] = [:],
        body: Input,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws where Input: Encodable {
        self.init(
            method: method,
            path: path,
            headers: [
                .accept: ContentType.json.rawValue,
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            queryParameters: [:],
            body: try jsonEncoder.encode(body),
            output: { try jsonDecoder.decode(Output.self, from: $0) },
            error: { _ in () }
        )
    }
}

public extension Endpoint where Output == Void, Error == Void {
    init<Input>(
        method: Method,
        path: String,
        headers: [HeaderField: String] = [:],
        body: Input,
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws where Input: Encodable {
        self.init(
            method: method,
            path: path,
            headers: [
                .contentType: ContentType.json.rawValue,
            ].merging(headers) { _, new in new },
            queryParameters: [:],
            body: try jsonEncoder.encode(body),
            output: { _ in () },
            error: { _ in () }
        )
    }
}
