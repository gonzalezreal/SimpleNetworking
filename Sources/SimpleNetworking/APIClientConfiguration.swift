import Foundation

public struct APIClientConfiguration {
    public var additionalHeaders: [HeaderField: String]
    public var additionalQueryParameters: [String: String]

    public init(additionalHeaders: [HeaderField: String] = [:], additionalQueryParameters: [String: String] = [:]) {
        self.additionalHeaders = additionalHeaders
        self.additionalQueryParameters = additionalQueryParameters
    }
}
