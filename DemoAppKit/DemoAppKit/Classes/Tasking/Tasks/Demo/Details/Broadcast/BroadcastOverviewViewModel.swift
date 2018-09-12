//
//  BroadcastOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class BroadcastOverviewViewModel: TaskDetailsOverviewViewModel {

    open var addressText: String?

    open override func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let broadcast = model as? CADBroadcastType else { return }
        
        // Only show map if we have a location
        if broadcast.location?.coordinate != nil {
            let mapViewModel = BroadcastOverviewMapViewModel()
            mapViewModel.reloadFromModel(broadcast)
            self.mapViewModel = mapViewModel
        } else {
            mapViewModel = nil
        }
        
        location = broadcast.location

        let locationItem = broadcast.location?.coordinate != nil ?
            // Show location and accessory for address popover
            TaskDetailsOverviewItemViewModel(title: "Broadcast location",
                                             value: broadcast.location?.displayText?.ifNotEmpty() ?? "Unknown",
                                             width: .column(1),
                                             selectAction: { [unowned self] cell in
                                                self.presentAddressPopover(from: cell)
                                             },
                                             accessory: ItemAccessory(style: .overflow, tintColor: .secondaryGray)) :
            // Just show location
            TaskDetailsOverviewItemViewModel(title: "Broadcast location",
                                             value: addressText?.ifNotEmpty() ?? "Unknown",
                                             width: .column(1))

        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
            locationItem,

                                                TaskDetailsOverviewItemViewModel(title: "Broadcast number",
                                                                              value: broadcast.identifier,
                                                                              width: .column(3)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Type",
                                                                              value: broadcast.type.title,
                                                                              width: .column(2)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Created",
                                                                              value: broadcast.createdAtString ?? "Unknown",
                                                                              width: .column(3)),
                                                
                                                TaskDetailsOverviewItemViewModel(title: "Last Updated",
                                                                              value: broadcast.lastUpdated?.elapsedTimeIntervalForHuman() ?? broadcast.createdAtString ?? "",
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
