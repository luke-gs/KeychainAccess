//
//  VINParserDefinition.swift
//  ClientKit
//
//  Created by KGWH78 on 14/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public enum VINParserError: LocalizedError {
    case invalidLength(query: String, requiredLengthRange: CountableClosedRange<Int>)
    
    public var errorDescription: String? {
        switch self {
        case .invalidLength(_, let range):
            return "VIN must be between \(range.lowerBound) and \(range.upperBound) characters long."
        }
    }
}

fileprivate var invalidLengthError: RangeParserDefinition.InvalidLengthErrorClosure {
    return {  (query, requiredLengthRange) -> LocalizedError in
        return VINParserError.invalidLength(query: query, requiredLengthRange: requiredLengthRange)
    }
}

public class VINParserDefinition: VehicleParserDefinition {
    
    public static let vinKey = "vin"
    
    public init(range: CountableClosedRange<Int>) {
        super.init(range: range, definitionKey: VINParserDefinition.vinKey, errorClosure: invalidLengthError)
    }
}

public class VINWildcardParserDefinition: VehicleWildcardParserDefinition {

    public static let registrationKey = "vin"

    public init(range: CountableClosedRange<Int>) {
        super.init(range: range, definitionKey: VINParserDefinition.vinKey, errorClosure: invalidLengthError)
    }
}
