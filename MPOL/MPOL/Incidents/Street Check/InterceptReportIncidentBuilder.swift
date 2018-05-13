//
//  InterceptReportIncidentBuilder.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

public class InterceptReportIncidentBuilder: IncidentBuilding {

    public func createIncident(for type: IncidentType, in event: Event) -> (incident: Incident, displayable: IncidentListDisplayable) {
        let incident = Incident(event: event, type: type)

        // Add reports here
        incident.add(report: IncidentTestReport(event: event, incident: incident))

        let displayable = IncidentListDisplayable(title: type.rawValue,
                                                  subtitle: "Not yet Started",
                                                  icon: AssetManager.shared.image(forKey: AssetManager.ImageKey.event))
        displayable.incidentId = incident.id
        return (incident: incident, displayable: displayable)
    }

    public init() {}
}
