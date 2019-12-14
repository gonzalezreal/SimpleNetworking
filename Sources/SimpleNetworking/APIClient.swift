import Combine
import Foundation
import Logging

public class APIClient {
    public let baseURL: URL
    public let configuration: APIClientConfiguration
    public var logger = Logger(label: "APIClient")

    private let session: URLSession

    public init(baseURL: URL, configuration: APIClientConfiguration = APIClientConfiguration(), session: URLSession = URLSession(configuration: .default)) {
        self.baseURL = baseURL
        self.configuration = configuration
        self.session = session
        #if DEBUG
            logger.logLevel = .debug
        #else
            logger.logLevel = .info
        #endif
    }

    public func response<Output>(for endpoint: Endpoint<Output>) -> AnyPublisher<Output, Error> {
        let request = URLRequest(baseURL: baseURL, endpoint: endpoint)
            .addingHeaders(configuration.additionalHeaders)
            .addingQueryParameters(configuration.additionalQueryParameters)

        logger.debug("\(request.logDescription)")

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                let httpResponse = response as! HTTPURLResponse

                guard 200 ..< 300 ~= httpResponse.statusCode else {
                    throw BadStatusError(data: data, response: httpResponse)
                }

                return try endpoint.output(data)
            }
            .eraseToAnyPublisher()
    }
}
