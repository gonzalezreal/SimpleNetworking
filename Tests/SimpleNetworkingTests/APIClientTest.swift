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
            additionalParameters: ["api_key": "test"]
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

        func testAnyValidResponseReturnsOutput() throws {
            // given
            try givenAnyValidResponse()
            let request = APIRequest<User, Error>.get("/user")
            let didReceiveValue = expectation(description: "didReceiveValue")
            var result: User?

            // when
            sut.response(for: request)
                .assertNoFailure()
                .sink(receiveValue: {
                    result = $0
                    didReceiveValue.fulfill()
                })
                .store(in: &cancellables)

            wait(for: [didReceiveValue], timeout: 1)

            // then
            XCTAssertEqual(Fixtures.anyUser, result)
        }

        func testAnyInvalidResponseReturnsDecodingError() {
            // given
            givenAnyInvalidResponse()
            let request = APIRequest<User, Error>.get("/user")
            let didFail = expectation(description: "didFail")
            var result: DecodingError?

            // when
            sut.response(for: request)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            result = error.decodingError
                            didFail.fulfill()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

            wait(for: [didFail], timeout: 1)

            // then
            XCTAssertNotNil(result)
        }

        func testAnyErrorResponseReturnsAPIError() throws {
            // given
            try givenAnyErrorResponse()
            let request = APIRequest<User, Error>.get("/user")
            let didFail = expectation(description: "didFail")
            var result: APIError<Error>?

            // when
            sut.response(for: request)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            result = error.apiError
                            didFail.fulfill()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

            wait(for: [didFail], timeout: 1)

            // then
            XCTAssertEqual(404, result?.statusCode)
            XCTAssertEqual(Fixtures.anyError, result?.error)
        }

        func testEmptyErrorResponseReturnsAPIError() {
            // given
            givenEmptyErrorResponse()
            let request = APIRequest<User, Error>.get("/user")
            let didFail = expectation(description: "didFail")
            var result: APIError<Error>?

            // when
            sut.response(for: request)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            result = error.apiError
                            didFail.fulfill()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

            wait(for: [didFail], timeout: 1)

            // then
            XCTAssertEqual(404, result?.statusCode)
            XCTAssertNil(result?.error)
        }

        func testInvalidErrorResponseReturnsDecodingError() {
            // given
            givenInvalidErrorResponse()
            let request = APIRequest<User, Error>.get("/user")
            let didFail = expectation(description: "didFail")
            var result: DecodingError?

            // when
            sut.response(for: request)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            result = error.decodingError
                            didFail.fulfill()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

            wait(for: [didFail], timeout: 1)

            // then
            XCTAssertNotNil(result)
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private extension APIClientTest {
        func givenAnyValidResponse() throws {
            try HTTPStubProtocol.stub(
                Fixtures.anyUser,
                statusCode: 200,
                for: APIRequest<User, Error>.get(
                    "/user",
                    headers: [.authorization: "Bearer 3xpo"],
                    parameters: ["api_key": "test"]
                ),
                baseURL: Fixtures.anyBaseURL
            )
        }

        func givenAnyErrorResponse() throws {
            try HTTPStubProtocol.stub(
                Fixtures.anyError,
                statusCode: 404,
                for: APIRequest<User, Error>.get(
                    "/user",
                    headers: [.authorization: "Bearer 3xpo"],
                    parameters: ["api_key": "test"]
                ),
                baseURL: Fixtures.anyBaseURL
            )
        }

        func givenEmptyErrorResponse() {
            HTTPStubProtocol.stub(
                "",
                statusCode: 404,
                for: APIRequest<User, Error>.get(
                    "/user",
                    headers: [.authorization: "Bearer 3xpo"],
                    parameters: ["api_key": "test"]
                ),
                baseURL: Fixtures.anyBaseURL
            )
        }

        func givenInvalidErrorResponse() {
            HTTPStubProtocol.stub(
                "invalid",
                statusCode: 404,
                for: APIRequest<User, Error>.get(
                    "/user",
                    headers: [.authorization: "Bearer 3xpo"],
                    parameters: ["api_key": "test"]
                ),
                baseURL: Fixtures.anyBaseURL
            )
        }

        func givenAnyInvalidResponse() {
            HTTPStubProtocol.stub(
                "invalid",
                statusCode: 200,
                for: APIRequest<User, Error>.get(
                    "/user",
                    headers: [.authorization: "Bearer 3xpo"],
                    parameters: ["api_key": "test"]
                ),
                baseURL: Fixtures.anyBaseURL
            )
        }
    }
#endif
