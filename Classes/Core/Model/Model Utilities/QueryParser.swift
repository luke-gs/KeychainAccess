//
//  QueryParser.swift
//  Pods
//
//  Created by Megan Efron on 18/6/17.
//
//

import UIKit


/// `SearchTokenDefinition` is an object that defines the type and validation for a search
/// token, when parsing a string.
public class QueryTokenDefinition {
    
    public typealias TypeCheckClosure = (_ string: String) -> Bool
    public typealias ValidationClosure = (_ string: String, _ index: Int,  _ map: [String:String]) -> Bool
    
    /// The name of the token (result will be mapped to this name).
    var key: String
    
    /// Defines if the token is required in the map (will throw a parsing error if no match is found for definition).
    var required: Bool
    
    /// Checks the string for the token type, and returns true if it matches.
    var typeCheck: TypeCheckClosure
    
    /// Checks the string is valid based on provided conditions (e.g. string length).
    var validate: ValidationClosure?
    
    init(key: String, required: Bool, typeCheck: @escaping TypeCheckClosure, validate: ValidationClosure? = nil) {
        self.key = key
        self.required = required
        self.typeCheck = typeCheck
        self.validate = validate
    }
}


/// `QueryParserProtocol` is an object that defines the type and validation for a search
/// token, when parsing a string.
public protocol QueryParserType {
    
    /// The conforming class/struct must provide an init, even if empty, to allow the
    /// 'QueryParser' class to create an instance of it.
    init()
    
    /// The character to split up the query string by (e.g. ",").
    var delimiter: String { get }
    
    /// An array of objects that define each token's type and validation.
    var definitions: [QueryTokenDefinition] { get }
}


/// Potential errors that can occur during query string parsing.
///
/// - multipleTokenDefinitions: An error that occurs from bad coding, two definitions are using the same key.
/// - additionalTokenFound:     There are more tokens found than definitions to match them to.
/// - invalidToken:             A token is found to be a correct type but invalid for that type.
/// - typeNotFound:             A token didn't match any type in the definitions array.
/// - requiredValueNotFound:    After parsing, a key that is declared required does not contain a value.
public enum QueryParserError: Error {
    case multipleTokenDefinitions(key: String)
    case additionalTokenFound(token: String)
    case invalidToken(token: String, key: String)
    case typeNotFound(token: String)
    case requiredValueNotFound(key: String)
}


/// Handles parsing a search string based on a concrete parser class which provides
/// definitions on how to break up the strings and what tokens to look for.
open class QueryParser<ParserType: QueryParserType> {
    
    /// Parser object that defines how to parse the string (conforms to 'QueryParserType').
    let parser: ParserType
    
    public init() {
        self.parser = ParserType()
    }
    
    /// Function takes a query string and parses it based on definitions found in 'parser'
    /// and returns a resulting map.
    ///
    /// - Parameter query:  The search string to parse.
    /// - Returns:          The results of the parsing as a map.
    public func parseString(query: String) throws -> [String:String] {
        
        // Split up query string using parser's delimiter
        let tokens = query.components(separatedBy: parser.delimiter)
        
        var map = [String: String]()
        var definitions = parser.definitions
        
        // Logic after match is found
        func mapStringToKey(string: String, key: String, index: Int) {
            print("\"\(string)\" mapped to \"\(key)\"")
            map[key] = string
            definitions.remove(at: index)
        }
        
        // Logic to garantee token is a match for a type in definnitions array
        func tokenMatchesAnyDefinition(_ token: String, atIndex index: Int) -> Bool {
            for definition in definitions {
                if definition.typeCheck(token) {
                    guard let validate = definition.validate else   { return true } // if validate closure is nil, token matches type
                    if validate(token, index, map)                  { return true } // if validate returns true, token matches type
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
                guard map[key] == nil else { throw QueryParserError.multipleTokenDefinitions(key: key) }
                
                if definition.typeCheck(token) {
                    if let validate = definition.validate {
                        if validate(token, index, map) {
                            mapStringToKey(string: token, key: key, index: definitionIndex)
                            found = true
                            break
                        } else if tokenMatchesAnyDefinition(token, atIndex: index) {
                            print("\"\(token)\" found invalid for \"\(key)\" but will match for a later definition")
                            continue
                        } else {
                            throw QueryParserError.invalidToken(token: token, key: key)
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
        let requiredKeys: [String] = parser.definitions.flatMap { $0.required ? $0.key : nil }
        for key in requiredKeys {
            guard let _ = map[key] else { throw QueryParserError.requiredValueNotFound(key: key) }
        }
        
        return map
    }
}
