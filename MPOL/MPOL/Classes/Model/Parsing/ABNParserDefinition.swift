//
//  ABNParserDefinition.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

// TODO: In the future check if the checksum is valid
/// The ABN is an 11-digit number where the first two digits are a checksum
public class ABNParserDefinition: FixedLengthNumberParserDefinition {
    
    static public let ABNKey = "abn"
    
    static public let ABNLength = 11
    
    public init() {
        super.init(length: ABNParserDefinition.ABNLength, queryKey: ABNParserDefinition.ABNKey)
    }
    
}
