//
//  OrganisationParserDefinition.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public class OrganisationParserDefinition: QueryParserDefinition {

    private let nameDefinition: QueryTokenDefinition

    public init(maxNameLength: Int = Int.max) {

        nameDefinition = QueryTokenDefinition(key: OrganisationParserDefinition.NameKey, required: false, typeCheck: { _ -> Bool in
            // accept all names for now, other fields are supplied as search options
            return true
        })
    }

    // MARK: - Public Static Constants

    public static let NameKey = "name"

    // MARK: - Query Parser Type

    public func tokensFrom(query: String) -> [String] {
        return [query]
    }

    public var tokenDefinitions: [QueryTokenDefinition] {
        return [
            nameDefinition
        ]
    }

}
