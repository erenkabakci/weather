import Foundation

enum MockError: Error {
    case generic
}

class Verifiable {
    var callCount = 0
}
