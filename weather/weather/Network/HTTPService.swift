import Foundation

enum NetworkError: Error {
    case server(_: Error?)
    case decodingFailure
    case unknown
}

protocol HttpServiceProtocol {
    func get<T: Decodable>(urlRequest: URLRequest, completion: @escaping ((Result<T, NetworkError>) -> Void))
}

final class HttpService: HttpServiceProtocol {
    private let session: URLSessionProtocol
    private let decoder = JSONDecoder()

    init(urlSession: URLSessionProtocol = URLSession(configuration: URLSessionConfiguration.default,
                                                     delegate: nil,
                                                     delegateQueue: nil)) {
        session = urlSession
        decoder.dateDecodingStrategy = .millisecondsSince1970
    }

    func get<T>(urlRequest: URLRequest, completion: @escaping ((Result<T, NetworkError>) -> Void)) where T : Decodable {
        let task = session.dataTask(with: urlRequest) { data, _, error in

            guard error == nil else { return completion(.failure(.server(error))) }
            guard let responseData = data else { return completion(.failure(.unknown)) }

            do {
                let model = try JSONDecoder().decode(T.self, from: responseData)
                completion(.success(model))

            } catch {
                completion(.failure(.decodingFailure))
            }
        }

        task.resume()
    }
}
