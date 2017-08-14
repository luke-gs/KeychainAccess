//
//  QueryParserDefinitionSelector.swift
//  Pods
//
//  Created by KGWH78 on 11/8/17.
//
//

import Foundation

/// QueryParserDefinitionSelector is a registry of definitions and validations.
final public class QueryParserDefinitionSelector {
    
    public typealias ValidationClosure = (_ query: String) -> Bool
    
    /// Definitions and its validation rules
    private var definitions = [(QueryParserDefinition, ValidationClosure)]()
    
    public init() {}
    
    /// Register a definition with a validation
    ///
    /// - Parameters:
    ///   - definition: The definition of interest.
    ///   - validation: The validation befitting such definition.
    public func register(definition: QueryParserDefinition, withValidation validation: @escaping ValidationClosure) {
        definitions.append((definition, validation))
    }
    
    /// Find a list of definitions that support the query.
    ///
    /// - Parameters:
    ///   - query: The text query.
    /// - Returns: A list of definitions.
    public func supportedDefinitions(for query: String) -> [QueryParserDefinition] {
        return definitions.filter({ return $0.1(query) == true }).flatMap({ $0.0 })
    }
    
}
