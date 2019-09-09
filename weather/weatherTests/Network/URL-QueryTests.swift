import XCTest
@testable import weather

class URL_QueryTests: XCTestCase {
    func test_givenUrlParams_shouldQuery() {
        let expected = "http://foo?key1=param1&key2=param2"

        let url = URL(string: "http://foo")?
            .appendingParameters(urlParameters: [("key1", "param1"),
                                                 ("key2", "param2")])

        XCTAssertEqual(url?.absoluteString, expected) 
    }
}
