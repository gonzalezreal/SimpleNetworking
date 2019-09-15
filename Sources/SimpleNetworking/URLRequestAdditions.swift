import Foundation

extension URLRequest {
    public init<Output>(baseURL: URL, endpoint: Endpoint<Output>) {
        let url = baseURL.appendingPathComponent(endpoint.path)

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        if !endpoint.queryParameters.isEmpty {
            components.queryItems = endpoint.queryParameters.map(URLQueryItem.init)
        }

        self.init(url: components.url!)

        httpMethod = endpoint.method.rawValue
        httpBody = endpoint.body

        for (field, value) in endpoint.headers {
            addValue(value, forHTTPHeaderField: field.rawValue)
        }
    }

    public func addingQueryParameters(_ parameters: [String: String]) -> URLRequest {
        guard !parameters.isEmpty else { return self }

        var components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
        components.queryItems = components.queryItems ?? []
        components.queryItems?.append(contentsOf: parameters.map(URLQueryItem.init))

        var result = self
        result.url = components.url

        return result
    }

    public func addingHeaders(_ headers: [HeaderField: String]) -> URLRequest {
        guard !headers.isEmpty else { return self }

        var result = self

        for (field, value) in headers {
            result.addValue(value, forHTTPHeaderField: field.rawValue)
        }

        return result
    }
}
