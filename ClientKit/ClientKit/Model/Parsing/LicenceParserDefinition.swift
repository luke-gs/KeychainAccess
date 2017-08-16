//
//  LicenceParserDefinition.swift
//  ClientKit
//
//  Created by Herli Halim on 21/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit

public enum LicenceParseError: LocalizedError {
    case invalidLicenceNumber(licenceNumber: String)
    case invalidLength(licenceNumber: String, requiredLengthRange: CountableClosedRange<Int>)
    
    public var errorDescription: String? {
        switch self {
        case .invalidLicenceNumber(let licenceNumber):
            return "\(licenceNumber) is not a valid licence number."
        case .invalidLength(_, let range):
            return "Licence number must be between \(range.lowerBound) and \(range.upperBound)."
        }
    }
}

public struct LicenceParserDefinition: QueryParserDefinition {
    private static let whiteCharacterSets = CharacterSet.whitespacesAndNewlines
    private static let numberFormatter = NumberFormatter()
    
    public static let licenceKey = "licence"
    public let range: CountableClosedRange<Int>
    public private(set) var tokenDefinitions: [QueryTokenDefinition]
    
    public init(range: CountableClosedRange<Int>) {
        self.range = range
        
        // Only one definition for licence
        let licenceDefinition = QueryTokenDefinition(key: LicenceParserDefinition.licenceKey, required: true, typeCheck: { value -> Bool in
            return true
        }) { (value, index, map) in
            
            guard LicenceParserDefinition.numberFormatter.number(from: value) != nil else {
                throw LicenceParseError.invalidLicenceNumber(licenceNumber: value)
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
