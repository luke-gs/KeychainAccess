//
//  VehicleParserDefinition.swift
//  ClientKit
//
//  Created by KGWH78 on 11/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public enum RegistrationParserError: LocalizedError {
    case invalidLength(query: String, requiredLengthRange: CountableClosedRange<Int>)
    
    public var errorDescription: String? {
        switch self {
        case .invalidLength(_, let range):
            return "Registration must be between \(range.lowerBound) and \(range.upperBound) characters long."
        }
    }
}

fileprivate var invalidLengthError: RangeParserDefinition.InvalidLengthErrorClosure {
    return {  (query, requiredLengthRange) -> LocalizedError in
        return RegistrationParserError.invalidLength(query: query, requiredLengthRange: requiredLengthRange)
    }
}

public class RegistrationParserDefinition: VehicleParserDefinition {
    
    public static let registrationKey = "registration"

    public init(range: CountableClosedRange<Int>) {
        super.init(range: range, definitionKey: RegistrationParserDefinition.registrationKey, errorClosure: invalidLengthError)
    }

}

public class RegistrationWildcardParserDefinition: VehicleWildcardParserDefinition {

    public static let registrationKey = "registration"

    public init(range: CountableClosedRange<Int>) {
        super.init(range: range, definitionKey: RegistrationParserDefinition.registrationKey, errorClosure: invalidLengthError)
    }
}
