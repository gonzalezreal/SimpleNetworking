import Foundation

struct User: Equatable, Codable {
    let name: String
}

enum Fixtures {
    static let anyBaseURL = URL(string: "https://example.com")!
    static let anyUser = User(name: "gonzalezreal")
    static let anyJSON = try! JSONEncoder().encode(anyUser)

    static func anyURLWithPath(_ path: String, query: String? = nil) -> URL {
        let url = anyBaseURL.appendingPathComponent(path)

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.query = query

        return components.url!
    }
}
