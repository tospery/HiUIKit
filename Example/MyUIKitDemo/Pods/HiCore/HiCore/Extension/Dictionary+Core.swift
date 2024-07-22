//
//  Dictionary+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import SwifterSwift
import ObjectMapper
import HiDomain

public extension Dictionary where Key == String {

    func bool(for key: String) -> Bool? { tryBool(self[key]) }

    func int(for key: String) -> Int? { tryInt(self[key]) }

    func string(for key: String) -> String? { tryString(self[key]) }
    
    func `enum`<T: RawRepresentable>(for key: String, type: T.Type) -> T? {
        tryEnum(value: self[key], type: T.self)
    }
    
    func data(for key: String) -> Data? {
        guard let value = self[key] else { return nil }
        return value as? Data
    }

    func url(for key: String) -> URL? {
        guard let value = self[key] else { return nil }
        //return (value as? URL) ?? URL.init(string: (value as? String))
        if let url = value as? URL {
            return url
        }
        if let string = value as? String {
            if let url = URL.init(string: string) {
                return url
            }
            if let url = URL.init(string: string.urlEncoded) {
                return url
            }
            if let url = URL.init(string: string.urlDecoded) {
                return url
            }
        }
        return nil
    }

    func color(for key: String) -> UIColor? {
        guard let value = self[key] else { return nil }
        return (value as? UIColor) ?? UIColor.init(hexString: (value as? String) ?? "")
    }

    func array(for key: String) -> [Any]? {
        guard let value = self[key] else { return nil }
        return value as? [Any]
    }

    func model<Model: ModelType>(for key: String, type: Model.Type) -> Model? {
        guard let value = self[key] else { return nil }
        if value is Model {
            return value as? Model
        }
        guard let string = self.string(for: key) else { return nil }
        guard let base64 = string.base64Decoded else { return nil }
        return Model.init(JSONString: base64)
    }

    var toStringString: [String: String] {
        var result = [String: String].init()
        for key in self.keys {
            let value = self[key]!
            result[key] = String.init(describing: value)
        }
        return result
    }

    var sortedJSONString: String {
        let temp = self
        var keys = [String].init()
        for key in temp.keys {
            keys.append(key)
        }
        keys.sort { $0 < $1 }
        var strings = [String].init()
        for key in keys {
            if let value = temp[key] as? [String: Any] {
                strings.append("\"\(key)\":\(value.sortedJSONString)")
            } else if let value = temp[key] as? [Any] {
                strings.append("\"\(key)\":\(value.sortedJSONString)")
            } else {
                strings.append("\"\(key)\":\"\(temp[key]!)\"")
            }
        }
        var result = "{"
        result += strings.joined(separator: ",")
        result += "}"
        return result
    }

}
