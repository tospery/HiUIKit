//
//  ReactorType.swift
//  HiUIKit
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import ObjectMapper
import HiCore
import HiDomain

public protocol ReactorType {

}

public protocol WithModel {
    var model: any ModelType { get }
    init(_ model: any ModelType)
}
