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

    init(urlSession: URLSessionProtocol = URLSession(configuration: URLSessionConfiguration(),
                                                     delegate: nil,
                                                     delegateQueue: nil)) {
        session = urlSession
    }

    func get<T>(urlRequest: URLRequest, completion: @escaping ((Result<T, NetworkError>) -> Void)) where T : Decodable {
        let task = session.dataTask(with: urlRequest) { data, response, error in

            guard error == nil else { return completion(.failure(.server(error))) }
            guard response == nil,
                let data = data else { return completion(.failure(.unknown)) }

            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))

            } catch {
                completion(.failure(.decodingFailure))
            }
        }

        task.resume()
    }
}
