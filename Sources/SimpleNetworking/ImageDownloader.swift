#if canImport(UIKit)
    import Combine
    import Foundation
    import UIKit

    public final class ImageDownloader {
        private let session: URLSession
        private let imageCache: ImageCache

        public convenience init(session: URLSession = .sharedImage) {
            self.init(session: session, imageCache: ImmediateCache.shared)
        }

        internal init(session: URLSession, imageCache: ImageCache) {
            self.session = session
            self.imageCache = imageCache
        }

        public func image(withURL url: URL) -> AnyPublisher<UIImage, Error> {
            if let image = imageCache.image(for: url) {
                return Just(image).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
                return session.dataTaskPublisher(for: url)
                    .tryMap { [imageCache] data, response in
                        if let httpResponse = response as? HTTPURLResponse {
                            guard 200 ..< 300 ~= httpResponse.statusCode else {
                                throw BadStatusError(data: data, response: httpResponse)
                            }
                        }

                        let image = try UIImage.makeImage(with: data)
                        imageCache.setImage(image, for: url)

                        return image
                    }
                    .eraseToAnyPublisher()
            }
        }
    }
#endif
