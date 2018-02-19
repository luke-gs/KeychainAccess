//
//  SyncDetailsOfficer.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for a single Officer in the call to /sync/details
open class SyncDetailsOfficer: Codable, CADOfficerType {

    // MARK: - Network
    public var capabilities: [String]!

    public var contactNumber: String!

    public var firstName: String!

    public var lastName: String!

    public var licenceTypeId: String!

    public var middleName: String!

    public var patrolGroup: String!

    public var payrollId: String!

    public var radioId: String?

    public var rank: String!

    public var remarks: String!

    public var station: String!

    // MARK: - Generated

    open var displayName: String {
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = firstName
        nameComponents.middleName = middleName
        nameComponents.familyName = lastName
        return OfficerDetailsResponse.nameFormatter.string(from: nameComponents)
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
