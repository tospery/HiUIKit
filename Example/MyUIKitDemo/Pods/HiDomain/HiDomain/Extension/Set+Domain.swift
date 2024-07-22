//
//  Set+Domain.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation
import ObjectMapper

public extension Set where Element: BaseMappable {
    
    func toJSON(shouldIncludeNilValues: Bool) -> [[String: Any]] {
        return Mapper(shouldIncludeNilValues: shouldIncludeNilValues).toJSONSet(self)
    }
    
    /// Returns the JSON Data for the object
    func toJSONData() -> Data? {
        toJSONString(prettyPrint: false)?.data(using: .utf8)
    }
    
}
