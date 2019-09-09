import XCTest
@testable import weather

final class HttpServiceTests: XCTestCase {
    private var service: HttpServiceProtocol!
    private var session: MockSession!
    private var dataTask: MockDataTask!

    override func setUp() {
        super.setUp()
        session = MockSession()
        service = HttpService(urlSession: session)
    }

    func test_givenValidData_shouldParseSuccessfully() {
        service.get(urlRequest: URLRequest(url: URL(string: "foo")!)) { (result: (Result<MockData, NetworkError>)) in
            if case let .success(response) = result {
                XCTAssertEqual(response.id, "foo")
                XCTAssertEqual(self.session.callCount, 1)
            } else {
                XCTFail()
            }
        }

        XCTAssertEqual(self.session.dataTask.callCount, 1)
    }

    func test_givenError_shouldFailWithAnError() {
        session.error = true
        service.get(urlRequest: URLRequest(url: URL(string: "foo")!)) { (result: (Result<MockData, NetworkError>)) in
            if case let .failure(error) = result {
                XCTAssertEqual(error, NetworkError.server(NSError()))
                XCTAssertEqual(self.session.callCount, 1)
            } else {
                XCTFail()
            }
        }

        XCTAssertEqual(self.session.dataTask.callCount, 1)
    }

    final class MockSession: Verifiable, URLSessionProtocol {
        let dataTask = MockDataTask()
        var error = false
        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
            callCount += 1
            if error {
                completionHandler(nil, nil, MockError.generic)
            } else {
                completionHandler(Data("""
                                        {"id": "foo"}
                                        """.utf8), nil, nil)
            }
            
            return dataTask
        }
    }

    final class MockDataTask: Verifiable, URLSessionDataTaskProtocol {
        func resume() {
            callCount += 1
        }
    }

    struct MockData: Codable {
        let id: String
    }
}

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
}
