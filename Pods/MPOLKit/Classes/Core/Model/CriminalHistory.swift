//
//  CriminalHistory.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Unbox

open class CriminalHistory: NSObject, Serialisable {
    
    public static var supportsSecureCoding: Bool { return true }
    
    var offenceDescription: String?
    var offenceCount: Int?
    var lastOccurred: Date?
    
    public required init(unboxer: Unboxer) {
        offenceDescription = unboxer.unbox(key: "offence")
        offenceCount = unboxer.unbox(key: "offenceCount")
        lastOccurred = unboxer.unbox(key: "offenceDate", formatter: ISO8601DateTransformer.shared)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    public func encode(with aCoder: NSCoder) {
        MPLUnimplemented()
    }
    
}
