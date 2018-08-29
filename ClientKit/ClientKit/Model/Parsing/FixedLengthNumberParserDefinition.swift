//
//  FixedLengthNumberParserDefinition.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public enum FixedLengthParseError: LocalizedError {
    case invalidNumber(number: String)
    case invalidLength(number: String, requiredLength: Int)
    
    public var errorDescription: String? {
        switch self {
        case .invalidNumber(let number):
            return "\(number) Could not be parsed."
        case .invalidLength(_, let length):
            return "Number must be \(length) characters long."
        }
    }
}

/// A parser for numbers of a fixed length, ie ACN or ABN numbers
public class FixedLengthNumberParserDefinition: QueryParserDefinition {
    
    private static let numberFormatter = NumberFormatter()
    
    public let queryKey: String
    public let length: Int
    
    public private(set) var tokenDefinitions: [QueryTokenDefinition]
    
    public init(length: Int, queryKey: String) {
        self.length = length
        self.queryKey = queryKey
        let numberDefinition = QueryTokenDefinition(key: queryKey, required: true, typeCheck: { value -> Bool in
            return true
        }) { (value, index, map) in
            
            guard FixedLengthNumberParserDefinition.numberFormatter.number(from: value) != nil else {
                throw FixedLengthParseError.invalidNumber(number: value)
            }
            
            if length != value.count {
                throw FixedLengthParseError.invalidLength(number: value, requiredLength: length)
            }
        }
        
        tokenDefinitions = [numberDefinition]
    }
    
    public func tokensFrom(query: String) -> [String] {
        let sanitised = sanitiseValue(query)
        return [sanitised]
    }
    
    /// Returns whether a queryString is valid to use this parser.
    open func validateQuery(_ query: String) -> Bool {
        let sanitisedString = sanitiseValue(query)
        return sanitisedString.isEmpty == false && FixedLengthNumberParserDefinition.numberFormatter.number(from: sanitisedString) != nil && sanitisedString.count == length
    }
    
    /// Sanities user input, override this to perform specific subclass sanitation
    open func sanitiseValue(_ value: String) -> String {
        return value.replacingOccurrences(of: " ", with: "")
    }
    
}
