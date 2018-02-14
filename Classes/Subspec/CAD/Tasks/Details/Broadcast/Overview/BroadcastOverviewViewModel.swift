//
//  BroadcastOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class BroadcastOverviewViewModel: TaskDetailsViewModel {

    /// The identifier for this broadcast
    open let broadcastNumber: String
    
    open weak var delegate: CADFormCollectionViewModelDelegate?
    
    public init(broadcastNumber: String) {
        self.broadcastNumber = broadcastNumber
        loadData()
    }
    
    open func createViewController() -> TaskDetailsViewController {
        return BroadcastOverviewFormViewController(viewModel: self)
    }
    
    open func reloadFromModel() {
        loadData()
    }
    
    
    /// Lazy var for creating view model content
    open var sections: [CADFormCollectionSectionViewModel<IncidentOverviewItemViewModel>] = [] {
        didSet {
            delegate?.sectionsUpdated()
        }
    }
    
    open func loadData() {
        guard let broadcast = CADStateManager.shared.broadcastsById[broadcastNumber] else { return }
        
        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
                                                IncidentOverviewItemViewModel(title: "Broadcast location",
                                                                              value: broadcast.location?.suburb,
                                                                              width: .column(1),
                                                                              accessory: ItemAccessory(style: .overflow, tintColor: .secondaryGray)),
                                                
                                                IncidentOverviewItemViewModel(title: "Broadcast number",
                                                                              value: broadcast.identifier,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Type",
                                                                              value: broadcast.type.rawValue,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: nil,
                                                                              value: nil,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Created",
                                                                              value: broadcast.createdAtString,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Last Updated",
                                                                              value: broadcast.lastUpdated.elapsedTimeIntervalForHuman(),
                                                                              width: .column(3)),
                                                ]),
            
            
            CADFormCollectionSectionViewModel(title: "Broadcast Details",
                                              items: [
                                                IncidentOverviewItemViewModel(title: nil,
                                                                              value: broadcast.details,
                                                                              width: .column(1)),
                                                ])
        ]
    }
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
    
}
