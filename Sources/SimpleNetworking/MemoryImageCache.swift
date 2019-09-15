#if os(iOS) || os(tvOS)
    import Foundation
    import UIKit

    public final class MemoryImageCache {
        private enum Constants {
            static let defaultCapacity = 10 * 1024 * 1024
        }

        public static let shared = MemoryImageCache(capacity: Constants.defaultCapacity)

        private let cache: NSCache<NSURL, UIImage>

        public init(capacity: Int) {
            cache = NSCache<NSURL, UIImage>()
            cache.totalCostLimit = capacity
        }

        public func image(for url: URL) -> UIImage? {
            return cache.object(forKey: url as NSURL)
        }

        public func setImage(_ image: UIImage, for url: URL) {
            cache.setObject(image, forKey: url as NSURL, cost: image.cost)
        }
    }

    private extension UIImage {
        var cost: Int {
            guard let cgImage = self.cgImage else { return 0 }
            return (cgImage.bytesPerRow) * cgImage.height
        }
    }
#endif
