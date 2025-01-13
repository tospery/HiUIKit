//
//  Bundle+Core.swift
//  HiCore
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import HiBase

public extension Bundle {
    
    convenience init?(module: String) {
        self.init(identifier: "org.cocoapods." + module)
    }
    
    static var enBundle: Bundle? {
        guard let path = Bundle.main.path(forResource: Localization.english.rawValue, ofType: "lproj") else { return nil }
        return .init(path: path)
    }
    
    static var zhBundle: Bundle? {
        guard let path = Bundle.main.path(forResource: Localization.chinese.rawValue, ofType: "lproj") else { return nil }
        return .init(path: path)
    }
    
}
