import Foundation

public struct Endpoint<Output> {
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    public let method: Method
    public let path: String
    public let headers: [HeaderField: String]
    public let queryParameters: [String: String]
    public let body: Data?
    public let output: (Data) throws -> Output
}

public extension Endpoint where Output: Decodable {
    init(method: Method,
         path: String,
         queryParameters: [String: String] = [:],
         dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) {
        self.init(method: method,
                  path: path,
                  headers: [.accept: ContentType.json.rawValue],
                  queryParameters: queryParameters,
                  body: nil,
                  output: decode(with: dateDecodingStrategy))
    }

    init<Input>(method: Method,
                path: String,
                body: Input,
                dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate,
                dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) where Input: Encodable {
        self.init(method: method,
                  path: path,
                  headers: [.accept: ContentType.json.rawValue, .contentType: ContentType.json.rawValue],
                  queryParameters: [:],
                  body: try! encode(body, with: dateEncodingStrategy),
                  output: decode(with: dateDecodingStrategy))
    }
}

public extension Endpoint where Output == Void {
    init<Input>(method: Method,
                path: String,
                body: Input,
                dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate) where Input: Encodable {
        self.init(method: method,
                  path: path,
                  headers: [.contentType: ContentType.json.rawValue],
                  queryParameters: [:],
                  body: try! encode(body, with: dateEncodingStrategy),
                  output: { _ in () })
    }
}

private func decode<Output: Decodable>(with dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) -> (Data) throws -> Output {
    return { data in
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        return try decoder.decode(Output.self, from: data)
    }
}

private func encode<Input: Encodable>(_ body: Input, with dateEncodingStrategy: JSONEncoder.DateEncodingStrategy) throws -> Data {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = dateEncodingStrategy

    return try encoder.encode(body)
}
