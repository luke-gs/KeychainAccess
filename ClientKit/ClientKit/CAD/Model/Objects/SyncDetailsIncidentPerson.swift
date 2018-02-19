//
//  SyncDetailsIncidentPerson.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// Reponse object for a single person in an incident
open class SyncDetailsIncidentPerson: Codable, CADIncidentPersonType {

    public var alertLevel: Int!

    public var dateOfBirth: String!

    public var firstName: String!

    public var fullAddress: String!

    public var gender: String!

    public var lastName: String!

    public var middleNames: String!

    public var thumbnail: String!


    open var initials: String {
        return [String(firstName?.prefix(1)), String(lastName?.prefix(1))].joined(separator: "")
    }

    open var fullName: String {
        let lastFirst = [lastName, firstName].joined(separator: ", ")
        let middle = middleNames != nil ? "\(middleNames.prefix(1))." : nil

        return [lastFirst, middle].joined()
    }

}

