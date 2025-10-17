import Foundation

public protocol QueryRepresentable {
    var queryValue: String { get }
}

// MARK: - String Types

extension String: QueryRepresentable {
    public var queryValue: String { self }
}

extension Substring: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension Character: QueryRepresentable {
    public var queryValue: String { String(self) }
}

// MARK: - Signed Integer Types

extension Int: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension Int8: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension Int16: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension Int32: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension Int64: QueryRepresentable {
    public var queryValue: String { String(self) }
}

// MARK: - Unsigned Integer Types

extension UInt: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension UInt8: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension UInt16: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension UInt32: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension UInt64: QueryRepresentable {
    public var queryValue: String { String(self) }
}

// MARK: - Floating Point Types

extension Float: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension Double: QueryRepresentable {
    public var queryValue: String { String(self) }
}

extension Decimal: QueryRepresentable {
    public var queryValue: String { String(describing: self) }
}

// MARK: - Boolean Type

extension Bool: QueryRepresentable {
    public var queryValue: String { self ? "true" : "false" }
}

// MARK: - Foundation Types

extension UUID: QueryRepresentable {
    public var queryValue: String { self.uuidString }
}

extension Date: QueryRepresentable {
    public var queryValue: String { String(self.timeIntervalSince1970) }
}

extension URL: QueryRepresentable {
    public var queryValue: String { self.absoluteString }
}

extension NSNumber: QueryRepresentable {
    public var queryValue: String { self.stringValue }
}

// MARK: - Array Extension

extension Array where Element: QueryRepresentable {
    public var queryValue: String {
        self.map { $0.queryValue }.joined(separator: ",")
    }
}
