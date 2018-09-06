//
//  TrafficHistory.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Unbox

public class TrafficHistory: NSObject, Serialisable {

    public let id: String
    public let source: MPOLSource

    public let trafficHistoryDescription: String?
    public let isLicenceCancelled: Bool
    public let isLicenceSurrendered: Bool
    public let demeritPoint: Int
    public let name: String?
    public let occurredDate: Date?
    public let expiryDate: Date?
    public let issuedDate: Date?

    // MARK: - Unbox
    public required init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: CodingKeys.id.rawValue)
        source = try unboxer.unbox(key: CodingKeys.source.rawValue)
        trafficHistoryDescription = unboxer.unbox(key: CodingKeys.trafficHistoryDescription.rawValue)
        isLicenceCancelled = try unboxer.unbox(key: CodingKeys.isLicenceCancelled.rawValue)
        isLicenceSurrendered = try unboxer.unbox(key: CodingKeys.isLicenceSurrendered.rawValue)
        demeritPoint = try unboxer.unbox(key: CodingKeys.demeritPoints.rawValue)
        name = unboxer.unbox(key: CodingKeys.name.rawValue)
        
        occurredDate = unboxer.unbox(key: CodingKeys.occurredDate.rawValue, formatter: ISO8601DateTransformer.shared)
        expiryDate = unboxer.unbox(key: CodingKeys.expiryDate.rawValue, formatter: ISO8601DateTransformer.shared)
        issuedDate = unboxer.unbox(key: CodingKeys.issuedDate.rawValue, formatter: ISO8601DateTransformer.shared)
    }

    // MARK: - NSSecureCoding
    public required init?(coder aDecoder: NSCoder) {

        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.id.rawValue) as String?,
              let sourceString = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.source.rawValue) as String?,
              let source = MPOLSource(rawValue: sourceString) else {
            return nil
        }
        
        self.id = id
        self.source = source
        trafficHistoryDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.trafficHistoryDescription.rawValue) as String?
        isLicenceCancelled = aDecoder.decodeBool(forKey: CodingKeys.isLicenceCancelled.rawValue)
        isLicenceSurrendered = aDecoder.decodeBool(forKey: CodingKeys.isLicenceSurrendered.rawValue)
        demeritPoint = aDecoder.decodeInteger(forKey: CodingKeys.demeritPoints.rawValue)
        name = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.name.rawValue) as String?
        occurredDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.occurredDate.rawValue) as Date?
        expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.expiryDate.rawValue) as Date?
        issuedDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.issuedDate.rawValue) as Date?

    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: CodingKeys.id.rawValue)
        aCoder.encode(source.rawValue, forKey: CodingKeys.source.rawValue)
        aCoder.encode(trafficHistoryDescription, forKey: CodingKeys.trafficHistoryDescription.rawValue)
        aCoder.encode(isLicenceCancelled, forKey: CodingKeys.isLicenceCancelled.rawValue)
        aCoder.encode(isLicenceSurrendered, forKey: CodingKeys.isLicenceSurrendered.rawValue)
        aCoder.encode(demeritPoint, forKey: CodingKeys.demeritPoints.rawValue)
        aCoder.encode(name, forKey: CodingKeys.name.rawValue)
        aCoder.encode(occurredDate, forKey: CodingKeys.occurredDate.rawValue)
        aCoder.encode(expiryDate, forKey: CodingKeys.expiryDate.rawValue)
        aCoder.encode(issuedDate, forKey: CodingKeys.issuedDate.rawValue)
    }

    public static var supportsSecureCoding: Bool {
        return true
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case source
        case trafficHistoryDescription = "description"
        case isLicenceCancelled = "licenceCancelled"
        case isLicenceSurrendered = "licenceSurrendered"
        case demeritPoints
        case name
        case occurredDate = "occurred"
        case expiryDate
        case issuedDate = "dateIssued"
    }

}
