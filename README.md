# SimpleNetworking
![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS+tvOS+macOS-brightgreen.svg?style=flat)
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![Twitter: @gonzalezreal](https://img.shields.io/badge/twitter-@gonzalezreal-blue.svg?style=flat)](https://twitter.com/gonzalezreal)

**SimpleNetworking** is a Swift Package that helps you create scalable API clients. It uses [Combine](https://developer.apple.com/documentation/combine) to expose API responses, making it easy to compose and transform them.

It also includes other goodies, like image downloading and caching, and network request stubbing.

Let's explore all the features using [The Movie Database API](https://developers.themoviedb.org/3) as an example.

- [Creating Endpoints](#creating-endpoints)
- [Configuring API clients](#configuring-api-clients)
- [Combining and transforming responses](#combining-and-transforming-responses)
- [Logging](#logging)
- [Downloading images](#downloading-images)
- [Stubbing network requests](#stubbing-network-requests)
- [Installation](#installation)
- [Help & Feedback](#help--feedback)

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
let subscription = theMovieDbClient.response(for: .configuration).sink(receiveValue: { config in
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

## Logging
The `APIClient` class uses [SwiftLog](https://github.com/apple/swift-log) to log requests and responses. If you set its `logger.logLevel` to `.debug` you will start seeing requests and responses as they happen in your logs.

```Swift
let apiClient = APIClient(baseURL: URL(string: "https://api.themoviedb.org/3")!)
apiClient.logger.logLevel = .debug
```

Here is an example of the output using the default `StreamLogHandler`:

```
2019-12-15T17:18:47+0100 debug: [REQUEST] GET https://api.themoviedb.org/3/genre/movie/list?language=en
├─ Headers
│ Accept: application/json
2019-12-15T17:18:47+0100 debug: [RESPONSE] 200 https://api.themoviedb.org/3/genre/movie/list?language=en
├─ Headers
│ access-control-expose-headers: ETag, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, Retry-After, Content-Length, Content-Range
│ Content-Type: application/json;charset=utf-8
│ x-ratelimit-reset: 1576426582
│ Server: openresty
│ Etag: "df2617d2ab5d0c85ceff5098b8ab70c4"
│ Cache-Control: public, max-age=28800
│ access-control-allow-methods: GET, HEAD, POST, PUT, DELETE, OPTIONS
│ Access-Control-Allow-Origin: *
│ Date: Sun, 15 Dec 2019 16:16:14 GMT
│ x-ratelimit-remaining: 39
│ Content-Length: 547
│ x-ratelimit-limit: 40
├─ Content
 {
   "genres" : [
     {
       "id" : 28,
       "name" : "Action"
     },
     {
       "id" : 12,
       "name" : "Adventure"
     },
 ...
```

If you want to use [Apple's Unified Logging](https://developer.apple.com/documentation/os/logging) for your logs, you might want to try [UnifiedLogHandler](https://github.com/gonzalezreal/UnifiedLogging).

## Downloading images
You can use `ImageDownloader` to download images in your views and take advantage of Combine operators to apply transformations to them. `ImageDownloader` leverages the foundation [`URLCache`](https://developer.apple.com/documentation/foundation/urlcache), providing persistent and in-memory caches.

```Swift
class MovieItemCell: UICollectionViewCell {
    // ...
    private lazy var imageView = ImageView()
    private let imageDownloader = ImageDownloader()
    private var subscription: AnyCancellable?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscription?.cancel()
    }
    
    func configure(with movieItem: MovieItem) {
        // ...
        subscription = imageDownloader.image(withURL: movieItem.posterURL)
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
Stubbing network requests can be useful when you are writing UI or integration tests and don't want to depend on the network being reachable.

You can use `HTTPStubProtocol` to stub a network request as follows:

```Swift
var request = URLRequest(url: Fixtures.anyURLWithPath("user", query: "api_key=test"))
request.addValue(ContentType.json.rawValue, forHTTPHeaderField: HeaderField.accept.rawValue)
request.addValue("Bearer 3xpo", forHTTPHeaderField: HeaderField.authorization.rawValue)

HTTPStubProtocol.stubRequest(request, data: Fixtures.anyJSON, statusCode: 200)
```

For this to have the desired effect, you need to pass `URLSession.stubbed` as a parameter when constructing the `APIClient`.

```Swift
override func setUp() {
    super.setUp()

    sut = APIClient(baseURL: Fixtures.anyBaseURL, configuration: configuration, session: .stubbed)
}
```

You can check out [`APIClientTest`](Tests/SimpleNetworkingTests/APIClientTest.swift) for more information.

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
