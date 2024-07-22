//
//  DataType.swift
//  HiCore
//
//  Created by 杨建祥 on 2024/5/20.
//

import UIKit
import DeviceKit

public enum HiPagingStyle: Int, Codable {
    case basic
    case navigationBar
    case pageViewController
}

public protocol BooleanType {
    var boolValue: Bool { get }
}

extension Bool: BooleanType {
    public var boolValue: Bool { return self }
}

public enum HiRequestMode: Int {
    case load, refresh, loadMore, update, reload
}

public protocol ImageSource {
}
extension URL: ImageSource {}
extension UIImage: ImageSource {}

public protocol Textable {
    func toString(_ value: Any?) -> String?
}
extension Textable {
    func toString(_ value: Any?) -> String? { nil }
}

@objc public protocol NSSwiftyLoadProtocol: AnyObject {
    @objc static func swiftyLoad()
}

public protocol StringRawRepresentable {
    var stringRawValue: String { get }
}

extension StringRawRepresentable where Self: RawRepresentable, Self.RawValue == String {
    var stringRawValue: String { return self.rawValue }
}

extension StringRawRepresentable where Self: RawRepresentable, Self.RawValue == Int {
    var stringRawValue: String { return self.rawValue.string }
}
