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

    public var capabilities: [String] = []

    public var contactNumber: String?

    public var licenceTypeId: String?

    public var patrolGroup: String?

    public var radioId: String?

    public var remarks: String?

    public var station: String?

    // MARK: - Generated

    public var displayName: String {
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

    public var payrollIdDisplayString: String {
        return "#\(employeeNumber ?? "Unknown")"
    }

    public var initials: String? {
        if let firstName = givenName, let lastName = familyName {
            return [String(firstName.prefix(1)), String(lastName.prefix(1))].joined(separator: "")
        }
        return nil
    }

    // MARK: - Init

    /// Default constructor
    required public override init(id: String) {
        super.init(id: id)
    }

    /// Copy constructor
    public required init(officer: CADOfficerType) {
        super.init(id: officer.id)
        self.capabilities = officer.capabilities
        self.contactNumber = officer.contactNumber
        self.givenName = officer.givenName
        self.familyName = officer.familyName
        self.licenceTypeId = officer.licenceTypeId
        self.middleNames = officer.middleNames
        self.patrolGroup = officer.patrolGroup
        self.employeeNumber = officer.employeeNumber
        self.radioId = officer.radioId
        self.rank = officer.rank
        self.remarks = officer.remarks
        self.station = officer.station
        self.region = officer.region
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

    public required init(unboxer: Unboxer) throws {
        try super.init(unboxer: unboxer)

        capabilities = unboxer.unbox(key: CodingKeys.capabilities.rawValue) ?? []
        contactNumber = unboxer.unbox(key: CodingKeys.contactNumber.rawValue)
        licenceTypeId = unboxer.unbox(key: CodingKeys.licenceTypeId.rawValue)
        patrolGroup = unboxer.unbox(key: CodingKeys.patrolGroup.rawValue)
        radioId = unboxer.unbox(key: CodingKeys.radioId.rawValue)
        remarks = unboxer.unbox(key: CodingKeys.remarks.rawValue)
        station = unboxer.unbox(key: CodingKeys.station.rawValue)
    }

    public required init(from decoder: Decoder) throws {

        try super.init(from: decoder)

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
