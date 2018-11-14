//
//  Organisation.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import Unbox

@objc(MPLOrganisation)
open class Organisation: Entity {

    // MARK: - Class

    override open class var serverTypeRepresentation: String {
        return "organisation"
    }

    open override class var localizedDisplayName: String {
        return NSLocalizedString("Organisation", comment: "")
    }

    public required override init(id: String) {
        super.init(id: id)
    }

    // MARK: - Properties

    public var abn: String?
    public var acn: String?
    public var aliases: [OrganisationAlias]?
    public var name: String?
    public var tradingAs: String?
    public var type: String?

    public var contacts: [Contact]?

    // MARK: - Calculated

    open override var summary: String {
        guard let tradingAsName = tradingAs else { return name ?? "" }
        guard let name = name else { return tradingAsName }
        return "\(name) trading as \(tradingAsName)"
    }

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {
        try super.init(unboxer: unboxer)
        name = unboxer.unbox(key: CodingKeys.name.rawValue)
        acn = unboxer.unbox(key: CodingKeys.acn.rawValue)
        abn = unboxer.unbox(key: CodingKeys.abn.rawValue)
        type = unboxer.unbox(key: CodingKeys.type.rawValue)
        tradingAs = unboxer.unbox(key: CodingKeys.tradingAs.rawValue)
        aliases = unboxer.unbox(key: CodingKeys.aliases.rawValue)
        contacts = unboxer.unbox(key: CodingKeys.contacts.rawValue)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case abn
        case acn
        case aliases
        case name
        case tradingAs
        case type
        case contacts
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        abn = try container.decodeIfPresent(String.self, forKey: .abn)
        acn = try container.decodeIfPresent(String.self, forKey: .acn)
        aliases = try container.decodeIfPresent([OrganisationAlias].self, forKey: .aliases)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        tradingAs = try container.decodeIfPresent(String.self, forKey: .tradingAs)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        contacts = try container.decodeIfPresent([Contact].self, forKey: .contacts)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(abn, forKey: CodingKeys.abn)
        try container.encode(acn, forKey: CodingKeys.acn)
        try container.encode(aliases, forKey: CodingKeys.aliases)
        try container.encode(name, forKey: CodingKeys.name)
        try container.encode(tradingAs, forKey: CodingKeys.tradingAs)
        try container.encode(type, forKey: CodingKeys.type)
        try container.encode(contacts, forKey: CodingKeys.contacts)
    }

}
