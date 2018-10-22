//
//  CADOfficerCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import DemoAppKit
import Unbox

/// PSCore implementation of class representing an officer
open class CADOfficerCore: Officer, CADOfficerType {

    // MARK: - Network

    open var capabilities: [String] = []

    open var contactNumber: String?

    open var licenceTypeId: String?

    open var patrolGroup: String?

    open var radioId: String?

    open var remarks: String?

    open var station: String?

    // MARK: - Generated

    open var displayName: String {
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = givenName
        nameComponents.middleName = middleNames
        nameComponents.familyName = familyName
        return CADOfficerCore.nameFormatter.string(from: nameComponents)
    }

    public static var nameFormatter: PersonNameComponentsFormatter = {
        let nameFormatter = PersonNameComponentsFormatter()
        nameFormatter.style = .medium
        return nameFormatter
    }()

    open var payrollIdDisplayString: String {
        return "#\(employeeNumber)"
    }

    open var initials: String? {
        if let firstName = givenName, let lastName = familyName {
            return [String(firstName.prefix(1)), String(lastName.prefix(1))].joined(separator: "")
        }
        return nil
    }

    // MARK: - Init

    /// Default constructor
    required public init() {
        super.init()
    }

    /// Copy constructor
    public required init(officer: CADOfficerType) {
        super.init()
        self.capabilities = officer.capabilities
        self.contactNumber = officer.contactNumber
        self.givenName = officer.givenName
        self.familyName = officer.familyName
        self.licenceTypeId = officer.licenceTypeId
        self.patrolGroup = officer.patrolGroup
        self.radioId = officer.radioId
        self.remarks = officer.remarks
        self.station = officer.station
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case capabilities = "capabilities"
        case contactNumber = "contactNumber"
        case licenceTypeId = "licenceTypeId"
        case patrolGroup = "patrolGroup"
        case radioId = "radioId"
        case rank = "rank"
        case remarks = "remarks"
        case station = "station"
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        capabilities = (aDecoder.decodeObject(of: NSArray.self, forKey: CodingKeys.capabilities.rawValue) as? [String]) ?? []
        contactNumber = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.contactNumber.rawValue) as String?
        licenceTypeId = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.licenceTypeId.rawValue) as String?
        patrolGroup = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.patrolGroup.rawValue) as String?
        radioId = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.radioId.rawValue) as String?
        remarks = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.remarks.rawValue) as String?
        station = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.station.rawValue) as String?
    }

    public required init(unboxer: Unboxer) throws {
        do { try super.init(unboxer: unboxer) }

        capabilities = unboxer.unbox(key: CodingKeys.capabilities.rawValue) ?? []
        contactNumber = unboxer.unbox(key: CodingKeys.contactNumber.rawValue)
        licenceTypeId = unboxer.unbox(key: CodingKeys.licenceTypeId.rawValue)
        patrolGroup = unboxer.unbox(key: CodingKeys.patrolGroup.rawValue)
        radioId = unboxer.unbox(key: CodingKeys.radioId.rawValue)
        remarks = unboxer.unbox(key: CodingKeys.remarks.rawValue)
        station = unboxer.unbox(key: CodingKeys.station.rawValue)
    }

    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        if capabilities.count > 0 {
            aCoder.encode(capabilities, forKey: CodingKeys.capabilities.rawValue)
        }
        aCoder.encode(contactNumber, forKey: CodingKeys.contactNumber.rawValue)
        aCoder.encode(licenceTypeId, forKey: CodingKeys.licenceTypeId.rawValue)
        aCoder.encode(patrolGroup, forKey: CodingKeys.patrolGroup.rawValue)
        aCoder.encode(radioId, forKey: CodingKeys.radioId.rawValue)
        aCoder.encode(remarks, forKey: CodingKeys.remarks.rawValue)
        aCoder.encode(station, forKey: CodingKeys.station.rawValue)
    }

    public required init(from decoder: Decoder) throws {

        do { try super.init(from: decoder) }

        let values = try decoder.container(keyedBy: CodingKeys.self)
        capabilities = try values.decodeIfPresent([String].self, forKey: .capabilities) ?? []
        contactNumber = try values.decodeIfPresent(String.self, forKey: .contactNumber)
        licenceTypeId = try values.decodeIfPresent(String.self, forKey: .licenceTypeId)
        patrolGroup = try values.decodeIfPresent(String.self, forKey: .patrolGroup)
        radioId = try values.decodeIfPresent(String.self, forKey: .radioId)
        remarks = try values.decodeIfPresent(String.self, forKey: .remarks)
        station = try values.decodeIfPresent(String.self, forKey: .station)
    }

    open override func encode(to encoder: Encoder) throws {

        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)

        if capabilities.count > 0 {
            try container.encodeIfPresent(capabilities, forKey: .capabilities)
        }
        try container.encodeIfPresent(contactNumber, forKey: .contactNumber)
        try container.encodeIfPresent(licenceTypeId, forKey: .licenceTypeId)
        try container.encodeIfPresent(patrolGroup, forKey: .patrolGroup)
        try container.encodeIfPresent(radioId, forKey: .radioId)
        try container.encodeIfPresent(rank, forKey: .rank)
        try container.encodeIfPresent(remarks, forKey: .remarks)
        try container.encodeIfPresent(station, forKey: .station)
    }

}
