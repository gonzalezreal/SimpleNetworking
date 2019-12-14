import Foundation

internal extension Data {
    var logDescription: String {
        String(data: self, encoding: .utf8).map {
            $0.components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
                .map { " │ \($0)" }
                .joined(separator: "\n")
        } ?? ""
    }
}
