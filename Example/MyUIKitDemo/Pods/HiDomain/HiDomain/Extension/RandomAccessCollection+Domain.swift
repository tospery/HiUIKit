//
//  RandomAccessCollection+Domain.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation
import ObjectMapper

// ******************************* MARK: - [[BaseMappable]]
public extension RandomAccessCollection where Element: RandomAccessCollection, Element.Element: BaseMappable {
    
    /// Creates models array from JSON string.
    /// - parameter jsonString: String in JSON format to use for model creation.
    /// - throws: `MappingError.emptyData` if response data is empty.
    /// - throws: `MappingError.invalidJSON` if response isn't a valid JSON.
    /// - throws: `MappingError.unknownType` if it wasn't possible to create model.
    static func create(jsonData: Data?) throws -> [[Element.Element]] {
        guard let jsonData = jsonData else {
            throw MappingError.emptyData
        }
        
        guard !jsonData.isEmpty else {
            throw MappingError.emptyData
        }
        
        // Start check
        guard  jsonData.firstNonWhitespaceByte == ASCIICodes.openSquareBracket else {
            throw MappingError.invalidJSON(message: "JSON array of arrays should start with the '[' character")
        }
        
        guard jsonData.secondNonWhitespaceByte == ASCIICodes.openSquareBracket else {
            throw MappingError.invalidJSON(message: "JSON array should start with the '[' character")
        }
        
        // End check
        guard jsonData.lastNonWhitespaceByte == ASCIICodes.closeSquareBracket else {
            throw MappingError.invalidJSON(message: "JSON array of arrays should end with the ']' character")
        }
        
        guard jsonData.beforeLastNonWhitespaceByte == ASCIICodes.closeSquareBracket else {
            throw MappingError.invalidJSON(message: "JSON array should end with the ']' character")
        }
        
        guard let json = jsonData.safeSerializeToJSON() else {
            throw MappingError.invalidJSON(message: "Unable to serialize JSON array from the data")
        }
        
        guard let arrayOfArraysOfDictionaries = json as? [[[String: Any]]] else {
            throw MappingError.unknownType
        }
        
        guard let arrayOfArraysOfObjects = Mapper<Element.Element>().mapArrayOfArrays(JSONObject: arrayOfArraysOfDictionaries) else {
            throw MappingError.unknownType
        }
        
        return arrayOfArraysOfObjects
    }
    
    /// Create models array from JSON string. Report error and return nil if unable.
    /// - parameter jsonString: String in JSON format to use for model creation.
    static func safeCreate(jsonData: Data?) -> [[Element.Element]]? {
        do {
            return try create(jsonData: jsonData)
        } catch {
            print("Unable to create array of objects from JSON string: \nerror = \(error)\ndata = \(["jsonData": jsonData ?? .init(), "self": self])")
            return nil
        }
    }
    
    /// Creates models array from JSON string.
    /// - parameter jsonString: String in JSON format to use for model creation.
    /// - throws: `MappingError.emptyData` if response data is empty.
    /// - throws: `MappingError.invalidJSON` if response isn't a valid JSON.
    /// - throws: `MappingError.unknownType` if it wasn't possible to create model.
    static func create(jsonString: String?) throws -> [[Element.Element]] {
        guard let jsonString = jsonString else {
            throw MappingError.emptyData
        }
        
        guard !jsonString.isEmpty else {
            throw MappingError.emptyData
        }
        
        // Start check
        guard jsonString.firstNonWhitespaceCharacter == "[" else {
            throw MappingError.invalidJSON(message: "JSON array should start with the '[' character")
        }
        
        guard jsonString.secondNonWhitespaceCharacter == "[" else {
            throw MappingError.invalidJSON(message: "JSON array should start with the '[' character")
        }
        
        // End check
        guard jsonString.lastNonWhitespaceCharacter == "]" else {
            throw MappingError.invalidJSON(message: "JSON array of arrays should end with the ']' character")
        }
        
        guard jsonString.beforeLastNonWhitespaceCharacter == "]" else {
            throw MappingError.invalidJSON(message: "JSON array should end with the ']' character")
        }
        
        guard let arrayOfArraysOfDictionaries = Mapper<Element.Element>.parseJSONString(JSONString: jsonString) as? [[[String: Any]]] else {
            throw MappingError.unknownType
        }
        
        guard let arrayOfArraysOfObjects = Mapper<Element.Element>().mapArrayOfArrays(JSONObject: arrayOfArraysOfDictionaries) else {
            throw MappingError.unknownType
        }
        
        return arrayOfArraysOfObjects
    }
    
    /// Create models array from JSON string. Report error and return nil if unable.
    /// - parameter jsonString: String in JSON format to use for model creation.
    static func safeCreate(jsonString: String?) -> [[Element.Element]]? {
        do {
            return try create(jsonString: jsonString)
        } catch {
            print("Unable to create array of objects from JSON string: \nerror = \(error)\ndata = \(["jsonString": jsonString ?? .init(), "self": self])")
            return nil
        }
    }
}
