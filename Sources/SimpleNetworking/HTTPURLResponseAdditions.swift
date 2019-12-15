import Foundation

internal extension HTTPURLResponse {
    func logDescription(content: String) -> String {
        var result = "[RESPONSE] \(statusCode) \(url!)"

        let headers = allHeaderFields.map { " │ \($0.key): \($0.value)" }
            .joined(separator: "\n")
        if !headers.isEmpty {
            result += "\n ├─ Headers\n\(headers)"
        }

        if !content.isEmpty {
            result += "\n ├─ Content\n\(content)"
        }

        return result
    }
}
