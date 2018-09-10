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
        switch self {
            case .interceptReport, .domesticViolence:
                if entity is Person {
                    return ["Respondent", "Aggrieved", "Claimant", "Custody", "Informant", "Interviewed", "Named Person", "Subject", "Witness"]
                }
                if entity is Vehicle {
                    return ["Involved in Offence","Involved in Crash","Damaged", "Towed", "Abandoned", "Defective"]
                }
            case .trafficInfringement:
                if entity is Person {
                    return ["Involved in Offence", "Involved in Crash", "Driver"]
                }
                if entity is Vehicle {
                    return ["Damaged", "Towed", "Abandoned", "Defective", "Used"]
                }
            default:
                break
        }
        fatalError("No Involvements for IncidentType")
    }
}


