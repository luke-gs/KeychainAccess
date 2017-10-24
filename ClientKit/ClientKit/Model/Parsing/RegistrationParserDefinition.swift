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

public class RegistrationParserDefinition: QueryParserDefinition {
    
    public static let registrationKey = "registration"
    
    public let tokenDefinitions: [QueryTokenDefinition]
    
    public init(range: CountableClosedRange<Int>) {
        let definition = QueryTokenDefinition(key: RegistrationParserDefinition.registrationKey, required: true, typeCheck: { token -> Bool in
            let allowedCharacters = CharacterSet.alphanumerics
            let extra = token.trimmingCharacters(in: allowedCharacters)
            return extra.count == 0
        }) { (token, index, map) in
            let length = token.count
            if range.contains(length) == false {
                throw RegistrationParserError.invalidLength(query: token, requiredLengthRange: range)
            }
        }
        
        tokenDefinitions = [definition]
    }
    
    public func tokensFrom(query: String) -> [String] {
        return [query.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)]
    }
}


