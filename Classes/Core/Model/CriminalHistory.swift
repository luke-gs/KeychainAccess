//
//  CriminalHistory.swift
//  Pods
//
//  Created by Rod Brown on 23/5/17.
//
//

import Foundation
import Unbox

open class CriminalHistory: NSObject, Serialisable {
    
    public static var supportsSecureCoding: Bool { return true }
    
    var offenceDescription: String?
    var offenceCount: Int?
    var lastOccurred: Date?
    
    public required init(unboxer: Unboxer) {
        offenceDescription = unboxer.unbox(key: "offenceDescription")
        offenceCount = unboxer.unbox(key: "offenceCount")
        lastOccurred = unboxer.unbox(key: "lastOccurredDate", formatter: ISO8601DateTransformer.shared)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    public func encode(with aCoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
}
