import Foundation

public protocol PathRepresentable {
    var pathValue: String { get }
}

// MARK: - String Types

extension String: PathRepresentable {
    public var pathValue: String { self }
}

extension Substring: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension Character: PathRepresentable {
    public var pathValue: String { String(self) }
}

// MARK: - Signed Integer Types

extension Int: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension Int8: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension Int16: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension Int32: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension Int64: PathRepresentable {
    public var pathValue: String { String(self) }
}

// MARK: - Unsigned Integer Types

extension UInt: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension UInt8: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension UInt16: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension UInt32: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension UInt64: PathRepresentable {
    public var pathValue: String { String(self) }
}

// MARK: - Floating Point Types

extension Float: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension Double: PathRepresentable {
    public var pathValue: String { String(self) }
}

extension Decimal: PathRepresentable {
    public var pathValue: String { String(describing: self) }
}

// MARK: - Boolean Type

extension Bool: PathRepresentable {
    public var pathValue: String { String(self) }
}

// MARK: - Foundation Types

extension UUID: PathRepresentable {
    public var pathValue: String { self.uuidString }
}

extension Date: PathRepresentable {
    public var pathValue: String { String(self.timeIntervalSince1970) }
}

extension URL: PathRepresentable {
    public var pathValue: String { self.absoluteString }
}

extension NSNumber: PathRepresentable {
    public var pathValue: String { self.stringValue }
}
