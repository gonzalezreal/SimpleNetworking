import Foundation

internal extension Dictionary where Key == String, Value == String {
    var logDescription: String {
        sorted { $0.key < $1.key }
            .map { " │ \($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
}
