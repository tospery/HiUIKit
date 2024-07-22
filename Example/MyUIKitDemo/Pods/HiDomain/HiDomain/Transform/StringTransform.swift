//
//  StringTransform.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/13.
//

import Foundation
import ObjectMapper
import SwifterSwift

/// Transforms value of type Any to String. Tries to typecast if possible.
public class StringTransform: TransformType {
    public typealias Object = String
    public typealias JSON = String
    
    private init() {}
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        tryString(value)
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value
    }
}

// ******************************* MARK: - Singleton
public extension StringTransform {
    static let shared = StringTransform()
}
