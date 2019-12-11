#if canImport(UIKit)
    import Combine
    import Foundation
    import UIKit

    public final class ImageDownloader {
        public let session: URLSession
        public let immediateCache = ImmediateCache.shared

        public init(session: URLSession = .sharedImage) {
            self.session = session
        }

        public func image(withURL url: URL) -> AnyPublisher<UIImage, Error> {
            if let image = immediateCache.image(for: url) {
                return Just(image).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
                return session.dataTaskPublisher(for: url)
                    .tryMap { [immediateCache] data, response in
                        let httpResponse = response as! HTTPURLResponse

                        guard 200 ..< 300 ~= httpResponse.statusCode else {
                            throw BadStatusError(data: data, response: httpResponse)
                        }

                        let image = try UIImage.makeImage(with: data)
                        immediateCache.setImage(image, for: url)

                        return image
                    }
                    .eraseToAnyPublisher()
            }
        }
    }
#endif
