//
//  Color+Core.swift
//  Pods
//
//  Created by 杨建祥 on 2024/12/20.
//

import UIKit
import SwiftUI
import SwifterSwift

public extension UIColor {
    
    public var swiftUIColor: SwiftUI.Color {
        SwiftUI.Color(uiColor: self)
    }
    
    var argbHexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        let a = Int(alpha * 255)
        return String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }
    
//    var isDark: Bool {
//         var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
//         if getRed(&red, green: &green, blue: &blue, alpha: nil) {
//             let referenceValue: CGFloat = 0.411
//             let colorDelta = (red * 0.299) + (green * 0.587) + (blue * 0.114)
//             return 1.0 - colorDelta > referenceValue
//         }
//         return true
//     }

}

