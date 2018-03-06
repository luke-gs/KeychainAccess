//
//  BroadcastOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class BroadcastOverviewViewModel: TaskDetailsOverviewViewModel {
    
    override open func loadData() {
        guard let broadcast = CADStateManager.shared.broadcastsById[identifier] else { return }
        
        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: "Broadcast location",
                                                                              value: broadcast.location?.suburb,
                                                                              width: .column(1),
                                                                              accessory: ItemAccessory(style: .overflow, tintColor: .secondaryGray)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Broadcast number",
                                                                              value: broadcast.identifier,
                                                                              width: .column(3)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Type",
                                                                              value: broadcast.type.title,
                                                                              width: .column(2)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Created",
                                                                              value: broadcast.createdAtString ?? "",
                                                                              width: .column(3)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Last Updated",
                                                                              value: broadcast.lastUpdated?.elapsedTimeIntervalForHuman() ?? "",
                                                                              width: .column(2)),
                                                ]),
            
            
            CADFormCollectionSectionViewModel(title: "Broadcast Details",
                                              items: [
                                                TaskDetailsOverviewItemViewModel(title: nil,
                                                                              value: broadcast.details,
                                                                              width: .column(1)),
                                                ])
        ]
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
    
}
