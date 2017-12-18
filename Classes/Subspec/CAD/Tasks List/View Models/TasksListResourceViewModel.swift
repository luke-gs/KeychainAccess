//
//  TasksListResourceViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 19/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksListResourceViewModel: NSObject {
    open let identifier: String
    open let title: String
    open let subtitle: String
    open let caption: String
    open let informationRows: [TasksListInformationRowViewModel]?
    open let incidentViewModel: TasksListIncidentViewModel?
    
    public var hasInformationRows: Bool {
        return informationRows?.count ?? 0 > 0
    }
    
    init(identifier: String, title: String, subtitle: String, caption: String,
         informationRows: [TasksListInformationRowViewModel]?, incidentViewModel: TasksListIncidentViewModel?)
    {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
        self.informationRows = informationRows
        self.incidentViewModel = incidentViewModel
    }

    public convenience init(resource: SyncDetailsResource, incident: SyncDetailsIncident?) {
        var incidentViewModel: TasksListIncidentViewModel? = nil
        if let incident = incident {
            incidentViewModel = TasksListIncidentViewModel(incident: incident, hasUpdates: false)
        }
        self.init(
            identifier: resource.callsign,
            title: [resource.callsign, resource.officerCountString].joined(),
            subtitle: resource.location?.suburb ?? "",
            caption: resource.status.title,
            informationRows: nil, // TODO: Get officer list and equipment list
            incidentViewModel: incidentViewModel
        )
    }
    
}
