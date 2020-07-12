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

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public class APIClient {
        public let baseURL: URL
        public let configuration: APIClientConfiguration
        public var logger = Logger(label: "APIClient")

        private let session: URLSession

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

        public func response<Output>(for endpoint: Endpoint<Output>) -> AnyPublisher<Output, Error> {
            let request = URLRequest(baseURL: baseURL, endpoint: endpoint)
                .addingHeaders(configuration.additionalHeaders)
                .addingQueryParameters(configuration.additionalQueryParameters)

            logger.debug("\(request.logDescription)")

            return session.dataTaskPublisher(for: request)
                .tryMap { [logger] data, response in
                    let httpResponse = response as! HTTPURLResponse

                    logger.debug("\(httpResponse.logDescription(content: data.logDescription))")

                    guard 200 ..< 300 ~= httpResponse.statusCode else {
                        throw BadStatusError(data: data, response: httpResponse)
                    }

                    return try endpoint.output(data)
                }
                .eraseToAnyPublisher()
        }
    }
#endif
