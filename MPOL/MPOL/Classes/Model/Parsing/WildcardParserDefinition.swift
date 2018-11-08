//
//  WildcardParserDefinition.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public enum WildcardParserError: LocalizedError {
    case incorrectFormat(query: String)

    public var errorDescription: String? {
        switch self {
        case .incorrectFormat(let query):
            return "Unidentified value '\(query)' found. Refer to search help."
        }
    }
}

/// Parser for wildcard searches,
/// allowed character set in initializer is unioned with
/// wildcard characters
open class WildcardParserDefinition: RangeParserDefinition {

    static public let wildcardCharacterSet: CharacterSet = CharacterSet(["*", "?"])

    public override init(range: CountableClosedRange<Int>, definitionKey: String, allowedCharacterSet: CharacterSet = .alphanumerics, errorClosure: @escaping InvalidLengthErrorClosure) {
        super.init(range: range, definitionKey: definitionKey, allowedCharacterSet: allowedCharacterSet.union(WildcardParserDefinition.wildcardCharacterSet), errorClosure: errorClosure)
    }

    /// Along with a range restrictions, restrict any search that contains more that one wildcard *
    override open func validationClosure(_ token: String, _ index: Int, _ map: [String: String]) throws {
        try super.validationClosure(token, index, map)
        if token.filter({ String($0) == "*" }).count > 1 {
            throw WildcardParserError.incorrectFormat(query: token)
        }
    }
}
