//
// HTTPURLResponseAdditionsTest.swift
//
// Copyright (c) 2020 Guille Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@testable import SimpleNetworking
import XCTest

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
final class HTTPURLResponseAdditionsTest: XCTestCase {
    func testAnyResponseLogDescription() {
        // given
        let anyResponse = HTTPURLResponse(
            url: Fixtures.anyURLWithPath("test"),
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json;charset=utf-8"]
        )!
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
