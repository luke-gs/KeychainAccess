//
//  CriminalHistory.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Unbox

@objc (MPLCrimimalHistory)
open class CriminalHistory: Entity {

    let offenceDescription: String?
    let primaryCharge: String?
    let occurredDate: Date?
    let courtName: String?

    public required init(unboxer: Unboxer) throws {
        offenceDescription = unboxer.unbox(key: CodingKeys.offenceDescription.rawValue)
        primaryCharge = unboxer.unbox(key: CodingKeys.primaryCharge.rawValue)
        occurredDate = unboxer.unbox(key: CodingKeys.occurredDate.rawValue, formatter: ISO8601DateTransformer.shared)
        courtName = unboxer.unbox(key: CodingKeys.courtName.rawValue)

        try super.init(unboxer: unboxer)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        offenceDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.offenceDescription.rawValue) as String?
        primaryCharge = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.primaryCharge.rawValue) as String?
        occurredDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.occurredDate.rawValue) as Date?
        courtName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.courtName.rawValue) as String?

        super.init(coder: aDecoder)
    }
    
    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(offenceDescription, forKey: CodingKeys.offenceDescription.rawValue)
        aCoder.encode(primaryCharge, forKey: CodingKeys.primaryCharge.rawValue)
        aCoder.encode(occurredDate, forKey: CodingKeys.occurredDate.rawValue)
        aCoder.encode(courtName, forKey: CodingKeys.courtName.rawValue)

    }

    override open static var modelVersion: Int {
        return 1
    }

    private enum CodingKeys: String, CodingKey {
        case primaryCharge
        case offenceDescription = "description"
        case occurredDate = "occurred"
        case courtName
    }

}

open class OffenderCharge: CriminalHistory {
    let nextCourtDate: Date?

    public required init(unboxer: Unboxer) throws {
        nextCourtDate = unboxer.unbox(key: CodingKeys.nextCourtDate.rawValue, formatter: ISO8601DateTransformer.shared)
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        nextCourtDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.nextCourtDate.rawValue) as Date?
        super.init(coder: aDecoder)
    }

    private enum CodingKeys: String, CodingKey {
        case nextCourtDate
    }

}

open class OffenderConviction: CriminalHistory {
    let finalCourtDate: Date?

    public required init(unboxer: Unboxer) throws {
        finalCourtDate = unboxer.unbox(key: CodingKeys.finalCourtDate.rawValue, formatter: ISO8601DateTransformer.shared)
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        finalCourtDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.finalCourtDate.rawValue) as Date?
        super.init(coder: aDecoder)
    }

    private enum CodingKeys: String, CodingKey {
        case finalCourtDate
    }
}
