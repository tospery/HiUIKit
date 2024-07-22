//
//  EnumTypeCastTransform.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/13.
//

import ObjectMapper

/// Transforms value of type Any to RawRepresentable enum. Tries to typecast if possible.
public class EnumTypeCastTransform<T: RawRepresentable>: TransformType {
    public typealias Object = T
    public typealias JSON = T.RawValue
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> T? {
        tryEnum(value: value, type: T.self)
    }
    
    open func transformToJSON(_ value: T?) -> T.RawValue? {
        if let obj = value {
            return obj.rawValue
        }
        return nil
    }
}
