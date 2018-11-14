//
//  OrganisationAlias.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import Unbox

@objc(MPLOrganisationAlias)
open class OrganisationAlias: Alias {

    // MARK: - Properties

    public var alias: String?

    public override init(id: String) {
        super.init(id: id)
    }

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {
        alias = unboxer.unbox(key: "alias")
        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case alias
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        alias = try container.decodeIfPresent(String.self, forKey: .alias)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alias, forKey: CodingKeys.alias)
    }

}
