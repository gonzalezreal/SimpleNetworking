@testable import SimpleNetworking
import XCTest

final class EndpointTest: XCTestCase {
    func testEndpointWithoutQuery() {
        // given
        let endpoint = Endpoint<User>(method: .get, path: "test")
        var expected = URLRequest(url: Fixtures.anyURLWithPath("test"))
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, endpoint: endpoint)

        // then
        XCTAssertEqual(result, expected)
    }

    func testEndpointWithQuery() {
        // given
        let endpoint = Endpoint<User>(method: .get, path: "test", queryParameters: ["foo": "bar"])
        var expected = URLRequest(url: Fixtures.anyURLWithPath("test", query: "foo=bar"))
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, endpoint: endpoint)

        // then
        XCTAssertEqual(result, expected)
    }

    func testEndpointWithBodyAndOutput() {
        // given
        let user = User(name: "test")
        let endpoint = Endpoint<User>(method: .post, path: "user/new", body: user)

        var expected = URLRequest(url: Fixtures.anyURLWithPath("user/new"))
        expected.httpMethod = "POST"
        expected.httpBody = try! JSONEncoder().encode(user)
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, endpoint: endpoint)

        // then
        XCTAssertEqual(result, expected)
    }

    func testEndpointWithBody() {
        // given
        let user = User(name: "test")
        let endpoint = Endpoint<Void>(method: .post, path: "user/new", body: user)

        var expected = URLRequest(url: Fixtures.anyURLWithPath("user/new"))
        expected.httpMethod = "POST"
        expected.httpBody = try! JSONEncoder().encode(user)
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, endpoint: endpoint)

        // then
        XCTAssertEqual(result, expected)
    }

    static var allTests = [
        ("testEndpointWithoutQuery", testEndpointWithoutQuery),
        ("testEndpointWithQuery", testEndpointWithQuery),
        ("testEndpointWithBodyAndOutput", testEndpointWithBodyAndOutput),
        ("testEndpointWithBody", testEndpointWithBody),
    ]
}
