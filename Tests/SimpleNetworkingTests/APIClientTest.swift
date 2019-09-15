import Combine
@testable import SimpleNetworking
import XCTest

final class APIClientTest: XCTestCase {
    private var sut: APIClient!
    private let configuration = APIClientConfiguration(additionalHeaders: [.authorization: "Bearer 3xpo"],
                                                       additionalQueryParameters: ["api_key": "test"])
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
        let didReceiveValue = expectation(description: "receiveValue")
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
        XCTAssertEqual(result, Fixtures.anyUser)
    }

    func testBadStatusResponseFailsWithBadStatusError() {
        // given
        givenBadStatusResponse()
        let endpoint = Endpoint<User>(method: .get, path: "user")
        let didFail = expectation(description: "failed")
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
        XCTAssertEqual(badStatusError?.statusCode, 500)
    }

    static var allTests = [
        ("testAnyJSONResponseReturnsOutput", testAnyJSONResponseReturnsOutput),
        ("testBadStatusResponseFailsWithBadStatusError", testBadStatusResponseFailsWithBadStatusError),
    ]
}

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
