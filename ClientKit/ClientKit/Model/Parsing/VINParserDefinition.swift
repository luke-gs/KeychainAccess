//
//  VINParserDefinition.swift
//  ClientKit
//
//  Created by KGWH78 on 14/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit


public enum VINParserError: QueryParsingError {
    case invalidLength(query: String, requiredLengthRange: CountableClosedRange<Int>)
    
    public var message: String {
        switch self {
        case .invalidLength(_, let range):
            return "VIN must be between \(range.lowerBound) and \(range.upperBound)."
        }
    }
}


public class VINParserDefinition: QueryParserDefinition {
    
    public static let vinKey = "vin"
    public let tokenDefinitions: [QueryTokenDefinition]
    
    public init(range: CountableClosedRange<Int>) {
        let definition = QueryTokenDefinition(key: VINParserDefinition.vinKey, required: true, typeCheck: { token -> Bool in
            let allowedCharacters = CharacterSet.alphanumerics
            let extra = token.trimmingCharacters(in: allowedCharacters)
            return extra.characters.count == 0
        }) { (token, index, map) in
            let length = token.characters.count
            if range.contains(length) == false {
                throw VINParserError.invalidLength(query: token, requiredLengthRange: range)
            }
        }
        
        tokenDefinitions = [definition]
    }
    
    public func tokensFrom(query: String) -> [String] {
        return [query.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)]
    }
}

