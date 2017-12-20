//
//  TasksListResourceViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 19/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksListResourceViewModel: TasksListItemViewModel {

    open let resourceImage: UIImage?
    open let statusImage: UIImage?
    open let informationRows: [TasksListInformationRowViewModel]?
    open let incidentViewModel: TasksListIncidentViewModel?
    
    public var hasInformationRows: Bool {
        return informationRows?.count ?? 0 > 0
    }
    
    init(identifier: String, title: String, subtitle: String, caption: String, resourceImage: UIImage?, statusImage: UIImage?,
         informationRows: [TasksListInformationRowViewModel]?, incidentViewModel: TasksListIncidentViewModel?)
    {
        self.resourceImage = resourceImage
        self.statusImage = statusImage
        self.informationRows = informationRows
        self.incidentViewModel = incidentViewModel
        
        super.init(identifier: identifier, title: title, subtitle: subtitle, caption: caption)
    }

    public convenience init(resource: SyncDetailsResource, incident: SyncDetailsIncident?) {
        var incidentViewModel: TasksListIncidentViewModel? = nil
        if let incident = incident {
            incidentViewModel = TasksListIncidentViewModel(incident: incident, hasUpdates: false)
        }
        
        let iconImage = resource.type.icon?
            .withCircleBackground(tintColor: resource.status.iconColors.icon,
                                  circleColor: resource.status.iconColors.background,
                                  style: .auto(padding: CGSize(width: 24, height: 24),
                                               shrinkImage: false),
                                  shouldCenterImage: true)
        
        let officers = CADStateManager.shared.officersForResource(callsign: resource.callsign).map {
            $0.displayName
        }.joined(separator: ", ")
        
        let infoViewModels = [
            TasksListInformationRowViewModel(image: AssetManager.shared.image(forKey: .resourceGeneral), title: officers),
            TasksListInformationRowViewModel(image: AssetManager.shared.image(forKey: .info),
                                             title: resource.equipmentListString(separator: ", ")?.ifNotEmpty() ?? "–" ),
        ]
        
        self.init(
            identifier: resource.callsign,
            title: [resource.callsign, resource.officerCountString].joined(),
            subtitle: resource.location?.suburb ?? "–",
            caption: resource.status.title,
            resourceImage: iconImage,
            statusImage: resource.status.icon,
            informationRows: infoViewModels,
            incidentViewModel: incidentViewModel
        )
    }
    
}
