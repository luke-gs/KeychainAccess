//
//  Order.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Unbox

@objc(MPLOrder)
open class Order: Entity {

    open var type: String?
    open var status: String?
    open var issuingAuthority: String?
    open var orderDescription: String?

    open var issuedDate: Date?

    public required init(unboxer: Unboxer) throws {
        type = unboxer.unbox(key: CodingKeys.type.rawValue)
        status = unboxer.unbox(key: CodingKeys.status.rawValue)
        issuingAuthority = unboxer.unbox(key: CodingKeys.issuingAuthority.rawValue)
        orderDescription = unboxer.unbox(key: CodingKeys.orderDescription.rawValue)
        issuedDate = unboxer.unbox(key: CodingKeys.issuedDate.rawValue, formatter: ISO8601DateTransformer.shared)

        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.type.rawValue) as String?
        status = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.status.rawValue) as String?
        issuingAuthority = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.issuingAuthority.rawValue) as String?
        orderDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.orderDescription.rawValue) as String?
        issuedDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.issuedDate.rawValue) as Date?
    }

    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(type, forKey: CodingKeys.type.rawValue)
        aCoder.encode(status, forKey: CodingKeys.status.rawValue)
        aCoder.encode(issuingAuthority, forKey: CodingKeys.issuingAuthority.rawValue)
        aCoder.encode(orderDescription, forKey: CodingKeys.orderDescription.rawValue)
        aCoder.encode(issuedDate, forKey: CodingKeys.issuedDate.rawValue)
    }

    // TODO: support codable
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    override open class var modelVersion: Int {
        return 1
    }
}

private enum CodingKeys: String, CodingKey {
    case type
    case status
    case issuingAuthority
    case orderDescription = "description"
    case issuedDate = "dateIssued"
}
