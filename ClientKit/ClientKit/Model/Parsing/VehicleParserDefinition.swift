//
//  VehicleParserDefinition.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class VehicleParserDefinition: QueryParserDefinition {

    public let tokenDefinitions: [QueryTokenDefinition]
    static public let allowedCharacterSet: CharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "?"))
    private let whitespacesAndNewlinesCharacterSet = CharacterSet.whitespacesAndNewlines

    public init(tokenDefinitions: [QueryTokenDefinition]) {
        self.tokenDefinitions = tokenDefinitions
    }

    public func tokensFrom(query: String) -> [String] {
        return [query.trimmingCharacters(in: whitespacesAndNewlinesCharacterSet)]
    }

}
