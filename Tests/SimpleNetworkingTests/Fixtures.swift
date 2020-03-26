import Foundation

struct User: Equatable, Codable {
    let name: String
}

enum Fixtures {
    static let anyBaseURL = URL(string: "https://example.com")!
    static let anyImageURL = URL(string: "https://example.com/dot.png")!
    static let anyDataImageURL = URL(string: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==")!
    static let anyUser = User(name: "gonzalezreal")
    static let anyJSON = try! JSONEncoder().encode(anyUser)
    static let anyImage = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==")!

    static func anyURLWithPath(_ path: String, query: String? = nil) -> URL {
        let url = anyBaseURL.appendingPathComponent(path)

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.query = query

        return components.url!
    }
}
