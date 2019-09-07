import Foundation

extension URL {

    func appendingParameters(urlParameters: [(String, String)]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            fatalError("Can't resolve the parameters")
        }
        let queryItems = urlParameters.map(URLQueryItem.init)
        components.queryItems = queryItems

        guard let url = components.url else {
            fatalError("Can't construct the URL")
        }
        return url
    }
}
