//
//  WildcardABNACNParser.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public enum WildABNACNParserError: LocalizedError {
    case invalidLength(query: String, requiredLengthRange: CountableClosedRange<Int>)
    
    public var errorDescription: String? {
        switch self {
        case .invalidLength(_, let range):
            return "ACN and ABN must be between \(range.lowerBound) and \(range.upperBound) characters long."
        }
    }
}

public protocol ABNACNWildcardDefinitionType {
    static var ABNACNWildcardNumberKey: String { get }
}

public class ABNACNWildcardParserDefinition: WildcardParserDefinition, ABNACNWildcardDefinitionType {
    public static let ABNACNWildcardNumberKey = "ABNACNWildcardNumber"
    
    public init() {
        super.init(range: 0...11,
                   definitionKey: ABNACNWildcardParserDefinition.ABNACNWildcardNumberKey,
                   allowedCharacterSet: .decimalDigits,
                   errorClosure: invalidLengthError)
    }
}

fileprivate var invalidLengthError: RangeParserDefinition.InvalidLengthErrorClosure {
    return { (query, requiredLengthRange) -> LocalizedError in
        return WildABNACNParserError.invalidLength(query: query, requiredLengthRange: requiredLengthRange)
    }
}
