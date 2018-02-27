//
//  InfringementIncidentBuilder.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 27/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

public class InfringementIncidentBuilder: IncidentBuilding {

    public func createIncident(for type: IncidentType, in event: Event)
        -> (incident: Incident, displayable: IncidentListDisplayable)
    {
        let incident = Incident(event: event, type: type)

        // Add reports here
        incident.add(report: DefaultDateTimeReport(event: event))

        let displayable = IncidentListDisplayable(title: type.rawValue,
                                                  subtitle: "Not yet started",
                                                  icon: AssetManager.shared.image(forKey: AssetManager.ImageKey.event))
        displayable.incidentId = incident.id
        return (incident: incident, displayable: displayable)
    }

    public init() { }
}
