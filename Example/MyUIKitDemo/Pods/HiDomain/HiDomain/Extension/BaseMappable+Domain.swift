//
//  BaseMappable+Core.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation
import ObjectMapper

public extension BaseMappable {
    func toJSON(shouldIncludeNilValues: Bool) -> [String: Any] {
        return Mapper(shouldIncludeNilValues: shouldIncludeNilValues).toJSON(self)
    }
    
    /// Returns the JSON Data for the object
    func toJSONData() -> Data? {
        toJSONString(prettyPrint: false)?.data(using: .utf8)
    }
    
    /// Returns the JSON String for the object
    func toJSONString(options: JSONSerialization.WritingOptions) -> String? {
        let dictionary = Mapper<Self>().toJSON(self)
        return Mapper<Self>.toJSONData(dictionary, options: options)?.utf8String
    }
    
}
