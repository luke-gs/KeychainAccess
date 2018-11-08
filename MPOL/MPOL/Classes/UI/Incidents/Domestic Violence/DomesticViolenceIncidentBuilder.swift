//
//  DomesticViolenceIncidentBuilder.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

public class DomesticViolenceIncidentBuilder: IncidentBuilding {

    public func createIncident(for type: IncidentType, in event: Event) -> (incident: Incident, displayable: IncidentListDisplayable) {
        let incident = Incident(event: event, type: type)

        // Add reports here
        incident.add(report: DefaultEntitiesListReport(event: event, incident: incident))
        incident.add(report: DomesticViolencePropertyReport(event: event, incident: incident))
        incident.add(report: DomesticViolenceGeneralDetailsReport(event: event, incident: incident))

        let displayable = IncidentListDisplayable(title: type.rawValue,
                                                  subtitle: "Not yet started",
                                                  iconKey: AssetManager.ImageKey.event)
        displayable.incidentId = incident.id
        return (incident: incident, displayable: displayable)
    }

    public init() {}
}
