//
//  ABNACNWildcardParserDefinition.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public enum ABNACNWildcardParserError: LocalizedError {
    case invalidLength(query: String, requiredLengthRange: CountableClosedRange<Int>)
    
    public var errorDescription: String? {
        switch self {
        case .invalidLength(_, let range):
            return "ACN and ABN must be between \(range.lowerBound) and \(range.upperBound) characters long."
        }
    }
}

public class ABNACNWildcardParserDefinition: WildcardParserDefinition {
    public static let ABNACNWildcardNumberKey = "ABNACNWildcardNumber"
    
    public init() {
        super.init(range: 0...11,
                   definitionKey: ABNACNWildcardParserDefinition.ABNACNWildcardNumberKey,
                   allowedCharacterSet: .decimalDigits,
                   errorClosure: { (query, requiredLengthRange) -> LocalizedError in
                      return ABNACNWildcardParserError.invalidLength(query: query, requiredLengthRange: requiredLengthRange)
                   })
    }
}
