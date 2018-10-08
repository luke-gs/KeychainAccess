//
//  WildcardParserDefinition.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

/// Parser for wildcard searches,
/// allowed character set in initializer is unioned with
/// wildcard characters
open class WildcardParserDefinition: RangeParserDefinition {

    static public let wildcardCharacterSet: CharacterSet = CharacterSet(["*", "?"])

    public override init(range: CountableClosedRange<Int>, definitionKey: String, allowedCharacterSet: CharacterSet = .alphanumerics, errorClosure: @escaping InvalidLengthErrorClosure) {
        super.init(range: range, definitionKey: definitionKey, allowedCharacterSet: allowedCharacterSet.union(WildcardParserDefinition.wildcardCharacterSet), errorClosure: errorClosure)
    }
}
