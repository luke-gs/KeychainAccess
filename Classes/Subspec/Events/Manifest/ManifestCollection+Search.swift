//
//  ManifestCollection+Search.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Extension for Search specific manifest categories
///
/// Note: these are defined as vars to allow override in client app
///
public extension ManifestCollection {
    static var personBuild = ManifestCollection(rawValue: "PersonBuild")
    static var personHairColour = ManifestCollection(rawValue: "PersonHairColour")
    static var personEyeColour = ManifestCollection(rawValue: "PersonEyeColour")
    static var personRace = ManifestCollection(rawValue: "PersonRace")
    static var eventLocationInvolvementType = ManifestCollection(rawValue: "EventLocationInvolvementType")
    static var eventOfficerInvolvement = ManifestCollection(rawValue: "EventOfficerInvolvement")
    static var eventEntityRelationship = ManifestCollection(rawValue: "EventEntityRelationship")

    /// The search app specific manifest collections to fetch when syncing
    static var searchCollections: [ManifestCollection] = [.personBuild,
                                                          .personHairColour,
                                                          .personEyeColour,
                                                          .personRace,
                                                          .eventLocationInvolvementType,
                                                          .eventOfficerInvolvement,
                                                          .eventEntityRelationship]

}

