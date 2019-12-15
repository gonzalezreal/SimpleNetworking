import Foundation

public final class HTTPStubProtocol: URLProtocol {
    private struct Stub {
        let data: Data
        let response: HTTPURLResponse
    }

    private static var stubs: [URLRequest: Stub] = [:]

    public static func stubRequest(_ request: URLRequest, data: Data, statusCode: Int, headers: [String: String]? = nil) {
        let response = HTTPURLResponse(url: request.url!,
                                       statusCode: statusCode,
                                       httpVersion: "HTTP/1.1",
                                       headerFields: headers)
        stubs[request] = Stub(data: data, response: response!)
    }

    public static func removeAllStubs() {
        stubs.removeAll()
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        stubs.keys.contains(request)
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    public override class func requestIsCacheEquivalent(_: URLRequest, to _: URLRequest) -> Bool {
        false
    }

    public override func startLoading() {
        guard let stub = HTTPStubProtocol.stubs[request] else {
            fatalError("Couldn't find stub for request \(request)")
        }

        client!.urlProtocol(self, didReceive: stub.response, cacheStoragePolicy: .notAllowed)
        client!.urlProtocol(self, didLoad: stub.data)
        client!.urlProtocolDidFinishLoading(self)
    }

    public override func stopLoading() {}
}
