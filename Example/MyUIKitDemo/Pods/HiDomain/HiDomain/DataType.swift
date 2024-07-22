//
//  DataType.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/15.
//

import Foundation

public protocol ServiceProvider { }
public protocol ProviderProtocol { }

public enum Localization: String, Codable {
    case chinese    = "zh-Hans"
    case english    = "en"
    
    public static let allValues = [chinese, english]
    
    public var preferredLanguages: [String] { [self.rawValue] }
}

public enum MappingError: Error {
    case emptyData
    case invalidJSON(message: String)
    case unknownType
}

// Take from https://github.com/RxSwiftCommunity/RxOptional/blob/master/Sources/RxOptional/OptionalType.swift
// Originally from here: https://github.com/artsy/eidolon/blob/24e36a69bbafb4ef6dbe4d98b575ceb4e1d8345f/Kiosk/Observable%2BOperators.swift#L30-L40
// Credit to Artsy and @ashfurrow
public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
    init(nilLiteral: ())
}

extension Optional: OptionalType {
    /// Cast `Optional<Wrapped>` to `Wrapped?`
    public var value: Wrapped? { self }
}
