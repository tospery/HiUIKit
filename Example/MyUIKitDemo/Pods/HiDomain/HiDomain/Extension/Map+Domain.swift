//
//  Map+Domain.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation
import ObjectMapper

public extension Map {
    
    /// It asserts that value is presents in JSON. Optional values must be included as <null>.
    func assureValuePresent(forKey key: String) -> Bool {
        if JSON[key] == nil {
            assertionFailure("Mandatory field for key `\(key)` is missing from JSON: \(JSON)")
            return false
        }
        return true
    }
    
}

