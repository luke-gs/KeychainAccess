//
//  RangeParserDefinition.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

open class RangeParserDefinition: QueryParserDefinition {

    public typealias InvalidLengthErrorClosure = (String, CountableClosedRange<Int>) -> LocalizedError

    public var tokenDefinitions: [QueryTokenDefinition]
    public let definitionKey: String
    public let allowedCharacterSet: CharacterSet

    private let whitespacesAndNewlinesCharacterSet = CharacterSet.whitespacesAndNewlines
    
    // Only used in the creation of the token definition + Validation so should be private
    private var range: CountableClosedRange<Int>
    private var errorClosure: InvalidLengthErrorClosure

    public init(range: CountableClosedRange<Int>, definitionKey: String, allowedCharacterSet: CharacterSet, errorClosure: @escaping InvalidLengthErrorClosure) {
        self.range = range
        self.errorClosure = errorClosure
        self.tokenDefinitions = []
        self.allowedCharacterSet = allowedCharacterSet
        self.definitionKey = definitionKey
        
        let definition = QueryTokenDefinition(key: definitionKey, required: true, typeCheck: { [allowedCharacterSet] token -> Bool in
            let extra = token.trimmingCharacters(in: allowedCharacterSet)
            return extra.count == 0
            }, validate: validationClosure)
        
        tokenDefinitions.append(definition)

    }
    
    /// Validation closure that is used with the default token definition to allow subclassing.
    open func validationClosure(_ token: String, _ index: Int,  _ map: [String:String]) throws {
        let length = token.count
        if range.contains(length) == false {
            throw errorClosure(token, range)
        }
    }

    /// Returns an array with one token with whitespaces and newlines trimmed.
    open func tokensFrom(query: String) -> [String] {
        return [query.trimmingCharacters(in: whitespacesAndNewlinesCharacterSet)]
    }
    
}
