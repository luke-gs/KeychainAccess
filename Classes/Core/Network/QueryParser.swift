//
//  QueryParser.swift
//  MPOLKit
//
//  Created by Megan Efron on 18/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// `QueryTokenDefinition` is an object that defines the type and validation for a search
/// token, when parsing a string.
open class QueryTokenDefinition {
    
    public typealias TypeCheckClosure = (_ string: String) -> Bool
    public typealias ValidationClosure = (_ string: String, _ index: Int,  _ map: [String:String]) throws -> Void
    
    /// The name of the token (result will be mapped to this name).
    open var key: String
    
    /// Defines if the token is required in the results (will throw a parsing error if no match is found for definition).
    open var required: Bool
    
    /// Checks the string for the token type, and returns true if it matches.
    open var typeCheck: TypeCheckClosure
    
    /// Checks the string is valid based on specific conditions, and throws errors for
    /// an invalid token (e.g. string length).
    open var validate: ValidationClosure?
    
    public init(key: String, required: Bool, typeCheck: @escaping TypeCheckClosure, validate: ValidationClosure? = nil) {
        self.key = key
        self.required = required
        self.typeCheck = typeCheck
        self.validate = validate
    }
}


/// `QueryParserDefinition` is an object that defines the type and validation for a search
/// token, when parsing a string.
public protocol QueryParserDefinition {
    
    /// Method responsible for breaking up the query string into components based on specific delimiter requirements.
    func tokensFrom(query: String) -> [String]
    
    /// An array of objects that define each token's type and validation.
    var tokenDefinitions: [QueryTokenDefinition] { get }
}

/// Potential errors that can occur during query string parsing.
///
/// - multipleTokenDefinitions: An error that occurs from bad coding, two definitions are using the same key.
/// - additionalTokenFound:     There are more tokens found than definitions to match them to.
/// - invalidToken:             A token is found to be a correct type but invalid for that type.
/// - typeNotFound:             A token didn't match any type in the definitions array.
/// - requiredValueNotFound:    After parsing, a key that is declared required does not contain a value.
public enum QueryParserError: LocalizedError {
    case multipleTokenDefinitions(key: String)
    case additionalTokenFound(token: String)
    case invalidToken(token: String, key: String)
    case typeNotFound(token: String)
    case requiredValueNotFound(key: String)
    
    public var errorDescription: String? {
        var message: String
        switch self {
        case QueryParserError.requiredValueNotFound(let key):
            message = "Couldn't find value for required \(key). Refer to search help."
        case QueryParserError.additionalTokenFound(let token):
            message = "Additional token '\(token)' has been found, does not conform to query parser. Refer to search help."
        case QueryParserError.multipleTokenDefinitions(let key):
            message = "Key '\(key)' has multiple multiple token definitions."
            fatalError()
        case QueryParserError.typeNotFound(let token):
            message = "Unidentified value '\(token)' found. Refer to search help."
        case QueryParserError.invalidToken(let token, let key):
            message = "Token '\(token)' is invalid for value '\(key)'."
        }
        return message
    }
}


/// Handles parsing a search string based on a parser definition class which will
/// define how to break up the strings and what tokens to look for.
open class QueryParser {
    
    /// Parser definition object that defines how to parse the string (conforms to 'QueryParserDefinition').
    public let parser: QueryParserDefinition
    
    public init(parserDefinition: QueryParserDefinition) {
        self.parser = parserDefinition
    }
    
    /// Function takes a query string and parses it based on definitions found in 'parser'
    /// and returns a resulting map.
    ///
    /// - Parameter query:  The search string to parse.
    /// - Returns:          The results of the parsing as a map.
    open func parseString(query: String) throws -> [String:String] {
        
        // Split up query string using parser's delimiter
        let tokens = parser.tokensFrom(query: query)
        
        var results = [String: String]()
        var definitions = parser.tokenDefinitions
        
        // Logic after match is found
        func mapStringToKey(string: String, key: String, index: Int) {
            results[key] = string
            definitions.remove(at: index)
        }
        
        // Logic to guarantee token is a match for a type in definitions array
        func tokenMatchesAnyDefinition(_ token: String, atIndex index: Int) -> Bool {
            for definition in definitions {
                if definition.typeCheck(token) {
                    guard let validate = definition.validate else { return true }
                    do {
                        try validate(token, index, results); return true
                    } catch {
                        continue
                    }
                }
            }
            return false
        }
        
        // Iteration for parsing strings
        for (index, token) in tokens.enumerated() {
            guard definitions.count > 0 else { throw QueryParserError.additionalTokenFound(token: token) }
            
            var found = false
            for (definitionIndex, definition) in definitions.enumerated() {
                let key = definition.key
                guard results[key] == nil else { throw QueryParserError.multipleTokenDefinitions(key: key) }
                
                if definition.typeCheck(token) {
                    if let validate = definition.validate {
                        do {
                            try validate(token, index, results)
                            mapStringToKey(string: token, key: key, index: definitionIndex)
                            found = true
                            break
                        } catch (let error) {
                            if (tokenMatchesAnyDefinition(token, atIndex: index)) {
                                continue
                            } else {
                                throw error
                            }
                        }
                    } else {
                        mapStringToKey(string: token, key: key, index: definitionIndex)
                        found = true
                        break
                    }
                }
            }
            
            guard found else { throw QueryParserError.typeNotFound(token: token) }
        }
        
        // Check all required tokens have been found
        let requiredKeys: [String] = parser.tokenDefinitions.flatMap { $0.required ? $0.key : nil }
        for key in requiredKeys {
            guard let _ = results[key] else { throw QueryParserError.requiredValueNotFound(key: key) }
        }
        
        return results
    }
}
