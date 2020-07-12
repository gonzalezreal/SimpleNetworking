//
// APIClientTest.swift
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

#if canImport(Combine)
    import Combine
    import SimpleNetworking
    import XCTest

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    final class APIClientTest: XCTestCase {
        private var sut: APIClient!
        private let configuration = APIClientConfiguration(
            additionalHeaders: [.authorization: "Bearer 3xpo"],
            additionalQueryParameters: ["api_key": "test"]
        )
        private var cancellables = Set<AnyCancellable>()

        override func setUp() {
            super.setUp()

            sut = APIClient(baseURL: Fixtures.anyBaseURL, configuration: configuration, session: .stubbed)
        }

        override func tearDown() {
            HTTPStubProtocol.removeAllStubs()
            super.tearDown()
        }

        func testAnyJSONResponseReturnsOutput() {
            // given
            givenAnyJSONResponse()
            let endpoint = Endpoint<User>(method: .get, path: "user")
            let didReceiveValue = expectation(description: "didReceiveValue")
            var result: User?

            // when
            sut.response(for: endpoint)
                .assertNoFailure()
                .sink(receiveValue: {
                    result = $0
                    didReceiveValue.fulfill()
                })
                .store(in: &cancellables)

            // then
            wait(for: [didReceiveValue], timeout: 1)
            XCTAssertEqual(Fixtures.anyUser, result)
        }

        func testBadStatusResponseFailsWithBadStatusError() {
            // given
            givenBadStatusResponse()
            let endpoint = Endpoint<User>(method: .get, path: "user")
            let didFail = expectation(description: "didFail")
            var result: Error?

            // when
            sut.response(for: endpoint)
                .catch { error -> Just<User> in
                    result = error
                    didFail.fulfill()
                    return Just(User(name: ""))
                }
                .sink(receiveValue: { _ in })
                .store(in: &cancellables)

            // then
            wait(for: [didFail], timeout: 1)

            let badStatusError = result as? BadStatusError
            XCTAssertEqual(500, badStatusError?.statusCode)
        }

        static var allTests = [
            ("testAnyJSONResponseReturnsOutput", testAnyJSONResponseReturnsOutput),
            ("testBadStatusResponseFailsWithBadStatusError", testBadStatusResponseFailsWithBadStatusError),
        ]
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private extension APIClientTest {
        func givenAnyJSONResponse() {
            var request = URLRequest(url: Fixtures.anyURLWithPath("user", query: "api_key=test"))
            request.addValue(ContentType.json.rawValue, forHTTPHeaderField: HeaderField.accept.rawValue)
            request.addValue("Bearer 3xpo", forHTTPHeaderField: HeaderField.authorization.rawValue)

            HTTPStubProtocol.stubRequest(request, data: Fixtures.anyJSON, statusCode: 200)
        }

        func givenBadStatusResponse() {
            var request = URLRequest(url: Fixtures.anyURLWithPath("user", query: "api_key=test"))
            request.addValue(ContentType.json.rawValue, forHTTPHeaderField: HeaderField.accept.rawValue)
            request.addValue("Bearer 3xpo", forHTTPHeaderField: HeaderField.authorization.rawValue)

            HTTPStubProtocol.stubRequest(request, data: Data(), statusCode: 500)
        }
    }
#endif
