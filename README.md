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
    // Popular movies
    static func popularMovies(page: Int) -> Endpoint {
        return Endpoint(method: .get,
                        path: "movie/popular",
                        queryParameters: ["page": String(page)],
                        dateDecodingStrategy: .formatted(.theMovieDb))
    }
}

extension Endpoint where Output == Session {
    // Create session
    static func session(with token: Token) -> Endpoint {
        return Endpoint(method: .post,
                        path: "authentication/session/new",
                        body: token)
    }
}
```

## Configuring API clients
Configuring additional headers and query parameters. Creating the API client with a base url.

## Combining and transforming responses
Zip configuration, genres and popular movies / transform into a view model.

## Downloading images
Downloading and prefetching / transforming images. prepareForReuse.

## Stubbing network requests
Provide an example to stub a network request.

## Installation
**Using the Swift Package Manager**

Add Reusable as a dependency to your `Package.swift` file. For more information, see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

```
.package(url: "https://github.com/gonzalezreal/SimpleNetworking", from: "1.0.0")
```

## Help & Feedback
- [Open an issue](https://github.com/gonzalezreal/SimpleNetworking/issues/new) if you need help, if you found a bug, or if you want to discuss a feature request.
- [Open a PR](https://github.com/gonzalezreal/SimpleNetworking/pull/new/master) if you want to make some change to `SimpleNetworking`.
- Contact [@gonzalezreal](https://twitter.com/gonzalezreal) on Twitter.
