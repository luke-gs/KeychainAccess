//
//  ManifestCollection+Search.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public extension ManifestCollection {

    static var personBuild = ManifestCollection(rawValue: "PersonBuild")
    static var personHairColour = ManifestCollection(rawValue: "PersonHairColour")
    static var personEyeColour = ManifestCollection(rawValue: "PersonEyeColour")
    static var personRace = ManifestCollection(rawValue: "PersonRace")
    static var eventLocationInvolvementType = ManifestCollection(rawValue: "EventLocationInvolvementType")
    static var eventOfficerInvolvement = ManifestCollection(rawValue: "EventOfficerInvolvement")
    static var eventEntityRelationship = ManifestCollection(rawValue: "EventEntityRelationship")
    static var eventLocationAddressType = ManifestCollection(rawValue: "EventLocationAddressType")
    static var eventPersonPersonRelationship = ManifestCollection(rawValue: "EventPersonPersonRelationship")
    static var eventPersonVehicleRelationship = ManifestCollection(rawValue: "EventPersonVehicleRelationship")
    static var eventPersonLocationRelationship = ManifestCollection(rawValue: "EventPersonLocationRelationship")
    static var eventPersonOrganisationRelationship = ManifestCollection(rawValue: "EventPersonOrganisationRelationship")
    static var eventVehicleLocationRelationship = ManifestCollection(rawValue: "EventVehicleLocationRelationship")
    static var eventVehicleOrganisationRelationship = ManifestCollection(rawValue: "EventVehicleOrganisationRelationship")
    static var eventLocationOrganisationRelationship = ManifestCollection(rawValue: "EventLocationOrganisationRelationship")
    static var eventVehicleVehicleRelationship = ManifestCollection(rawValue: "EventVehicleVehicleRelationship")

    /// The search app specific manifest collections to fetch when syncing
    static var searchCollections: [ManifestCollection] = [
        .personBuild,
        .personHairColour,
        .personEyeColour,
        .personRace,
        .eventLocationInvolvementType,
        .eventOfficerInvolvement,
        .eventEntityRelationship,
        .eventLocationAddressType,
        .eventPersonPersonRelationship,
        .eventPersonVehicleRelationship,
        .eventPersonLocationRelationship,
        .eventPersonOrganisationRelationship,
        .eventVehicleLocationRelationship,
        .eventVehicleOrganisationRelationship,
        .eventLocationOrganisationRelationship,
        .eventVehicleVehicleRelationship
    ]
}
