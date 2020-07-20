//
// APIRequestTest.swift
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

import SimpleNetworking
import XCTest

final class APIRequestTest: XCTestCase {
    func testGetRequest() {
        // given
        let request = APIRequest<User, Error>.get(
            "/test",
            headers: [.authorization: "Bearer 3xpo"],
            parameters: ["page": 1]
        )
        var expected = URLRequest(url: Fixtures.anyURLWithPath("/test", query: "page=1"))
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
    }

    func testPostRequest() {
        // given
        let request = APIRequest<User, Error>.post(
            "/test/1",
            headers: [.authorization: "Bearer 3xpo"]
        )
        var expected = URLRequest(url: Fixtures.anyURLWithPath("/test/1"))
        expected.httpMethod = "POST"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
    }

    func testPostRequestWithBody() throws {
        // given
        let user = User(name: "test")
        let request = try APIRequest<User, Error>.post(
            "/user/new",
            headers: [.authorization: "Bearer 3xpo"],
            body: user
        )

        var expected = URLRequest(url: Fixtures.anyURLWithPath("user/new"))
        expected.httpMethod = "POST"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
        XCTAssertEqual(result.httpBody, try JSONEncoder().encode(user))
    }

    func testPostRequestWithoutResponse() {
        // given
        let request = APIRequest<Void, Error>.post(
            "/test/1",
            headers: [.authorization: "Bearer 3xpo"]
        )
        var expected = URLRequest(url: Fixtures.anyURLWithPath("/test/1"))
        expected.httpMethod = "POST"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
    }

    func testPostRequestWithBodyButWithoutResponse() throws {
        // given
        let user = User(name: "test")
        let request = try APIRequest<Void, Error>.post(
            "/user/new",
            headers: [.authorization: "Bearer 3xpo"],
            body: user
        )

        var expected = URLRequest(url: Fixtures.anyURLWithPath("user/new"))
        expected.httpMethod = "POST"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
        XCTAssertEqual(result.httpBody, try JSONEncoder().encode(user))
    }

    func testPutRequest() {
        // given
        let request = APIRequest<User, Error>.put(
            "/test/1",
            headers: [.authorization: "Bearer 3xpo"]
        )
        var expected = URLRequest(url: Fixtures.anyURLWithPath("/test/1"))
        expected.httpMethod = "PUT"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
    }

    func testPuttRequestWithBody() throws {
        // given
        let user = User(name: "test")
        let request = try APIRequest<User, Error>.put(
            "/user/edit",
            headers: [.authorization: "Bearer 3xpo"],
            body: user
        )

        var expected = URLRequest(url: Fixtures.anyURLWithPath("user/edit"))
        expected.httpMethod = "PUT"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
        XCTAssertEqual(result.httpBody, try JSONEncoder().encode(user))
    }

    func testPutRequestWithoutResponse() {
        // given
        let request = APIRequest<Void, Error>.put(
            "/test/1",
            headers: [.authorization: "Bearer 3xpo"]
        )
        var expected = URLRequest(url: Fixtures.anyURLWithPath("/test/1"))
        expected.httpMethod = "PUT"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
    }

    func testPutRequestWithBodyButWithoutResponse() throws {
        // given
        let user = User(name: "test")
        let request = try APIRequest<Void, Error>.put(
            "/user/edit",
            headers: [.authorization: "Bearer 3xpo"],
            body: user
        )

        var expected = URLRequest(url: Fixtures.anyURLWithPath("user/edit"))
        expected.httpMethod = "PUT"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
        XCTAssertEqual(result.httpBody, try JSONEncoder().encode(user))
    }

    func testDeleteRequest() {
        // given
        let request = APIRequest<User, Error>.delete(
            "/test/1",
            headers: [.authorization: "Bearer 3xpo"]
        )
        var expected = URLRequest(url: Fixtures.anyURLWithPath("/test/1"))
        expected.httpMethod = "DELETE"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
    }

    func testDeleteRequestWithBody() throws {
        // given
        let user = User(name: "test")
        let request = try APIRequest<User, Error>.delete(
            "/test/1",
            headers: [.authorization: "Bearer 3xpo"],
            body: user
        )
        var expected = URLRequest(url: Fixtures.anyURLWithPath("/test/1"))
        expected.httpMethod = "DELETE"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
        XCTAssertEqual(result.httpBody, try JSONEncoder().encode(user))
    }

    func testDeleteRequestWithoutResponse() {
        // given
        let request = APIRequest<Void, Error>.delete(
            "/test/1",
            headers: [.authorization: "Bearer 3xpo"]
        )
        var expected = URLRequest(url: Fixtures.anyURLWithPath("/test/1"))
        expected.httpMethod = "DELETE"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
    }

    func testDeleteRequestWithBodyButWithoutResponse() throws {
        // given
        let user = User(name: "test")
        let request = try APIRequest<Void, Error>.delete(
            "/test/1",
            headers: [.authorization: "Bearer 3xpo"],
            body: user
        )
        var expected = URLRequest(url: Fixtures.anyURLWithPath("/test/1"))
        expected.httpMethod = "DELETE"
        expected.addValue("Bearer 3xpo", forHTTPHeaderField: "Authorization")
        expected.addValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")

        // when
        let result = URLRequest(baseURL: Fixtures.anyBaseURL, apiRequest: request)

        // then
        XCTAssertEqual(result, expected)
        XCTAssertEqual(result.httpBody, try JSONEncoder().encode(User(name: "test")))
    }
}
