//
//  LicenceWildcardParserDefinition.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public enum LicenceWildcardParserError: LocalizedError {
    case invalidLength(query: String, requiredLengthRange: CountableClosedRange<Int>)

    public var errorDescription: String? {
        switch self {
        case .invalidLength(_, let range):
            return "Licence number must be between \(range.lowerBound) and \(range.upperBound) characters long."
        }
    }
}

public class LicenceWildcardParserDefinition: WildcardParserDefinition, LicenceDefinitionType {
    public static let licenceNumberKey = "licenceNumber"

    public init(range: CountableClosedRange<Int>) {
        super.init(range: range,
                   definitionKey: LicenceWildcardParserDefinition.licenceNumberKey,
                   allowedCharacterSet: .decimalDigits,
                   errorClosure: { (query, requiredLengthRange) -> LocalizedError in
                      return LicenceWildcardParserError.invalidLength(query: query, requiredLengthRange: requiredLengthRange)
                   })
    }
}
