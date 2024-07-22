//
//  String+Domain.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation

// ******************************* MARK: - Checks
private let kSpaceCharacter = Character(" ")
private let kNewLineCharacter = Character("\n")

public extension String {
    
    var isNil: Bool { isEmpty || self == "-" }
    
    var isNotEmpty: Bool { !isEmpty }
    
    var safeDouble: Double? {
        if self.isNil {
            return nil
        }
        return Double(self)
    }
    
    var safeInt: Int? {
        if self.isNil {
            return nil
        }
        if let int = self.int {
            return int
        } else if let double = self.safeDouble {
            return double.safeInt
        }
        return nil
    }
    
    var safeBool: Bool? {
        if self.isNil {
            return nil
        }
        return self.bool
    }
    
    var firstNonWhitespaceCharacter: Character? {
        guard let index = firstIndex(where: { $0 != kSpaceCharacter && $0 != kNewLineCharacter }) else { return nil }
        return self[index]
    }
    
    var secondNonWhitespaceCharacter: Character? {
        guard let firstIndex = firstIndex(where: { $0 != kSpaceCharacter && $0 != kNewLineCharacter }) else { return nil }
                
        let secondIndex = index(after: firstIndex)
        guard secondIndex < endIndex else { return nil }
        
        return self[secondIndex]
    }
    
    var lastNonWhitespaceCharacter: Character? {
        guard let index = lastIndex(where: { $0 != kSpaceCharacter && $0 != kNewLineCharacter }) else { return nil }
        return self[index]
    }
    
    var beforeLastNonWhitespaceCharacter: Character? {
        guard let lastIndex = lastIndex(where: { $0 != kSpaceCharacter && $0 != kNewLineCharacter }) else { return nil }
        
        let beforeLastIndex = index(before: lastIndex)
        guard startIndex <= beforeLastIndex else { return nil }
        
        return self[beforeLastIndex]
    }
    
    /// Returns fileName without extension
    var fileName: String {
        guard let lastPathComponent = components(separatedBy: "/").last else { return "" }
        
        var components = lastPathComponent.components(separatedBy: ".")
        if components.count == 1 {
            return lastPathComponent
        } else {
            components.removeLast()
            return components.joined(separator: ".")
        }
    }
    
}
