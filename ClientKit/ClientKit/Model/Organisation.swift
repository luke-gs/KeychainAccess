//
//  Organisation.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import Unbox


private enum CodingKeys: String, CodingKey {
    case name = "name"
    case acn = "acn"
    case abn = "abn"
    case type = "type"
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
    
    open override class var localizedDisplayName: String {
        return NSLocalizedString("Organisation", comment: "")
    }
    
    open override var summary: String {
        return name ?? ""
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
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        name = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.name.rawValue) as String?
        acn = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.acn.rawValue) as String?
        abn = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.abn.rawValue) as String?
        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.type.rawValue) as String?
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        aCoder.encode(name, forKey: CodingKeys.name.rawValue)
        aCoder.encode(acn, forKey: CodingKeys.acn.rawValue)
        aCoder.encode(abn, forKey: CodingKeys.abn.rawValue)
        aCoder.encode(type, forKey: CodingKeys.type.rawValue)
       
    }
}
