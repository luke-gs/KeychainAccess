//
//  IncidentTypes.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

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
}


