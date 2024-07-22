//
//  TypeCastTransform.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/13.
//

import ObjectMapper

/// Transforms value of type Any to generic type. Tries to typecast if possible.
public class TypeCastTransform<T>: TransformType {
    public typealias Object = T
    public typealias JSON = T
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        tryType(value: value, type: T.self)
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value
    }
}
