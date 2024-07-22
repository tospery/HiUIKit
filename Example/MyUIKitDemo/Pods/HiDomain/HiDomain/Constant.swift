//
//  Constant.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation

enum ASCIICodes {
    static let openCurlyBracket: UInt8 = "{".data(using: .ascii)!.first!
    static let closeCurlyBracket: UInt8 = "}".data(using: .ascii)!.first!
    static let openSquareBracket: UInt8 = "[".data(using: .ascii)!.first!
    static let closeSquareBracket: UInt8 = "]".data(using: .ascii)!.first!
    static let space: UInt8 = " ".data(using: .ascii)!.first!
    static let newLine: UInt8 = "\n".data(using: .ascii)!.first!
}
