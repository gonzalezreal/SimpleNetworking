//
// APIClient.swift
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

#if canImport(Combine)
    import Combine
    import Foundation
    import Logging

    /// An `APIClient` is an object that makes requests to an API and handles its responses.
    /// It works in conjunction with the `Endpoint` type, which encapsulates a specific request
    /// as well as how to decode its response.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public class APIClient {
        /// The base URL to which the endpoint paths are appended.
        public let baseURL: URL

        /// The configuration contains additional headers and query parameters that will be appended to each request.
        public let configuration: APIClientConfiguration

        /// This logger emits requests and responses at debug level.
        public var logger = Logger(label: "APIClient")

        private let session: URLSession

        /// Initializes an API client.
        /// - Parameters:
        ///   - baseURL: The base URL to which the endpoint paths are appended.
        ///   - configuration: Additional headers and query parameters that will be appended to each request.
        ///   - session: The URL session that will handle the requests and responses.
        ///   - logLevel: The log level. If `.debug`, all requests and responses will be logged.
        public init(
            baseURL: URL,
            configuration: APIClientConfiguration = APIClientConfiguration(),
            session: URLSession = URLSession(configuration: .default),
            logLevel: Logger.Level = .info
        ) {
            self.baseURL = baseURL
            self.configuration = configuration
            self.session = session
            logger.logLevel = logLevel
        }

        /// Returns a publisher that wraps a request for a given endpoint.
        ///
        /// The publisher decodes and emits the response when the request completes,
        /// or terminates with an error if the request fails.
        ///
        /// - Parameter endpoint: The endpoint for which to create the request.
        public func response<Output, Error>(for endpoint: Endpoint<Output, Error>) -> AnyPublisher<Output, APIClientError<Error>> {
            let request = URLRequest(baseURL: baseURL, endpoint: endpoint)
                .addingHeaders(configuration.additionalHeaders)
                .addingQueryParameters(configuration.additionalQueryParameters)

            logger.debug("\(request.logDescription)")

            return session.dataTaskPublisher(for: request)
                .tryMap { [logger] data, response in
                    let httpResponse = response as! HTTPURLResponse

                    logger.debug("\(httpResponse.logDescription(content: data.logDescription))")

                    guard 200 ..< 300 ~= httpResponse.statusCode else {
                        let error = try endpoint.error(data)
                        throw APIError(statusCode: httpResponse.statusCode, error: error)
                    }

                    return try endpoint.output(data)
                }
                .mapError(APIClientError.init)
                .eraseToAnyPublisher()
        }
    }
#endif
