//
// URLRequestAdditionsTest.swift
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
final class URLRequestAdditionsTest: XCTestCase {
    func testAnyRequestAddingQueryReturnsExpectedRequest() {
        // given
        let anyRequest = URLRequest(url: Fixtures.anyURLWithPath("test", query: "foo=bar"))
        let expected = URLRequest(url: Fixtures.anyURLWithPath("test", query: "baz=qux&foo=bar"))

        // when
        let result = anyRequest.addingParameters(["baz": "qux"])

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
}
