//
//  ACNParserDefinition.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// An Australian Company Number (usually shortened to ACN) is a unique nine-digit number
public class ACNParserDefinition: FixedLengthNumberParserDefinition {

    static public let ACNKey = "acn"

    static public let ACNLength = 9

    public init() {
        super.init(length: ACNParserDefinition.ACNLength, queryKey: ACNParserDefinition.ACNKey)
    }

}
