# SimpleNetworking
![Swift 5.2](https://img.shields.io/badge/Swift-5.2-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-macOS+iOS+tvOS+watchOS-brightgreen.svg?style=flat)
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![Twitter: @gonzalezreal](https://img.shields.io/badge/twitter-@gonzalezreal-blue.svg?style=flat)](https://twitter.com/gonzalezreal)

**SimpleNetworking** is a Swift Package that helps you create scalable API clients, simple and elegantly. It uses [Combine](https://developer.apple.com/documentation/combine) to expose API responses, making it easy to compose and transform them.

It also includes other goodies, like logging and response stubbing.

Let's explore all the features using [The Movie Database API](https://developers.themoviedb.org/3) as an example.

- [Configuring the API client](#configuring-the-api-client)
- [Creating API requests](#creating-api-requests)
- [Handling errors](#handling-errors)
- [Combining and transforming responses](#combining-and-transforming-responses)

- [Logging](#logging)
- [Stubbing network requests](#stubbing-network-requests)
- [Installation](#installation)
- [Help & Feedback](#help--feedback)

## Configuring the API client
The API client is responsible for making requests to an API and handling its responses. To create an API client, you need to provide the base URL and, optionally, any additional parameters or headers that you would like to append to all requests, like an API key or an authorization header.

```swift
let tmdbClient = APIClient(
    baseURL: URL(string: "https://api.themoviedb.org/3")!,
    configuration: APIClientConfiguration(
        additionalParameters: [
            "api_key": "20495f041a8caac8752afc86",
            "language": "es",
        ]
    )
)
```

## Creating API requests
The `APIRequest` type contains all the data required to make an API request, as well as the logic to decode valid and error responses from the request's endpoint.

Before creating an API request, we need to model its valid and error responses, preferably as types conforming to `Decodable`.

Usually, an API defines different valid response models, depending on the request, but a single error response model for all the requests. In the case of The Movie Database API, error responses take the form of a [`Status`](https://www.themoviedb.org/documentation/api/status-codes) value:

```Swift
struct Status: Decodable {
    var code: Int
    var message: String

    enum CodingKeys: String, CodingKey {
        case code = "status_code"
        case message = "status_message"
    }
}
```

Now, consider the [`GET /genre/movie/list`](https://developers.themoviedb.org/3/genres/get-movie-list) API request. This request returns the official list of genres for movies. We could implement a `GenreList` type for its response:

```Swift
struct Genre: Decodable {
    var id: Int
    var name: String
}

struct GenreList: Decodable {
    var genres: [Genre]
}
```

With these response models in place, we are ready to create the API request:

```Swift
let movieGenresRequest = APIRequest<GenreList, Status>.get("/genre/movie/list")
```

But we can do better, and extend `APIClient` to provide a method to get the movie genres:

```Swift
extension APIClient {
    func movieGenres() -> AnyPublisher<GenreList, APIClientError<Status>> {
        response(for: .get("/genre/movie/list"))
    }
}
```

The `response(for:)` method takes an `APIRequest` and returns a publisher that wraps sending the request and decoding its response. We can implement all the API methods by relying on it:

```Swift
extension APIClient {
    func createSession(with token: Token) -> AnyPublisher<Session, APIClientError<Status>> {
        response(for: .post("/authentication/session/new", body: token))
    }
    
    func deleteSession(_ session: Session) -> AnyPublisher<Void, APIClientError<Status>> {
        response(for: .delete("/authentication/session", body: session))
    }
    
    ...
    
    func popularMovies(page: Int) -> AnyPublisher<Page<Movie>, APIClientError<Status>> {
        response(for: .get("/movie/popular", parameters: ["page": page]))
    }
    
    func topRatedMovies(page: Int) -> AnyPublisher<Page<Movie>, APIClientError<Status>> {
        response(for: .get("/movie/top_rated", parameters: ["page": page]))
    }
    
    ...
}
```

## Handling errors
Your app must be prepared to handle errors when working with an API client. **SimpleNetworking** provides [`APIClientError`](Sources/SimpleNetworking/APIClientError.swift), which unifies URL loading errors, JSON decoding errors, and specific API error responses in a single generic type.

```Swift
let cancellable = tmdbClient.movieGenres()
    .catch { error in
        switch error {
        case .loadingError(let loadingError):
            // Handle URL loading errors
            ...
        case .decodingError(let decodingError):
            // Handle JSON decoding errors
            ...
        case .apiError(let apiError):
            // Handle specific API errors
            ...
        }
    }
    .sink { movieGenres in
        // handle response
    }
```

The generic [`APIError`](Sources/SimpleNetworking/APIError.swift) type provides access to the HTTP status code and the API error response. 

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
    return Publishers.Zip3(
        theMovieDbClient.response(for: .popularMovies(page: 1)),
        theMovieDbClient.response(for: .configuration),
        theMovieDbClient.response(for: .movieGenres)
    )
    .map { (page, config, genres) -> [MovieItem] in
        let url = config.images.secureBaseURL
        return page.results.map {
            MovieItem(movieResult: $0, imageBaseURL: url, movieGenres: genres)
        }
    }
    .eraseToAnyPublisher()
}
```

## Logging
The `APIClient` class uses [SwiftLog](https://github.com/apple/swift-log) to log requests and responses. If you set its `logger.logLevel` to `.debug` you will start seeing requests and responses as they happen in your logs.

```Swift
let apiClient = APIClient(baseURL: URL(string: "https://api.themoviedb.org/3")!, logLevel: .debug)
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
.package(url: "https://github.com/gonzalezreal/SimpleNetworking", from: "1.3.0")
```

## Related projects
- [NetworkImage](https://github.com/gonzalezreal/NetworkImage)
- [UnifiedLogHandler](https://github.com/gonzalezreal/UnifiedLogging)

## Help & Feedback
- [Open an issue](https://github.com/gonzalezreal/SimpleNetworking/issues/new) if you need help, if you found a bug, or if you want to discuss a feature request.
- [Open a PR](https://github.com/gonzalezreal/SimpleNetworking/pull/new/master) if you want to make some change to `SimpleNetworking`.
- Contact [@gonzalezreal](https://twitter.com/gonzalezreal) on Twitter.
