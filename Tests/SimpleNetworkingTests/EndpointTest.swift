import SimpleNetworking
import XCTest

final class EndpointTest: XCTestCase {
    func testEndpointWithoutQuery() {
        // given
        let endpoint = Endpoint<User>(method: .get, path: "test", headers: [.authorization: "Bearer 3xpo"])
        var expected = URLRequest(url: Fixtures.anyURLWithPath("test"))
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, endpoint: endpoint)

        // then
        XCTAssertEqual(result, expected)
    }

    func testEndpointWithQuery() {
        // given
        let endpoint = Endpoint<User>(method: .get, path: "test", headers: [.authorization: "Bearer 3xpo"], queryParameters: ["foo": "bar"])
        var expected = URLRequest(url: Fixtures.anyURLWithPath("test", query: "foo=bar"))
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, endpoint: endpoint)

        // then
        XCTAssertEqual(result, expected)
    }

    func testEndpointWithBodyAndOutput() {
        // given
        let user = User(name: "test")
        let endpoint = Endpoint<User>(method: .post,
                                      path: "user/new",
                                      headers: [.authorization: "Bearer 3xpo"],
                                      body: user)

        var expected = URLRequest(url: Fixtures.anyURLWithPath("user/new"))
        expected.httpMethod = "POST"
        expected.httpBody = try! JSONEncoder().encode(user)
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
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
        let endpoint = Endpoint<Void>(method: .post, path: "user/new", headers: [.authorization: "Bearer 3xpo"], body: user)

        var expected = URLRequest(url: Fixtures.anyURLWithPath("user/new"))
        expected.httpMethod = "POST"
        expected.httpBody = try! JSONEncoder().encode(user)
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
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
