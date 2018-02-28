//
//  PatrolOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class PatrolOverviewViewModel: TaskDetailsOverviewViewModel {
    
    override open func mapViewModel() -> TasksMapViewModel {
        return PatrolOverviewMapViewModel(patrolNumber: identifier)
    }
    
    override open func loadData() {
        guard let patrol = CADStateManager.shared.patrolsById[identifier] else { return }
        
        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: "Patrol Location",
                                                                              value: patrol.location?.fullAddress,
                                                                              width: .column(1),
                                                                              accessory: ItemAccessory(style: .overflow, tintColor: .secondaryGray)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Patrol number",
                                                                              value: patrol.identifier,
                                                                              width: .column(3)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Type",
                                                                              value: patrol.type,
                                                                              width: .column(3)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Subtype",
                                                                              value: patrol.subtype,
                                                                              width: .column(3)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Created",
                                                                              value: patrol.createdAtString ?? "",
                                                                              width: .column(3)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Last Updated",
                                                                              value: patrol.lastUpdated?.elapsedTimeIntervalForHuman() ?? "",
                                                                              width: .column(3)),
                                                ]),
            
            
            CADFormCollectionSectionViewModel(title: "Patrol Details",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: nil,
                                                                              value: patrol.details,
                                                                              width: .column(1)),
                                                ])
        ]
    }
    
    /// The title to use in the navigation bar
    open override func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
    
}
