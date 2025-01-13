//
//  NSPredicate+Base.swift
//  HiBase
//
//  Created by 杨建祥 on 2024/5/30.
//

import Foundation

public extension NSPredicate {
    
    func primaryKey(_ name: String = "id") -> String? {
        let format = self.predicateFormat
        var regex = try? NSRegularExpression(pattern: "^\(name) == \".*\"$")
        if regex == nil {
            return nil
        }
        let range = NSRange(format.startIndex..<format.endIndex, in: format)
        var match = regex?.firstMatch(in: format, options: [], range: range)
        if match == nil {
            return nil
        }
        regex = try? NSRegularExpression(pattern: "\"([^\"]*)\"", options: [])
        if regex == nil {
            return nil
        }
        match = regex?.firstMatch(in: format, options: [], range: range)
        if match == nil {
            return nil
        }
        guard let resultRange = Range(match!.range(at: 1), in: format) else { return nil }
        return String(format[resultRange])
    }

}
