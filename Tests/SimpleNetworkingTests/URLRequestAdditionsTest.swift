@testable import SimpleNetworking
import XCTest

final class URLRequestAdditionsTest: XCTestCase {
    func testAnyRequestAddingQueryReturnsExpectedRequest() {
        // given
        let anyRequest = URLRequest(url: Fixtures.anyURLWithPath("test", query: "foo=bar"))
        let expected = URLRequest(url: Fixtures.anyURLWithPath("test", query: "baz=qux&foo=bar"))

        // when
        let result = anyRequest.addingQueryParameters(["baz": "qux"])

        // then
        XCTAssertEqual(result, expected)
    }

    func testAnyRequestAddingHeadersReturnsExpectedRequest() {
        // given
        var anyRequest = URLRequest(url: Fixtures.anyURLWithPath("test"))
        anyRequest.addValue(ContentType.json.rawValue, forHTTPHeaderField: HeaderField.accept.rawValue)

        var expected = URLRequest(url: Fixtures.anyURLWithPath("test"))
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: HeaderField.accept.rawValue)
        expected.addValue("Bearer: LoremFistrumCaballo", forHTTPHeaderField: HeaderField.authorization.rawValue)

        // when
        let result = anyRequest.addingHeaders([.authorization: "Bearer: LoremFistrumCaballo"])

        // then
        XCTAssertEqual(result, expected)
    }

    func testAnyRequestLogDescription() {
        // given
        let anyRequest = URLRequest(url: Fixtures.anyURLWithPath("test"))

        // when
        let result = anyRequest.logDescription

        // then
        XCTAssertEqual(result, "[REQUEST] GET https://example.com/test")
    }

    func testAnyRequestWithHeadersLogDescription() {
        // given
        var anyRequest = URLRequest(url: Fixtures.anyURLWithPath("test"))
        anyRequest.addValue(ContentType.json.rawValue, forHTTPHeaderField: HeaderField.accept.rawValue)
        anyRequest.addValue("Bearer: LoremFistrumCaballo", forHTTPHeaderField: HeaderField.authorization.rawValue)
        let expected = """
        [REQUEST] GET https://example.com/test
         ├─ Headers
         │ Accept: application/json
         │ Authorization: Bearer: LoremFistrumCaballo
        """

        // when
        let result = anyRequest.logDescription

        // then
        XCTAssertEqual(result, expected)
    }

    func testAnyRequestWithBodyLogDescription() {
        // given
        var anyRequest = URLRequest(url: Fixtures.anyURLWithPath("test"))
        anyRequest.httpMethod = "POST"
        anyRequest.httpBody = """
        {"foo": "bar"}
        """.data(using: .utf8)
        anyRequest.addValue(ContentType.json.rawValue, forHTTPHeaderField: HeaderField.contentType.rawValue)
        let expected = """
        [REQUEST] POST https://example.com/test
         ├─ Headers
         │ Content-Type: application/json
         ├─ Body
          {
            "foo" : "bar"
          }
        """

        // when
        let result = anyRequest.logDescription

        // then
        XCTAssertEqual(result, expected)
    }

    static var allTests = [
        ("testAnyRequestAddingQueryReturnsExpectedRequest", testAnyRequestAddingQueryReturnsExpectedRequest),
        ("testAnyRequestAddingHeadersReturnsExpectedRequest", testAnyRequestAddingHeadersReturnsExpectedRequest),
        ("testAnyRequestLogDescription", testAnyRequestLogDescription),
        ("testAnyRequestWithHeadersLogDescription", testAnyRequestWithHeadersLogDescription),
        ("testAnyRequestWithBodyLogDescription", testAnyRequestWithBodyLogDescription),
    ]
}
