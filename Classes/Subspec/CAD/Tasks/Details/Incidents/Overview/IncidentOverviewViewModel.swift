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
    
    override open func mapViewModel() -> TasksMapViewModel? {
        return IncidentOverviewMapViewModel(incidentNumber: identifier)
    }
    
    override open func loadData() {
        guard let incident = CADStateManager.shared.incidentsById[identifier] else { return }
        
        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: "Incident Location",
                                                                              value: incident.location?.fullAddress ?? "",
                                                                              width: .column(1),
                                                                              selectAction: { [unowned self] cell in
                                                                                self.presentAddressPopover(from: cell, for: incident)
                                                                              },
                                                                              accessory: ItemAccessory(style: .overflow, tintColor: .secondaryGray)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Priority",
                                                                              value: incident.grade.title,
                                                                              width: .column(4)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Primary Code",
                                                                              value: incident.identifier,
                                                                              width: .column(4)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Secondary Code",
                                                                              value: incident.secondaryCode,
                                                                              width: .column(4)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Patrol Area",
                                                                              value: incident.patrolGroup,
                                                                              width: .column(4)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Created",
                                                                              value: incident.createdAtString ?? "",
                                                                              width: .column(4)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Last Updated",
                                                                              value: incident.lastUpdated?.elapsedTimeIntervalForHuman() ?? "",
                                                                              width: .column(4)),
            ]),
            
            CADFormCollectionSectionViewModel(title: "Informant Details",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: "Name",
                                                                              value: incident.informant?.fullName ?? "",
                                                                              width: .column(3)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Contact Number",
                                                                              value: incident.informant?.primaryPhone ?? "",
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

    /// Present "Directions, Street View, Search" options on address
    open func presentAddressPopover(from cell: CollectionViewFormCell, for incident: CADIncidentType) {
        if let coordinate = incident.coordinate {
            delegate?.present(TaskItemScreen.addressLookup(source: cell, coordinate: coordinate))
        }
    }

}

