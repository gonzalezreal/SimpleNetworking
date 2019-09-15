#if os(iOS) || os(tvOS)
    import Foundation
    import UIKit

    public final class ImagePrefetcher {
        public let session: URLSession
        public let imageCache: MemoryImageCache

        private var tasks: [URL: URLSessionDataTask] = [:]

        public init(session: URLSession = .imageSession, imageCache: MemoryImageCache = .shared) {
            self.session = session
            self.imageCache = imageCache
        }

        deinit {
            tasks.values.forEach { $0.cancel() }
        }

        public func prefetchImages(with urls: Set<URL>) {
            assert(Thread.isMainThread)

            for url in urls {
                guard !tasks.keys.contains(url) else { continue }

                let task = session.dataTask(with: url) { [weak self] data, _, _ in
                    guard let self = self else { return }

                    if let data = data, let image = try? UIImage.makeImage(with: data) {
                        self.imageCache.setImage(image, for: url)
                    }

                    DispatchQueue.main.async {
                        self.tasks.removeValue(forKey: url)
                    }
                }

                tasks[url] = task
                task.resume()
            }
        }

        public func cancelPrefetchingImages(with urls: Set<URL>) {
            assert(Thread.isMainThread)

            for url in urls {
                tasks[url]?.cancel()
                tasks.removeValue(forKey: url)
            }
        }
    }
#endif
