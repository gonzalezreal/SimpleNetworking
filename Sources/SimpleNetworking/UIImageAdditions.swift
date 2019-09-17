#if canImport(UIKit)
    import UIKit

    public struct ImageDecodingError: Error {
        public let data: Data
    }

    internal extension UIImage {
        static func makeImage(with data: Data) throws -> UIImage {
            guard let image = UIImage(data: data, scale: UIScreen.main.scale) else {
                throw ImageDecodingError(data: data)
            }

            // Inflates the underlying compressed image data to be backed by an uncompressed bitmap representation.
            _ = image.cgImage?.dataProvider?.data

            return image
        }
    }
#endif
