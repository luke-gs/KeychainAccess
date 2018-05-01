//
//  Order.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Unbox

@objc(MPLOrder)
open class Order: NSObject, Serialisable {

    open var type: String?

    open var eventDescription: String?
    open var occurredDate: Date?

    public required init(unboxer: Unboxer) throws {
        type = unboxer.unbox(key: CodingKeys.type.rawValue)
    }

    public required init?(coder aDecoder: NSCoder) {
        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.type.rawValue) as String?
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(type, forKey: CodingKeys.type.rawValue)
    }

    public static var supportsSecureCoding: Bool {
        return true
    }

    open class var modelVersion: Int {
        return 1
    }
}

private enum CodingKeys: String, CodingKey {
    case type
}
