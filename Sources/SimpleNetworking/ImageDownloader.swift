#if os(iOS) || os(tvOS)
    import Combine
    import Foundation
    import UIKit

    public final class ImageDownloader {
        public let session: URLSession
        public let imageCache: MemoryImageCache

        public init(session: URLSession = .imageSession, imageCache: MemoryImageCache = .shared) {
            self.session = session
            self.imageCache = imageCache
        }

        public func image(withURL url: URL) -> AnyPublisher<UIImage, Error> {
            if let image = imageCache.image(for: url) {
                return Just(image).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
                return session.dataTaskPublisher(for: url)
                    .tryMap { data, response in
                        let httpResponse = response as! HTTPURLResponse

                        guard 200 ..< 300 ~= httpResponse.statusCode else {
                            throw BadStatusError(data: data, response: httpResponse)
                        }

                        return try UIImage.makeImage(with: data)
                    }
                    .handleEvents(receiveOutput: { [imageCache] image in
                        imageCache.setImage(image, for: url)
                    })
                    .eraseToAnyPublisher()
            }
        }
    }
#endif
