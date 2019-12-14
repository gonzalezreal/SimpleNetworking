import Foundation

extension URLRequest {
    internal var logDescription: String {
        var result = "[REQUEST] \(httpMethod!) \(url!)"

        if let logDescription = allHTTPHeaderFields?.logDescription, !logDescription.isEmpty {
            result += "\n ├─ Headers\n\(logDescription)"
        }

        if let logDescription = httpBody?.logDescription, !logDescription.isEmpty {
            result += "\n ├─ Body\n\(logDescription)"
        }

        return result
    }

    public init<Output>(baseURL: URL, endpoint: Endpoint<Output>) {
        let url = baseURL.appendingPathComponent(endpoint.path)

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        if !endpoint.queryParameters.isEmpty {
            components.queryItems = endpoint.queryParameters.sorted { $0.key < $1.key }.map(URLQueryItem.init)
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

        let queryItems = (components.queryItems ?? []) + parameters.map(URLQueryItem.init)
        components.queryItems = queryItems.sorted { $0.name < $1.name }

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
