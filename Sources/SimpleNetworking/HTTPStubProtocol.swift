//
// HTTPStubProtocol.swift
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

/// `HTTPStubProtocol` is a `URLProtocol` subclass that allows stubbing responses for specific API or URL requests.
///
/// Stubbing responses can be useful when writing UI or integration tests to avoid depending on network reachability.
///
/// You can stub any `Encodable` value as a valid response for an API request:
///
///     try HTTPStubProtocol.stub(
///         User(name: "gonzalezreal"),
///         statusCode: 200,
///         for: APIRequest<User, Error>.get(
///             "/user",
///             headers: [.authorization: "Bearer 3xpo"],
///             parameters: ["api_key": "a9a5aac8752afc86"]
///         ),
///         baseURL: URL(string: "https://example.com/api")!
///     )
///
/// Or as an error response for the same API request:
///
///     try HTTPStubProtocol.stub(
///         Error(message: "The resource you requested could not be found."),
///         statusCode: 404,
///         for: APIRequest<User, Error>.get(
///             "/user",
///             headers: [.authorization: "Bearer 3xpo"],
///             parameters: ["api_key": "a9a5aac8752afc86"]
///         ),
///         baseURL: URL(string: "https://example.com/api")!
///     )
///
/// To use stubbed responses, you need to pass `URLSession.stubbed` as a parameter for
/// `session:` when constructing the `APIClient`:
///
///     let apiClient = APIClient(
///         baseURL: URL(string: "https://example.com/api")!,
///         configuration: configuration,
///         session: .stubbed
///     )
///
public final class HTTPStubProtocol: URLProtocol {
    private struct Stub {
        let data: Data
        let response: HTTPURLResponse
    }

    private static var stubs: [URLRequest: Stub] = [:]

    /// Stubs a valid response for a given API request.
    ///
    /// - Parameters:
    ///   - output: The response to stub.
    ///   - jsonEncoder: The JSON encoder that is  used to encode the `output` parameter.
    ///   - statusCode: The HTTP status code for the response.
    ///   - headers: The HTTP headers for the response.
    ///   - request: The API request for which the response is stubbed.
    ///   - baseURL: The base URL for the API request.
    ///
    public static func stub<Output, Error>(
        _ output: Output,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        statusCode: Int,
        headers: [String: String]? = nil,
        for request: APIRequest<Output, Error>,
        baseURL: URL
    ) throws where Output: Encodable {
        stub(
            try jsonEncoder.encode(output),
            statusCode: statusCode,
            headers: headers,
            for: URLRequest(baseURL: baseURL, apiRequest: request)
        )
    }

    /// Stubs an error response for a given API request.
    ///
    /// - Parameters:
    ///   - error: The error response to stub.
    ///   - jsonEncoder: The JSON encoder that is  used to encode the `error` parameter.
    ///   - statusCode: The HTTP status code for the response.
    ///   - headers: The HTTP headers for the response.
    ///   - request: The API request for which the error response is stubbed.
    ///   - baseURL: The base URL for the API request.
    ///
    public static func stub<Output, Error>(
        _ error: Error,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        statusCode: Int,
        headers: [String: String]? = nil,
        for request: APIRequest<Output, Error>,
        baseURL: URL
    ) throws where Error: Encodable {
        stub(
            try jsonEncoder.encode(error),
            statusCode: statusCode,
            headers: headers,
            for: URLRequest(baseURL: baseURL, apiRequest: request)
        )
    }

    /// Stubs a text response for a given API request.
    ///
    /// - Parameters:
    ///   - text: The text response to stub.
    ///   - statusCode: The HTTP status code for the response.
    ///   - headers: The HTTP headers for the response.
    ///   - request: The API request for which the response is stubbed.
    ///   - baseURL: The base URL for the API request.
    ///
    public static func stub<Output, Error>(
        _ text: String,
        statusCode: Int,
        headers: [String: String]? = nil,
        for request: APIRequest<Output, Error>,
        baseURL: URL
    ) {
        return stub(
            text.data(using: .utf8)!,
            statusCode: statusCode,
            headers: headers,
            for: URLRequest(baseURL: baseURL, apiRequest: request)
        )
    }

    /// Stubs an empty response with a status code for a given API requests.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code for the response.
    ///   - headers: The HTTP headers for the response.
    ///   - request: The API request for which the response is stubbed.
    ///   - baseURL: The base URL for the API request.
    ///
    public static func stub<Error>(
        statusCode: Int,
        headers: [String: String]? = nil,
        for request: APIRequest<Void, Error>,
        baseURL: URL
    ) {
        return stub(
            Data(),
            statusCode: statusCode,
            headers: headers,
            for: URLRequest(baseURL: baseURL, apiRequest: request)
        )
    }

    /// Stubs the specified data as a response for a given URL request.
    ///
    /// - Parameters:
    ///   - data: The data for the response
    ///   - statusCode: The HTTP status code for the response.
    ///   - headers: The HTTP headers for the response.
    ///   - request: The URL request for which the response is stubbed.
    ///
    public static func stub(
        _ data: Data,
        statusCode: Int,
        headers: [String: String]? = nil,
        for request: URLRequest
    ) {
        stubs[request] = Stub(
            data: data,
            response: HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: headers
            )!
        )
    }

    public static func removeAllStubs() {
        stubs.removeAll()
    }

    override public class func canInit(with request: URLRequest) -> Bool {
        stubs.keys.contains(request)
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override public class func requestIsCacheEquivalent(_: URLRequest, to _: URLRequest) -> Bool {
        false
    }

    override public func startLoading() {
        guard let stub = HTTPStubProtocol.stubs[request] else {
            fatalError("Couldn't find stub for request \(request)")
        }

        client!.urlProtocol(self, didReceive: stub.response, cacheStoragePolicy: .notAllowed)
        client!.urlProtocol(self, didLoad: stub.data)
        client!.urlProtocolDidFinishLoading(self)
    }

    override public func stopLoading() {}
}
