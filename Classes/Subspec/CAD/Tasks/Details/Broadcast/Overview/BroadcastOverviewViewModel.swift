//
//  BroadcastOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class BroadcastOverviewViewModel: TaskDetailsOverviewViewModel {
    
    override open func mapViewModel() -> TasksMapViewModel? {
        // Only show map if we have a location
        if let broadcast = CADStateManager.shared.broadcastsById[identifier], broadcast.location?.coordinate != nil {
            return BroadcastOverviewMapViewModel(broadcastNumber: identifier)
        }
        return nil
    }

    override open func loadData() {
        guard let broadcast = CADStateManager.shared.broadcastsById[identifier] else { return }

        let locationItem = broadcast.location?.coordinate != nil ?
            // Show location and accessory for address popover
            TaskDetailsOverviewItemViewModel(title: "Broadcast location",
                                             value: broadcast.location?.displayText,
                                             width: .column(1),
                                             selectAction: { [unowned self] cell in
                                                self.presentAddressPopover(from: cell, for: broadcast)
                                             },
                                             accessory: ItemAccessory(style: .overflow, tintColor: .secondaryGray)) :
            // Just show location
            TaskDetailsOverviewItemViewModel(title: "Broadcast location",
                                             value: broadcast.location?.displayText,
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
    
    /// Present "Directions, Street View, Search" options on address
    open func presentAddressPopover(from cell: CollectionViewFormCell, for broadcast: CADBroadcastType) {
        if let coordinate = broadcast.coordinate {
            delegate?.present(TaskItemScreen.addressLookup(source: cell, coordinate: coordinate))
        }
    }
}
