//
//  AssociationReason.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import Unbox

open class AssociationReason: NSObject, Serialisable {
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    open let id: String
    
    open var effectiveDate: Date?
    open var reason: String?
    
    public required init(unboxer: Unboxer) throws {
        id = unboxer.unbox(key: "id") ?? UUID().uuidString
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: AssociationReason.dateTransformer)
        reason = unboxer.unbox(key: "reason")
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        id = (aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String?)!
        
        super.init()
        
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
        reason = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.reason.rawValue) as String?
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        aCoder.encode(effectiveDate, forKey: CodingKey.effectiveDate.rawValue)
        aCoder.encode(reason, forKey: CodingKey.reason.rawValue)
    }
    
    open static var supportsSecureCoding: Bool { return true }
    
    private enum CodingKey: String {
        case id
        case effectiveDate
        case reason
    }
    
    // MARK: - Temp Formatters
    
    func formattedReason() -> String? {
        guard let reason = reason else { return nil }
        guard let date = effectiveDate else { return reason }
        return reason + " " +  DateFormatter.preferredDateStyle.string(from: date)
    }

}
