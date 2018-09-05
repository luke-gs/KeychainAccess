//
//  EngineNumberParserDefinition.swift
//  ClientKit
//
//  Created by KGWH78 on 14/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public enum EngineNumberParserError: LocalizedError {
    case invalidLength(query: String, requiredLengthRange: CountableClosedRange<Int>)
    
    public var errorDescription: String? {
        switch self {
        case .invalidLength(_, let range):
            return "Engine number must be between \(range.lowerBound) and \(range.upperBound) characters long."
        }
    }
}

public protocol EngineNumberDefinitionType {
    static var engineNumberKey: String { get }
}

public class EngineNumberParserDefinition: WildcardParserDefinition, EngineNumberDefinitionType {
    public static let engineNumberKey = "engineNumber"

    public init(range: CountableClosedRange<Int>) {
        super.init(range: range, definitionKey: EngineNumberParserDefinition.engineNumberKey, errorClosure: invalidLengthError)
    }
}

fileprivate var invalidLengthError: RangeParserDefinition.InvalidLengthErrorClosure {
    return {  (query, requiredLengthRange) -> LocalizedError in
        return EngineNumberParserError.invalidLength(query: query, requiredLengthRange: requiredLengthRange)
    }
}
