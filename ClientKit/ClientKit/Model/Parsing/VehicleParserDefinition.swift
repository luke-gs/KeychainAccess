//
//  VehicleParserDefinition.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class VehicleParserDefinition: RangeParserDefinition {

    static public let allowedCharacterSet: CharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "?"))

    public init(range: CountableClosedRange<Int>, definitionKey: String, errorClosure: @escaping InvalidLengthErrorClosure) {
        super.init(range: range, definitionKey: definitionKey, allowedCharacterSet: VehicleParserDefinition.allowedCharacterSet, errorClosure: errorClosure)
    }
}
