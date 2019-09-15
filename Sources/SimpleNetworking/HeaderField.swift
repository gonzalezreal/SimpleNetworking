import Foundation

public struct HeaderField: Hashable, Equatable, RawRepresentable {
    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension HeaderField {
    static let accept = HeaderField(rawValue: "Accept")!
    static let authorization = HeaderField(rawValue: "Authorization")!
    static let contentType = HeaderField(rawValue: "Content-Type")!
}
