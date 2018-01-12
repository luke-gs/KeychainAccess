//
//  CriminalHistory.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Unbox

open class CriminalHistory: NSObject, Serialisable {
    
    public static var supportsSecureCoding: Bool { return true }
    open static var modelVersion: Int { return 0 }
    
    var offenceDescription: String?
    var offenceCount: Int?
    var lastOccurred: Date?
    
    public required init(unboxer: Unboxer) {
        offenceDescription = unboxer.unbox(key: "offence")
        offenceCount = unboxer.unbox(key: "offenceCount")
        lastOccurred = unboxer.unbox(key: "offenceDate", formatter: ISO8601DateTransformer.shared)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        offenceDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.offenceDescription.rawValue) as String?
        offenceCount = aDecoder.decodeInteger(forKey: CodingKey.offenceCount.rawValue)
        lastOccurred = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.lastOccurred.rawValue) as Date?
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(CriminalHistory.modelVersion, forKey: CodingKey.version.rawValue)

        aCoder.encode(offenceDescription, forKey: CodingKey.offenceDescription.rawValue)
        aCoder.encode(offenceCount, forKey: CodingKey.offenceCount.rawValue)
        aCoder.encode(lastOccurred, forKey: CodingKey.lastOccurred.rawValue)
    }

    private enum CodingKey: String {
        case version
        case offenceDescription
        case offenceCount
        case lastOccurred
    }
    
}
