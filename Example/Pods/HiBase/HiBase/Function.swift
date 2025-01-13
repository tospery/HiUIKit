//
//  Function.swift
//  HiBase
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation
import SwifterSwift

public func tryBool(_ value: Any?) -> Bool? {
    guard let value = value else { return nil }
    if let bool = value as? Bool {
        return bool
    } else if let int = value as? Int {
        return int.bool
    } else if let double = value as? Double {
        return double.bool
    } else if let string = value as? String {
        return string.safeBool
    } else if let number = value as? NSNumber {
        return number.boolValue
    }
    return nil
}

public func tryInt(_ value: Any?) -> Int? {
    guard let value = value else { return nil }
    if let int = value as? Int {
        return int
    } else if let double = value as? Double {
        return double.safeInt
    } else if let bool = value as? Bool {
        return bool.int
    } else if let string = value as? String {
        return string.safeInt
    } else if let number = value as? NSNumber {
        return number.intValue
    }
    return nil
}

public func tryDouble(_ value: Any?) -> Double? {
    guard let value = value else { return nil }
    if let double = value as? Double {
        return double
    } else if let int = value as? Int {
        return int.double
    } else if let bool = value as? Bool {
        return bool.double
    } else if let string = value as? String {
        return string.safeDouble
    } else if let number = value as? NSNumber {
        return number.doubleValue
    }
    return nil
}

public func tryString(_ value: Any?) -> String? {
    guard let value = value else { return nil }
    if let string = value as? String {
        return string
    } else if let int = value as? Int {
        return int.string
    } else if let double = value as? Double {
        return double.string
    } else if let bool = value as? Bool {
        return bool.string
    } else if let number = value as? NSNumber {
        return number.stringValue
    } else if let identifiable = value as? (any Identifiable) {
        return tryString(identifiable.id)
    } else if let hashable = value as? (any Hashable) {
        return hashable.hashValue.string
    } else if let customStringConvertible = value as? CustomStringConvertible {
        return customStringConvertible.description
    } else if let nsobject = value as? NSObject {
        return nsobject.description
    } else if let array = value as? [Any] {
        return array.map { tryString($0) ?? "" }.joined(separator: ",")
    } else if let dictionary = value as? [AnyHashable: Any] {
        return dictionary.map { key, value in
            "\(tryString(key) ?? ""): \(tryString(value) ?? "")"
        }.joined(separator: ",")
    } else if let optional = value as? Optional<Any> {
        return tryString(optional as Any)
    }
    return String.init(describing: value)
}

public func tryType<T>(value: Any?, type: T.Type) -> T? {
    guard let value = value else { return nil }
    if let value = value as? T {
        return value
    } else if T.self == Int.self {
        return tryInt(value) as? T
    } else if T.self == Double.self {
        return tryDouble(value) as? T
    } else if T.self == Bool.self {
        return tryBool(value) as? T
    } else if T.self == String.self {
        return tryString(value) as? T
    }
    return nil
}

public func tryEnum<T: RawRepresentable>(value: Any?, type: T.Type) -> T? {
    guard let value = value else { return nil }
    if let value = value as? T.RawValue {
        return T(rawValue: value)
    } else if T.RawValue.self == Int.self {
        let rawValue = tryInt(value) as? T.RawValue
        return rawValue.flatMap(T.init(rawValue:))
    } else if T.RawValue.self == Double.self {
        let rawValue = tryDouble(value) as? T.RawValue
        return rawValue.flatMap(T.init(rawValue:))
    } else if T.RawValue.self == Bool.self {
        let rawValue = tryBool(value) as? T.RawValue
        return rawValue.flatMap(T.init(rawValue:))
    } else if T.RawValue.self == String.self {
        let rawValue = tryString(value) as? T.RawValue
        return rawValue.flatMap(T.init(rawValue:))
    }
    return nil
}
