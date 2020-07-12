#if canImport(UIKit)
    import Combine
    import Foundation
    import UIKit

    @available(*, deprecated, message: "This functionality has been moved to https://github.com/gonzalezreal/NetworkImage")
    public final class ImagePrefetcher {
        private let session: URLSession
        private var subscriptions: [URL: AnyCancellable] = [:]

        public init(session: URLSession = .sharedImage) {
            self.session = session
        }

        public func prefetchImages(with urls: Set<URL>) {
            assert(Thread.isMainThread)

            for url in urls where !subscriptions.keys.contains(url) {
                subscriptions[url] = session.dataTaskPublisher(for: url)
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            }
        }

        public func cancelPrefetchingImages(with urls: Set<URL>) {
            assert(Thread.isMainThread)

            for url in urls {
                subscriptions.removeValue(forKey: url)
            }
        }
    }
#endif
