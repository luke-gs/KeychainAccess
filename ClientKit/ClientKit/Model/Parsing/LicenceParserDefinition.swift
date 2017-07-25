//
//  LicenceParserDefinition.swift
//  ClientKit
//
//  Created by Herli Halim on 21/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit

public enum LicenceParseError: Error {
    case invalidLicenceNumber
    case invalidLength(licenceNumber: String, requiredLengthRange: CountableClosedRange<Int>)
}

public struct LicenceParserDefinition: QueryParserDefinition {
    
    private static let whiteCharacterSets = CharacterSet.whitespacesAndNewlines
    private static let numberFormatter = NumberFormatter()
    
    public let range: CountableClosedRange<Int>
    public private(set) var tokenDefinitions: [QueryTokenDefinition]
    
    public init(range: CountableClosedRange<Int>) {
        self.range = range
        
        // Only one definition for licence
        let licenceDefinition = QueryTokenDefinition(key: "licence", required: true, typeCheck: { value -> Bool in
            return true
        }) { (value, index, map) in
            
            guard LicenceParserDefinition.numberFormatter.number(from: value) != nil else {
                throw LicenceParseError.invalidLicenceNumber
            }
            
            let length = value.characters.count
            if range.contains(length) == false {
                throw LicenceParseError.invalidLength(licenceNumber: value, requiredLengthRange: range)
            }
        }
        
        tokenDefinitions = [licenceDefinition]
    }
    
    public func tokensFrom(query: String) -> [String] {
        let trimmed = query.trimmingCharacters(in: LicenceParserDefinition.whiteCharacterSets)
        return [trimmed]
    }
    
}
