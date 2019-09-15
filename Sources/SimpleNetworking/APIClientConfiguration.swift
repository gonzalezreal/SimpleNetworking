import Foundation

public struct APIClientConfiguration {
    public let additionalHeaders: [HeaderField: String]
    public let additionalQueryParameters: [String: String]
}
