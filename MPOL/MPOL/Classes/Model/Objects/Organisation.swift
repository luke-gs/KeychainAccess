//
//  Organisation.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import Unbox


private enum CodingKeys: String, CodingKey {
    case name = "name"
    case acn = "acn"
    case abn = "abn"
    case type = "type"
    case tradingAs = "tradingAs"
    case locations = "locations"
    case aliases = "aliases"
}


@objc(MPLOrganisation)
open class Organisation: Entity {
    
    override open class var serverTypeRepresentation: String {
        return "organisation"
    }
    
    open var name: String?
    open var acn: String?
    open var abn: String?
    open var type: String?
    
    open var tradingAs: String?
    open var locations: [Address]?
    open var aliases: [Alias]?
    
    open override class var localizedDisplayName: String {
        return NSLocalizedString("Organisation", comment: "")
    }
    
    open override var summary: String {
        guard let tradingAsName = tradingAs else { return name ?? "" }
        guard let name = name else { return tradingAsName }
        return "\(name) trading as \(tradingAsName)"
    }
    
    public required override init(id: String = UUID().uuidString) {
        super.init(id: id)
    }
    
    public required init(unboxer: Unboxer) throws {
        try super.init(unboxer: unboxer)
        name = unboxer.unbox(key: CodingKeys.name.rawValue)
        acn = unboxer.unbox(key: CodingKeys.acn.rawValue)
        abn = unboxer.unbox(key: CodingKeys.abn.rawValue)
        type = unboxer.unbox(key: CodingKeys.type.rawValue)
        locations = unboxer.unbox(key: CodingKeys.locations.rawValue)
        tradingAs = unboxer.unbox(key: CodingKeys.tradingAs.rawValue)
        aliases = unboxer.unbox(key: CodingKeys.aliases.rawValue)

    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        name = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.name.rawValue) as String?
        acn = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.acn.rawValue) as String?
        abn = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.abn.rawValue) as String?
        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.type.rawValue) as String?
        locations = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKeys.locations.rawValue) as? [Address]
        tradingAs = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.tradingAs.rawValue) as String?
        aliases = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKeys.aliases.rawValue) as? [Alias]
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        aCoder.encode(name, forKey: CodingKeys.name.rawValue)
        aCoder.encode(acn, forKey: CodingKeys.acn.rawValue)
        aCoder.encode(abn, forKey: CodingKeys.abn.rawValue)
        aCoder.encode(type, forKey: CodingKeys.type.rawValue)
        aCoder.encode(locations, forKey: CodingKeys.locations.rawValue)
        aCoder.encode(tradingAs, forKey: CodingKeys.tradingAs.rawValue)
        aCoder.encode(aliases, forKey: CodingKeys.aliases.rawValue)
    }
}
