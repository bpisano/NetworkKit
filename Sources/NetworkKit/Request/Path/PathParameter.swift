import Foundation

public struct PathParameter: RequestModifier {
    public let key: String
    public let value: String

    public init<T: PathRepresentable>(key: String, value: T) {
        self.key = key
        self.value = value.pathValue
    }

    func modify(_ urlRequest: inout URLRequest) throws {
        urlRequest.url = urlRequest.url?.replacingPathParameter(key, with: value)
    }
}
