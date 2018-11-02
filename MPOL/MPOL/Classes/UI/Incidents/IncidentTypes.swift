//
//  IncidentTypes.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit

extension IncidentType {

    // Add incident types here
    // rawValue used as title
    static let interceptReport = IncidentType(rawValue: "Intercept Report")
    static let trafficInfringement = IncidentType(rawValue: "Traffic Infringement")
    static let domesticViolence = IncidentType(rawValue: "Domestic Violence")

    /// Contains all incident types
    ///
    /// Used to determine the correct builder to use
    ///
    /// If you forget to add the incident here but still try to add it to the event
    /// it will attempt to use a blank incident builder which might not exist
    ///
    /// - Returns: all the incident types defined
    static func allIncidentTypes() -> [IncidentType] {
        return [
            .interceptReport,
            .trafficInfringement,
            .domesticViolence
        ]
    }

    func involvements(for entity: MPOLKitEntity) -> [String] {
        switch entity {
        case is Person:
            if let items = Manifest.shared.entries(for: .eventPersonInvolvementType)?.rawValues() {
                return items
            }

            fatalError("Manifest items not found for \(ManifestCollection.eventPersonInvolvementType.rawValue)")

        case is Vehicle:
            if let items = Manifest.shared.entries(for: .eventVehicleInvolvementType)?.rawValues() {
                return items
            }

            fatalError("Manifest items not found for \(ManifestCollection.eventVehicleInvolvementType.rawValue)")

        case is Organisation:
            if let items = Manifest.shared.entries(for: .eventOrganisationInvolvementType)?.rawValues() {
                return items
            }

            fatalError("Manifest items not found for \(ManifestCollection.eventOrganisationInvolvementType.rawValue)")

        case is Address:
            if let items = Manifest.shared.entries(for: .eventLocationInvolvementType)?.rawValues() {
                return items
            }

            fatalError("Manifest items not found for \(ManifestCollection.eventLocationInvolvementType.rawValue)")

        default:
            fatalError("Unrecognised entity type found when fetching event involvements.")
        }
    }
}

extension IncidentsManager {
    static var managerWithPrepopulatedBuilders: IncidentsManager {
        let manager = IncidentsManager()

        for incidentType in IncidentType.allIncidentTypes() {
            switch incidentType {
            case .trafficInfringement:
                manager.add(TrafficInfringementIncidentBuilder(), for: .trafficInfringement)
            case .interceptReport:
                manager.add(InterceptReportIncidentBuilder(), for: .interceptReport)
            case .domesticViolence:
                manager.add(DomesticViolenceIncidentBuilder(), for: .domesticViolence)
            default:
                fatalError("No builder added for incident type \"\(incidentType.rawValue)\"")
            }
        }

        return manager
    }
}
