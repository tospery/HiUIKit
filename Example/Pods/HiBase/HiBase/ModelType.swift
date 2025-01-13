//
//  ModelType.swift
//  HiBase
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import ObjectMapper
import SwifterSwift

/// 数据模型的协议
/// 判断一个模型跟另一个模型是否一样的方法有三种：
/// 1. 遵循Identifiable，通过id值来判断
/// 2. 遵循Hashable，通过hashValue来判断
/// 3. 遵循Equatable，通过==操作符来判断
public protocol ModelType: Mappable, Identifiable, Hashable, Codable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    var isValid: Bool { get }
    init()
}

public extension ModelType {

    var isValid: Bool {
        let string = tryString(self.id) ?? ""
        if !string.isEmpty {
            return true
        }
        let int = tryInt(self.id) ?? 0
        if int != 0 {
            return true
        }
        return false
    }
    
    var description: String { self.toJSONString() ?? tryString(self.id) ?? "" }
    
    var debugDescription: String { self.toJSONString() ?? tryString(self.id) ?? "" }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tryString(self.id) ?? "")
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }

    public func isEqual(to other: any ModelType) -> Bool {
        guard let otherModel = other as? Self else {
            return false
        }
        return self == otherModel
    }
}

public protocol UserType: ModelType {
    var username: String? { get }
    var nickname: String? { get }
    var avatar: String? { get }
}

public protocol ProfileType: ModelType {
    var isDark: Bool? { get set }
    var accentColor: String { get }
    var localization: Localization? { get set }
    var loginedUser: (any UserType)? { get set }
}

public struct AnyModel: Identifiable, Equatable, Hashable {
    
    public let base: any ModelType

    public var id: String { tryString(base.id) ?? "" }
    
    public init<Model: ModelType>(_ base: Model) {
        self.base = base
    }
    
    public func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }

    public static func == (lhs: AnyModel, rhs: AnyModel) -> Bool {
        guard type(of: lhs.base) == type(of: rhs.base) else {
            return false
        }
        return lhs.base.isEqual(to: rhs.base)
    }
}

public struct WrappedModel: ModelType {
    
    public var data: Any
    
    public var id: String { self.description }
    
    public var isValid: Bool { true }
    
    public init() {
        self.data = 0
    }
    
    public init(_ data: Any) {
        self.data = data
    }
    
    public init?(map: Map) {
        self.data = 0
    }
    
    public mutating func mapping(map: Map) {
        data    <- map["data"]
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description == rhs.description
    }
    
    public var description: String {
        tryString(self.data) ?? ""
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
        case data
    }
    
    public func encode(to encoder: Encoder) throws { throw MappingError.unknownType }

     public init(from decoder: Decoder) throws { throw MappingError.unknownType }
    
}

public struct ModelContext: MapContext {
    
    public let shouldMap: Bool
    
    public init(shouldMap: Bool = true){
        self.shouldMap = shouldMap
    }

}


