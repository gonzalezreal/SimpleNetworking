import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(APIClientTest.allTests),
            testCase(EndpointTest.allTests),
            testCase(URLRequestAdditionsTest.allTests),
        ]
    }
#endif
