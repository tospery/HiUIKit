//
//  StringProtocol+Domain.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation

public extension StringProtocol {
    
    /// Returns `self` as `String`
    var asString: String {
        if let string = self as? String {
            return string
        } else {
            return String(self)
        }
    }
    
    /// Returns `self` as `Bool` if conversion is possible.
    var forceBool: Bool? {
        if let bool = Bool(asString) {
            return bool
        }
        
        switch lowercased() {
        case "true", "yes", "1", "enable": return true
        case "false", "no", "0", "disable": return false
        default: return nil
        }
    }
    
}
