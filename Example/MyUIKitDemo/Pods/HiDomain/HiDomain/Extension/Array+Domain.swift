//
//  Array+Domain.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation
import ObjectMapper

public extension Array where Element: BaseMappable {
    
    func toJSON(shouldIncludeNilValues: Bool) -> [[String: Any]] {
        return Mapper(shouldIncludeNilValues: shouldIncludeNilValues).toJSONArray(self)
    }
    
    /// Returns the JSON Data for the object
    func toJSONData() -> Data? {
        toJSONString(prettyPrint: false)?.data(using: .utf8)
    }
    
    /// Returns the JSON String for the object
    func toJSONString(options: JSONSerialization.WritingOptions) -> String? {
        let dictionary = Mapper<Element>().toJSONArray(self)
        return Mapper<Element>.toJSONData(dictionary, options: options)?.utf8String
    }

    /// Creates models array from JSON string.
    /// - parameter jsonData: Data in JSON format to use for model creation.
    /// - throws: `MappingError.emptyData` if response data is empty.
    /// - throws: `MappingError.invalidJSON` if response isn't a valid JSON.
    /// - throws: `MappingError.unknownType` if it wasn't possible to create model.
    static func create(jsonData: Data?) throws -> Array {
        guard let jsonData = jsonData, !jsonData.isEmpty else {
            throw MappingError.emptyData
        }
        
        // Start check
        guard jsonData.firstNonWhitespaceByte == ASCIICodes.openSquareBracket else {
            throw MappingError.invalidJSON(message: "JSON array should start with the '[' character")
        }
        
        // End check
        guard jsonData.lastNonWhitespaceByte == ASCIICodes.closeSquareBracket else {
            throw MappingError.invalidJSON(message: "JSON array should end with the ']' character")
        }
        
        guard let jsonObject = jsonData.safeSerializeToJSON() else {
            throw MappingError.invalidJSON(message: "Unable to serialize JSON array from the data")
        }
        
        guard let jsonArrayOfDictionaries = jsonObject as? [[String: Any]] else {
            throw MappingError.unknownType
        }
        
        let array = Mapper<Element>().mapArray(JSONArray: jsonArrayOfDictionaries)
        
        return array
    }
    
    /// Create models array from JSON string. Report error and return nil if unable.
    /// - parameter jsonData: Data in JSON format to use for model creation.
    static func safeCreate(jsonData: Data?) -> Array? {
        do {
            return try create(jsonData: jsonData)
        } catch {
            print("Unable to create array of objects from JSON data: \nerror = \(error)\ndata: \(["jsonData": jsonData?.asString])")
            return nil
        }
    }
    
    /// Creates models array from JSON string.
    /// - parameter jsonString: String in JSON format to use for model creation.
    /// - throws: `MappingError.emptyData` if response data is empty.
    /// - throws: `MappingError.invalidJSON` if response isn't a valid JSON.
    /// - throws: `MappingError.unknownType` if it wasn't possible to create model.
    static func create(jsonString: String?) throws -> Array {
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
        
        // End check
        guard jsonString.lastNonWhitespaceCharacter == "]" else {
            throw MappingError.invalidJSON(message: "JSON array should end with the ']' character")
        }
        
        guard let array = Mapper<Element>().mapArray(JSONString: jsonString) else {
            throw MappingError.unknownType
        }
        
        return array
    }
    
    /// Create models array from JSON string. Report error and return nil if unable.
    /// - parameter jsonString: String in JSON format to use for model creation.
    static func safeCreate(jsonString: String?) -> Array? {
        do {
            return try create(jsonString: jsonString)
        } catch {
            print("Unable to create array of objects from JSON string: \nerror = \(error)\ndata = \(["jsonString": jsonString ?? .init(), "self": self])")
            return nil
        }
    }
    
}

// ******************************* MARK: - [BaseMappable?] with data
public extension Array where Element: OptionalType, Element.Wrapped: BaseMappable {
    
    /// Creates models array from JSON string.
    /// - parameter jsonData: Data in JSON format to use for model creation.
    /// - throws: `MappingError.emptyData` if response data is empty.
    /// - throws: `MappingError.invalidJSON` if response isn't a valid JSON.
    /// - throws: `MappingError.unknownType` if it wasn't possible to create model.
    static func create(jsonData: Data?) throws -> [Element] {
        guard let jsonData = jsonData, !jsonData.isEmpty else {
            throw MappingError.emptyData
        }
        
        // Start check
        guard jsonData.firstNonWhitespaceByte == ASCIICodes.openSquareBracket else {
            throw MappingError.invalidJSON(message: "JSON array should start with the '[' character")
        }
        
        // End check
        guard jsonData.lastNonWhitespaceByte == ASCIICodes.closeSquareBracket else {
            throw MappingError.invalidJSON(message: "JSON array should end with the ']' character")
        }
        
        guard let jsonObject = jsonData.safeSerializeToJSON() else {
            throw MappingError.invalidJSON(message: "Unable to serialize JSON array from the data")
        }
        
        guard let jsonArrayOfObjects = jsonObject as? [Any] else {
            throw MappingError.unknownType
        }
        
        return try jsonArrayOfObjects.map { object in
            if object is NSNull {
                return Element(nilLiteral: ())
                
            } else {
                if let _jsonObject = object as? [String: Any],
                   let jsonObject = Mapper<Element.Wrapped>().map(JSON: _jsonObject) as? Element {
                    
                    return jsonObject
                    
                } else {
                    throw MappingError.unknownType
                }
            }
        }
    }
    
    /// Create models array from JSON string. Report error and return nil if unable.
    /// - parameter jsonData: Data in JSON format to use for model creation.
    static func safeCreate(jsonData: Data?) -> Array? {
        do {
            return try create(jsonData: jsonData)
        } catch {
            print("Unable to create array of optional objects from JSON data: \nerror = \(error)\ndata = \(["jsonData": jsonData?.asString])")
            return nil
        }
    }
    
}
