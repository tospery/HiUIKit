//
//  ImmutableMappable+Domain.swift
//  HiDomain
//
//  Created by 杨建祥 on 2024/5/20.
//

import Foundation
import ObjectMapper

// ******************************* MARK: - From data
public extension ImmutableMappable {
    
    /// Creates model from JSON string.
    /// - parameter jsonData: Data in JSON format to use for model creation.
    /// - throws: `MappingError.emptyData` if response data is empty.
    /// - throws: `MappingError.invalidJSON` if response isn't a valid JSON.
    /// - throws: `MappingError.unknownType` if it wasn't possible to create model.
    static func create(jsonData: Data?) throws -> Self {
        guard let jsonData = jsonData, !jsonData.isEmpty else {
            throw MappingError.emptyData
        }
        
        // Start check
        guard jsonData.firstNonWhitespaceByte == ASCIICodes.openCurlyBracket else {
            throw MappingError.invalidJSON(message: "JSON object should start with the '{' character")
        }
        
        // End check
        guard jsonData.lastNonWhitespaceByte == ASCIICodes.closeCurlyBracket else {
            throw MappingError.invalidJSON(message: "JSON object should end with the '}' character")
        }
        
        guard let jsonObject = jsonData.safeSerializeToJSON() else {
            throw MappingError.invalidJSON(message: "Unable to serialize JSON object from the data")
        }
        
        guard let jsonDictionary = jsonObject as? [String: Any] else {
            throw MappingError.unknownType
        }
        
        let model = try Self(JSON: jsonDictionary)
        
        return model
    }
    
    /// Create model from JSON string. Report error and return nil if unable.
    /// - parameter jsonData: Data in JSON format to use for model creation.
    static func safeCreate(jsonData: Data?) -> Self? {
        do {
            return try create(jsonData: jsonData)
        } catch {
            print("Unable to create object from JSON data: \nerror = \(error)\ndata = \(["jsonData": jsonData ?? .init(), "self": self])")
            return nil
        }
    }
}

// ******************************* MARK: - From string
public extension ImmutableMappable {
    
    /// Creates model from JSON string.
    /// - parameter jsonString: String in JSON format to use for model creation.
    /// - throws: `MappingError.emptyData` if response data is empty.
    /// - throws: `MappingError.invalidJSON` if response isn't a valid JSON.
    /// - throws: Any other error that model may emmit during initialization.
    static func create(jsonString: String?) throws -> Self {
        guard let jsonString = jsonString else {
            throw MappingError.emptyData
        }
        
        guard !jsonString.isEmpty else {
            throw MappingError.emptyData
        }
        
        // Start check
        guard jsonString.firstNonWhitespaceCharacter == "{" else {
            throw MappingError.invalidJSON(message: "JSON object should start with the '{' character")
        }
        
        // End check
        guard jsonString.lastNonWhitespaceCharacter == "}" else {
            throw MappingError.invalidJSON(message: "JSON object should end with the '}' character")
        }
        
        let model = try Self(JSONString: jsonString)
        
        return model
    }
    
    /// Create model from JSON string. Report error and return nil if unable.
    /// - parameter jsonString: String in JSON format to use for model creation.
    static func safeCreate(jsonString: String?) -> Self? {
        do {
            return try create(jsonString: jsonString)
        } catch {
            print("Unable to create object from JSON string: \nerror = \(error)\ndata = \(["jsonString": jsonString ?? .init(), "self": self])")
            return nil
        }
    }
}
