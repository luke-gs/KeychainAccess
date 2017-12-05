//
//  IncidentTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentTaskItemViewModel: TaskItemViewModel {
    
    public init(incidentNumber: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?, lastUpdated: String?) {
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName, lastUpdated: lastUpdated)
        
        self.viewModels = [
            IncidentOverviewViewModel(incidentNumber: incidentNumber),
            IncidentAssociationsViewModel(incidentNumber: incidentNumber),
            IncidentResourcesViewModel(incidentNumber: incidentNumber),
            IncidentNarrativeViewModel(incidentNumber: incidentNumber),
        ]
    }

    public convenience init(incident: SyncDetailsIncident, resource: SyncDetailsResource?) {
        self.init(incidentNumber: incident.identifier,
                  iconImage: resource?.status.icon ?? ResourceStatus.unavailable.icon,
                  iconTintColor: resource?.status.iconColors.icon ?? .white,
                  color: resource?.status.iconColors.background,
                  statusText: resource?.status.title ?? incident.status.rawValue,
                  itemName: [incident.type, incident.resourceCountString].joined(),
                  lastUpdated: incident.lastUpdated.elapsedTimeIntervalForHuman())
    }
}
