//
//  IntTransform.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/13.
//

import Foundation
import ObjectMapper

/// Transforms value of type Any to Int. Tries to typecast if possible.
public class IntTransform: TransformType {
    public typealias Object = Int
    public typealias JSON = Int
    
    private init() {}
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        tryInt(value)
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value
    }
}

// ******************************* MARK: - Singleton
public extension IntTransform {
    static let shared = IntTransform()
}
