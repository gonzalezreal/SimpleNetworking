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

/// A `URLProtocol` subclass that stubs HTTP requests.
///
/// You can use `HTTPStubProtocol` to stub a network request as follows:
///
///     var request = URLRequest(url: URL(string: "https://example.com/user?api_key=test")!)
///     request.addValue("application/json", forHTTPHeaderField: "Accept")
///     request.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
///
///     let json = #"{"foo": "bar"}"#.data(using: .utf8)!
///
///     HTTPStubProtocol.stubRequest(request, data: json, statusCode: 200)
///
/// And then pass the `.stubbed` URL session as a parameter when constructing your `APIClient`:
///
///     let apiClient = APIClient(
///         baseURL: URL(string: "https://example.com")!,
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

    public static func stubRequest(
        _ request: URLRequest,
        data: Data,
        statusCode: Int,
        headers: [String: String]? = nil
    ) {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )
        stubs[request] = Stub(data: data, response: response!)
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
