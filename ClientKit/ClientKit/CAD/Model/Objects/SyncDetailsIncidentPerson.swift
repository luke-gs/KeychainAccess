//
//  SyncDetailsIncidentPerson.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Reponse object for a single person in an incident
open class SyncDetailsIncidentPerson: Codable, CADIncidentPersonType {
    open var alertLevel: Int!
    open var dateOfBirth: String!

    open var firstName: String!
    open var middleNames: String!
    open var lastName: String!
    open var fullAddress: String!
    open var gender: String!
    open var thumbnail: String!

    open var initials: String {
        return ["\(firstName?.prefix(1))", String(lastName?.prefix(1))].joined(separator: "")
    }

    open var fullName: String {
        let lastFirst = [lastName, firstName].joined(separator: ", ")
        let middle = middleNames != nil ? "\(middleNames.prefix(1))." : nil

        return [lastFirst, middle].joined()
    }

}

