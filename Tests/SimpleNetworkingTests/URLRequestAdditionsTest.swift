@testable import SimpleNetworking
import XCTest

final class URLRequestAdditionsTest: XCTestCase {
    func testAnyRequestAddingQueryReturnsExpectedRequest() {
        // given
        let anyRequest = URLRequest(url: Fixtures.anyURLWithPath("test", query: "foo=bar"))
        let expected = URLRequest(url: Fixtures.anyURLWithPath("test", query: "foo=bar&baz=qux"))

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

    static var allTests = [
        ("testAnyRequestAddingQueryReturnsExpectedRequest", testAnyRequestAddingQueryReturnsExpectedRequest),
        ("testAnyRequestAddingHeadersReturnsExpectedRequest", testAnyRequestAddingHeadersReturnsExpectedRequest),
    ]
}
