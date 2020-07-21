//
// APIRequest.swift
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

/// The `APIRequest` type encapsulates an API request, as well as how to decode valid and error responses
/// from that request.
///
/// To define an `APIRequest`, you model the **response** and **error response**, preferably as types
/// conforming to `Decodable`.
///
/// For example, consider the
/// [/genre/movie/list](https://developers.themoviedb.org/3/genres/get-movie-list)
/// method in [The Movie Database API](https://developers.themoviedb.org/3).
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
/// Then, we can create the request as follows:
///
///     let request = APIRequest<GenreList, Status>.get("/genre/movie/list")
///
/// Alternatively, if we are going to reuse the request elsewhere, we can create an extension of `APIRequest` that implements
/// a static property or a factory method:
///
///     extension APIRequest where Output == GenreList, Error == Status {
///         static let movieGenres = APIRequest.get("/genre/movie/list")
///     }
///
public struct APIRequest<Output, Error> {
    /// Represents an HTTP method.
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    /// The HTTP method for the request.
    public let method: Method

    /// The route to the request endpoint.
    ///
    /// API clients append the path to their base URL.
    public let path: String

    /// The headers that are passed with the request.
    public let headers: [HeaderField: CustomStringConvertible]

    /// The parameters that are passed with the request.
    ///
    /// This parameters are appended to the URL as query parameters.
    public let parameters: [String: CustomStringConvertible]

    /// The body payload that is passed with the request.
    ///
    /// The `body` property is normally used as a payload for `.post`, `.put` and `.patch` requests.
    public let body: Data?

    /// A closure that decodes a valid response into a value of type `Output`.
    public let output: (Data) throws -> Output

    /// A closure that decodes an error response into a value of type `Error`.
    public let error: (Data) throws -> Error

    /// Initializes an API request.
    ///
    /// - Parameters:
    ///   - method: The HTTP method for the request.
    ///   - path: The route to the request endpoint.
    ///   - headers: The headers that are passed with the request.
    ///   - parameters: The parameters that are passed with the request.
    ///   - body: The body payload that is passed with the request.
    ///   - output: A closure that decodes a valid response into a value of type `Output`.
    ///   - error: A closure that decodes an error response into a value of type `Error`.
    public init(
        method: Method,
        path: String,
        headers: [HeaderField: CustomStringConvertible],
        parameters: [String: CustomStringConvertible],
        body: Data?,
        output: @escaping (Data) throws -> Output,
        error: @escaping (Data) throws -> Error
    ) {
        self.method = method
        self.path = path
        self.headers = headers
        self.parameters = parameters
        self.body = body
        self.output = output
        self.error = error
    }
}
