//
//  InterceptReportIncidentBuilder.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

public class InterceptReportIncidentBuilder: IncidentBuilding {

    public func createIncident(for type: IncidentType, in event: Event) -> Incident {
        let incident = Incident(event: event, type: type)

        // Add reports here
        incident.add(report: DefaultEntitiesListReport(event: event, incident: incident))
        incident.add(report: InterceptReportGeneralDetailsReport(event: event, incident: incident))

        return incident
    }

    public func displayable(for incident: Incident) -> IncidentListDisplayable {
        return IncidentListDisplayable(
            id: incident.id,
            title: incident.title,
            subtitle: "Not yet started",
            iconKey: AssetManager.ImageKey.event)
    }

    public init() {}
}
