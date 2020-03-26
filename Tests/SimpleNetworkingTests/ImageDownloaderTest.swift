#if canImport(UIKit)
    import Combine
    @testable import SimpleNetworking
    import UIKit
    import XCTest

    final class ImageDownloaderTest: XCTestCase {
        private class NoopImageCache: ImageCache {
            func image(for _: URL) -> UIImage? {
                nil
            }

            func setImage(_: UIImage, for _: URL) {}
        }

        private var sut: ImageDownloader!
        private var cancellables = Set<AnyCancellable>()

        override func setUp() {
            super.setUp()

            sut = ImageDownloader(session: .stubbed, imageCache: NoopImageCache())
        }

        override func tearDown() {
            HTTPStubProtocol.removeAllStubs()
            super.tearDown()
        }

        func testAnyImageResponseReturnsImage() {
            // given
            givenAnyImageResponse()
            let didReceiveValue = expectation(description: "didReceiveValue")
            var result: UIImage?

            // when
            sut.image(withURL: Fixtures.anyImageURL)
                .assertNoFailure()
                .sink(receiveValue: {
                    result = $0
                    didReceiveValue.fulfill()
                })
                .store(in: &cancellables)

            // then
            wait(for: [didReceiveValue], timeout: 1)
            XCTAssertNotNil(result)
        }

        func testBadStatusResponseFailsWithBadStatusError() {
            // given
            givenBadStatusResponse()
            let didFail = expectation(description: "didFail")
            var result: Error?

            // when
            sut.image(withURL: Fixtures.anyImageURL)
                .catch { error -> Just<UIImage> in
                    result = error
                    didFail.fulfill()
                    return Just(UIImage())
                }
                .sink(receiveValue: { _ in })
                .store(in: &cancellables)

            // then
            wait(for: [didFail], timeout: 1)

            let badStatusError = result as? BadStatusError
            XCTAssertEqual(500, badStatusError?.statusCode)
        }

        func testAnyResponseFailsWithImageDecodingError() {
            // given
            givenAnyResponse()
            let didFail = expectation(description: "didFail")
            var result: Error?

            // when
            sut.image(withURL: Fixtures.anyImageURL)
                .catch { error -> Just<UIImage> in
                    result = error
                    didFail.fulfill()
                    return Just(UIImage())
                }
                .sink(receiveValue: { _ in })
                .store(in: &cancellables)

            // then
            wait(for: [didFail], timeout: 1)

            let imageDecodingError = result as? ImageDecodingError
            XCTAssertEqual(Fixtures.anyJSON, imageDecodingError?.data)
        }

        func testAnyDataImageURLReturnsImage() {
            // given
            let didReceiveValue = expectation(description: "didReceiveValue")
            var result: UIImage?

            // when
            sut.image(withURL: Fixtures.anyDataImageURL)
                .assertNoFailure()
                .sink(receiveValue: {
                    result = $0
                    didReceiveValue.fulfill()
                })
                .store(in: &cancellables)

            // then
            wait(for: [didReceiveValue], timeout: 1)
            XCTAssertNotNil(result)
        }
    }

    private extension ImageDownloaderTest {
        func givenAnyImageResponse() {
            let request = URLRequest(url: Fixtures.anyImageURL)
            HTTPStubProtocol.stubRequest(request, data: Fixtures.anyImage, statusCode: 200)
        }

        func givenBadStatusResponse() {
            let request = URLRequest(url: Fixtures.anyImageURL)
            HTTPStubProtocol.stubRequest(request, data: Data(), statusCode: 500)
        }

        func givenAnyResponse() {
            let request = URLRequest(url: Fixtures.anyImageURL)
            HTTPStubProtocol.stubRequest(request, data: Fixtures.anyJSON, statusCode: 200)
        }
    }
#endif
