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

    open var alias: String?

    public required init(id: String = UUID().uuidString) {
        super.init(id: id)
    }

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {
        alias = unboxer.unbox(key: "alias")
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        alias = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.alias.rawValue) as String?
    }

    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(alias, forKey: CodingKey.alias.rawValue)
    }

    private enum CodingKey: String {
        case alias
    }
}
