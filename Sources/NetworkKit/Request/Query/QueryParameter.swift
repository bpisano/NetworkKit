import Foundation

public struct QueryParameter: RequestModifier {
    public let key: String
    public let value: String?

    public init<T: QueryRepresentable>(key: String, value: T?) {
        self.key = key
        self.value = value?.queryValue
    }

    func modify(_ urlRequest: inout URLRequest) throws {
        guard let value = value else { return }
        urlRequest.url = urlRequest.url?.appendingQueryParameter(key, with: value)
    }
}
