@testable import SimpleNetworking
import XCTest

final class HTTPURLResponseAdditionsTest: XCTestCase {
    func testAnyResponseLogDescription() {
        // given
        let anyResponse = HTTPURLResponse(url: Fixtures.anyURLWithPath("test"),
                                          statusCode: 200,
                                          httpVersion: "HTTP/1.1",
                                          headerFields: ["Content-Type": "application/json;charset=utf-8"])!
        let expected = """
        [RESPONSE] 200 https://example.com/test
         ├─ Headers
         │ Content-Type: application/json;charset=utf-8
         ├─ Content
          {
            "name" : "gonzalezreal"
          }
        """

        // when
        let result = anyResponse.logDescription(content: Fixtures.anyJSON.logDescription)

        // then
        XCTAssertEqual(result, expected)
    }

    static var allTests = [
        ("testResponseLogDescription", testAnyResponseLogDescription),
    ]
}
