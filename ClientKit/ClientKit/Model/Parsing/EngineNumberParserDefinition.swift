//
//  EngineNumberParserDefinition.swift
//  ClientKit
//
//  Created by KGWH78 on 14/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public enum EngineNumberParserError: LocalizedError {
    case invalidLength(query: String, requiredLengthRange: CountableClosedRange<Int>)
    
    public var errorDescription: String? {
        switch self {
        case .invalidLength(_, let range):
            return "Engine number must be between \(range.lowerBound) and \(range.upperBound) characters long."
        }
    }
}

public class EngineNumberParserDefinition: VehicleParserDefinition {
    public static let engineNumberKey = "engineNumber"

    public init(range: CountableClosedRange<Int>) {
        let definition = QueryTokenDefinition(key: EngineNumberParserDefinition.engineNumberKey, required: true, typeCheck: { [allowedCharacterSet = VehicleParserDefinition.allowedCharacterSet] token -> Bool in
            let extra = token.trimmingCharacters(in: allowedCharacterSet)
            return extra.count == 0
        }) { (token, index, map) in
            let length = token.count
            if range.contains(length) == false {
                throw EngineNumberParserError.invalidLength(query: token, requiredLengthRange: range)
            }
        }
        
        super.init(tokenDefinitions: [definition])
    }

}


