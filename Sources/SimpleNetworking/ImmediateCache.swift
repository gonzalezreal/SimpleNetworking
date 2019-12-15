#if canImport(UIKit)
    import Foundation
    import UIKit

    public final class ImmediateCache {
        public static let shared = ImmediateCache()
        private let cache = NSCache<NSURL, UIImage>()

        public func image(for url: URL) -> UIImage? {
            cache.object(forKey: url as NSURL)
        }

        public func setImage(_ image: UIImage, for url: URL) {
            cache.setObject(image, forKey: url as NSURL)
        }
    }
#endif
