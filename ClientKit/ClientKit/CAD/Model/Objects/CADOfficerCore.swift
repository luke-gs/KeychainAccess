//
//  CADOfficerCore.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// PSCore implementation of class representing an officer
open class CADOfficerCore: Codable, CADOfficerType {

    // MARK: - Network
    open var capabilities: [String]!

    open var contactNumber: String!

    open var firstName: String!

    open var lastName: String!

    open var licenceTypeId: String!

    open var middleName: String!

    open var patrolGroup: String!

    open var payrollId: String!

    open var radioId: String?

    open var rank: String!

    open var remarks: String!

    open var station: String!

    // MARK: - Generated

    open var displayName: String {
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = firstName
        nameComponents.middleName = middleName
        nameComponents.familyName = lastName
        return CADOfficerDetailsResponse.nameFormatter.string(from: nameComponents)
    }

    open static var nameFormatter: PersonNameComponentsFormatter = {
        let nameFormatter = PersonNameComponentsFormatter()
        nameFormatter.style = .medium
        return nameFormatter
    }()

    open var payrollIdDisplayString: String? {
        if let payrollId = payrollId {
            return "#\(payrollId)"
        }
        return nil
    }

    open var initials: String {
        return [String(firstName?.prefix(1)), String(lastName?.prefix(1))].joined(separator: "")
    }

    // MARK: - Init

    /// Default constructor
    public required init() { }

    /// Copy constructor
    public required init(officer: CADOfficerType) {
        self.capabilities = officer.capabilities
        self.contactNumber = officer.contactNumber
        self.firstName = officer.firstName
        self.lastName = officer.lastName
        self.licenceTypeId = officer.licenceTypeId
        self.middleName = officer.middleName
        self.patrolGroup = officer.patrolGroup
        self.payrollId = officer.payrollId
        self.radioId = officer.radioId
        self.rank = officer.rank
        self.remarks = officer.remarks
        self.station = officer.station
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case capabilities = "capabilities"
        case contactNumber = "contactNumber"
        case firstName = "firstName"
        case lastName = "lastName"
        case licenceTypeId = "licenceTypeId"
        case middleName = "middleName"
        case patrolGroup = "patrolGroup"
        case payrollId = "payrollId"
        case radioId = "radioId"
        case rank = "rank"
        case remarks = "remarks"
        case station = "station"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        capabilities = try values.decodeIfPresent([String].self, forKey: .capabilities)
        contactNumber = try values.decodeIfPresent(String.self, forKey: .contactNumber)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        licenceTypeId = try values.decodeIfPresent(String.self, forKey: .licenceTypeId)
        middleName = try values.decodeIfPresent(String.self, forKey: .middleName)
        patrolGroup = try values.decodeIfPresent(String.self, forKey: .patrolGroup)
        payrollId = try values.decodeIfPresent(String.self, forKey: .payrollId)
        radioId = try values.decodeIfPresent(String.self, forKey: .radioId)
        rank = try values.decodeIfPresent(String.self, forKey: .rank)
        remarks = try values.decodeIfPresent(String.self, forKey: .remarks)
        station = try values.decodeIfPresent(String.self, forKey: .station)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
