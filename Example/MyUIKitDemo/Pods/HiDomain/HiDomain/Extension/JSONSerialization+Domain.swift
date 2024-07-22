//
//  JSONSerialization+Domain.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation
import ObjectMapper

public extension JSONSerialization.WritingOptions {
    
    /// `[.sortedKeys]` on `iOS <13.0` and `[.sortedKeys, .withoutEscapingSlashes]` on `iOS >=13.0`
    static let sortedKeysWithoutEscapingSlashesIfPossible: JSONSerialization.WritingOptions = {
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
            return [.sortedKeys, .withoutEscapingSlashes]
        } else {
            return [.sortedKeys]
        }
    }()
    
}
