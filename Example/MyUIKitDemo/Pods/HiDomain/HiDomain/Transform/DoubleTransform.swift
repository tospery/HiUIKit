//
//  DoubleTransform.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/13.
//

import Foundation
import ObjectMapper
import SwifterSwift

/// Transforms value of type Any to Double. Tries to typecast if possible.
public class DoubleTransform: TransformType {
    public typealias Object = Double
    public typealias JSON = Double
    
    private init() {}
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        tryDouble(value)
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value
    }
}

// ******************************* MARK: - Singleton

public extension DoubleTransform {
    static let shared = DoubleTransform()
}
