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

    public let tokenDefinitions: [QueryTokenDefinition]
    public let definitionKey: String
    public let allowedCharacterSet: CharacterSet

    private let whitespacesAndNewlinesCharacterSet = CharacterSet.whitespacesAndNewlines

    public init(range: CountableClosedRange<Int>, definitionKey: String, allowedCharacterSet: CharacterSet, errorClosure: @escaping InvalidLengthErrorClosure) {

        let definition = QueryTokenDefinition(key: definitionKey, required: true, typeCheck: { [allowedCharacterSet] token -> Bool in
            let extra = token.trimmingCharacters(in: allowedCharacterSet)
            return extra.count == 0
        }) { (token, index, map) in
            let length = token.count
            if range.contains(length) == false {
                throw errorClosure(token, range)
            }
        }
        self.tokenDefinitions = [definition]
        self.allowedCharacterSet = allowedCharacterSet
        self.definitionKey = definitionKey

    }

    /// Returns an array with one token with whitespaces and newlines trimmed.
    open func tokensFrom(query: String) -> [String] {
        return [query.trimmingCharacters(in: whitespacesAndNewlinesCharacterSet)]
    }
    
}
