# SimpleNetworking
![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS+tvOS+macOS-brightgreen.svg?style=flat)
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![Twitter: @gonzalezreal](https://img.shields.io/badge/twitter-@gonzalezreal-blue.svg?style=flat)](https://twitter.com/gonzalezreal)

**SimpleNetworking** is a Swift Package that helps you create scalable API clients. It uses [Combine](https://developer.apple.com/documentation/combine) to expose API responses, making it easy to compose and transform them.

It also includes other goodies, like image downloading and caching, and network request stubbing.

Let's explore all the features using [The Movie Database API](https://developers.themoviedb.org/3) as an example.

## Creating Endpoints
The `Endpoint` struct encapsulates an API request as well as the result type of the responses for that request.

For example, to implement the [Configuration Endpoint](https://developers.themoviedb.org/3/configuration/get-api-configuration), we start with the response model:

```Swift
struct Configuration: Codable {
    struct Images: Codable {
        let secureBaseURL: URL
        ...
    }
    
    let images: Images
    let changeKeys: [String]

    enum CodingKeys: String, CodingKey {
        case images
        case changeKeys = "change_keys"
    }
}
```

We could create our endpoint as follows:

```Swift
let endpoint = Endpoint<Configuration>(method: .get, path: "configuration")
```

But we want our endpoints to be reusable, so we can implement a factory method or a static property in an extension:

```Swift
extension Endpoint where Output == Configuration {
    static let configuration = Endpoint(method: .get, path: "configuration")
}
```

This way, you could obtain responses from that endpoint as follows:

```Swift
cancellable = theMovieDbClient.response(for: .configuration).sink(receiveValue: { config in
    print("base url for images: \(config.images.secureBaseURL)")
})
```

You can customize many properties of an `Endpoint`: headers, query parameters, body, etc. Here are some additional examples:

```Swift
extension Endpoint where Output == Page<MovieResult> {
    static func popularMovies(page: Int) -> Endpoint {
        return Endpoint(method: .get,
                        path: "movie/popular",
                        queryParameters: ["page": String(page)],
                        dateDecodingStrategy: .formatted(.theMovieDb))
    }
}

extension Endpoint where Output == Session {
    static func session(with token: Token) -> Endpoint {
        return Endpoint(method: .post,
                        path: "authentication/session/new",
                        body: token)
    }
}
```

## Configuring API clients
When creating an API client, you must specify a base URL and, optionally, the additional headers and query parameters that go with each request.

```Swift
extension APIClient {
    static func theMovieDb(apiKey: String, language: String) -> APIClient {
        var configuration = APIClientConfiguration()
        configuration.additionalQueryParameters = [
            "api_key": apiKey,
            "language": language,
        ]
        return APIClient(baseURL: URL(string: "https://api.themoviedb.org/3")!, configuration: configuration)
    }
}
```

## Combining and transforming responses
Since `APIClient.response(from:)` method returns a [`Publisher`](https://developer.apple.com/documentation/combine/publisher), it is quite simple to combine responses and transform them for presentation.

Consider, for example, that we have to present a list of popular movies; including their title, genre, and cover. To build that list we need information from three different endpoints:
* `.configuration`, to obtain the image base URL.
* `.movieGenres`, to obtain the movie genres by id.
* `.popularMovies(page:)`, to obtain the list of movies sorted by popularity.

We could model an item in that list as follows:

```Swift
struct MovieItem {
    let title: String
    let genres: String
    let posterURL: URL?
    
    init(movieResult: MovieResult, imageBaseURL: URL, movieGenres: GenreList) {
        ...
    }
}
```

To build the list, we can use the `zip` operator with the publishers returned by the `APIClient`.

```Swift
func popularItems() -> AnyPublisher<[MovieItem], Error> {
    return Publishers.Zip3(theMovieDbClient.response(for: .popularMovies(page: 1)),
                           theMovieDbClient.response(for: .configuration),
                           theMovieDbClient.response(for: .movieGenres))
        .map { (page, config, genres) -> [MovieItem] in
            let url = config.images.secureBaseURL
            return page.results.map { MovieItem(movieResult: $0, imageBaseURL: url, movieGenres: genres) }
        }
        .eraseToAnyPublisher()
}
```

## Downloading images
You can use `ImageDownloader` to download images in your views and take advantage of Combine operators to apply transformations to them. `ImageDownloader` leverages the foundation [`URLCache`](https://developer.apple.com/documentation/foundation/urlcache), providing a persistent disk cache and two in-memory caches.

```Swift
class MovieItemCell: UICollectionViewCell {
    // ...
    private lazy var imageView = ImageView()
    private let imageDownloader = ImageDownloader()
    private var cancellable: AnyCancellable?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
    }
    
    func configure(with movieItem: MovieItem) {
        // ...
        cancellable = imageDownloader.image(withURL: movieItem.posterURL)
            .map { $0.applyFancyEffect() }
            .replaceError(with: placeholderImage)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: imageView)
    }
}
```

You can also preload images and warm the caches up by using an instance of `ImagePrefetcher`.

```Swift
extension MovieListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        imagePrefetcher.prefetchImages(with: imageURLs(at: indexPaths))
    }

    func collectionView(_: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        imagePrefetcher.cancelPrefetchingImages(with: imageURLs(at: indexPaths))
    }
}
```

## Stubbing network requests
Provide an example to stub a network request.

## Installation
**Using the Swift Package Manager**

Add SimpleNetworking as a dependency to your `Package.swift` file. For more information, see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

```
.package(url: "https://github.com/gonzalezreal/SimpleNetworking", from: "1.0.0")
```

## Help & Feedback
- [Open an issue](https://github.com/gonzalezreal/SimpleNetworking/issues/new) if you need help, if you found a bug, or if you want to discuss a feature request.
- [Open a PR](https://github.com/gonzalezreal/SimpleNetworking/pull/new/master) if you want to make some change to `SimpleNetworking`.
- Contact [@gonzalezreal](https://twitter.com/gonzalezreal) on Twitter.
