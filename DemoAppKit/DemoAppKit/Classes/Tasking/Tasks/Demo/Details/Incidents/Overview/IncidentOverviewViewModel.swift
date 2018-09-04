//
//  IncidentOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class IncidentOverviewViewModel: TaskDetailsOverviewViewModel {

    public override init() {
        super.init()
        mapViewModel = IncidentOverviewMapViewModel()
    }

    open override func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let incident = model as? CADIncidentType else { return }
        (mapViewModel as? IncidentOverviewMapViewModel)?.reloadFromModel(incident)
        
        location = incident.location

        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: "Incident Location",
                                                                              value: location?.displayText,
                                                                              width: .column(1),
                                                                              selectAction: { [unowned self] cell in
                                                                                self.presentAddressPopover(from: cell)
                                                                              },
                                                                              accessory: ItemAccessory(style: .overflow, tintColor: .secondaryGray)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Priority",
                                                                              value: incident.grade.title,
                                                                              width: .column(4)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Primary Code",
                                                                              value: incident.incidentNumber,
                                                                              width: .column(4)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Secondary Code",
                                                                              value: incident.secondaryCode,
                                                                              width: .column(4)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Patrol Area",
                                                                              value: incident.patrolGroup,
                                                                              width: .column(4)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Created",
                                                                              value: incident.createdAtString ?? "Unknown",
                                                                              width: .column(4)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Last Updated",
                                                                              value: incident.lastUpdated?.elapsedTimeIntervalForHuman() ?? incident.createdAtString ?? "Unknown",
                                                                              width: .column(4)),
            ]),
            
            CADFormCollectionSectionViewModel(title: "Informant Details",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: "Name",
                                                                              value: incident.informant?.fullName ?? "Unknown",
                                                                              width: .column(3)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Contact Number",
                                                                              value: incident.informant?.primaryPhone ?? "Unknown",
                                                                              width: .column(3)),
            ]),
            
            CADFormCollectionSectionViewModel(title: "Incident Details",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: nil,
                                                                              value: incident.details,
                                                                              width: .column(1)),
            ])
        ]
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }

}

