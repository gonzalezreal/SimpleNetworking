import Foundation

internal extension Data {
    var logDescription: String {
        String(data: prettyPrintedJSON ?? self, encoding: .utf8).map {
            $0.components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
                .map { "  \($0)" }
                .joined(separator: "\n")
        } ?? ""
    }
}

private extension Data {
    var prettyPrintedJSON: Data? {
        (try? JSONSerialization.jsonObject(with: self, options: [])).flatMap {
            try? JSONSerialization.data(withJSONObject: $0, options: [.prettyPrinted, .sortedKeys])
        }
    }
}
