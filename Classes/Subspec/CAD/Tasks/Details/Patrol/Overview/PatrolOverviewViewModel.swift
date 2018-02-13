//
//  PatrolOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class PatrolOverviewViewModel: TaskDetailsViewModel {
    
    /// The identifier for this patrol
    open let patrolNumber: String
    
    open weak var delegate: CADFormCollectionViewModelDelegate?
    
    public init(patrolNumber: String) {
        self.patrolNumber = patrolNumber
        loadData()
    }
    
    open func createViewController() -> TaskDetailsViewController {
        return PatrolOverviewViewController(viewModel: self)
    }
    
    open func reloadFromModel() {
        loadData()
    }
    
    open func createFormViewController() -> FormBuilderViewController {
        return PatrolOverviewFormViewController(viewModel: self)
    }
    
    /// Lazy var for creating view model content
    open var sections: [CADFormCollectionSectionViewModel<IncidentOverviewItemViewModel>] = [] {
        didSet {
            delegate?.sectionsUpdated()
        }
    }
    
    open func loadData() {
        guard let patrol = CADStateManager.shared.patrolsById[patrolNumber] else { return }
        
        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
                                                IncidentOverviewItemViewModel(title: "Patrol Location",
                                                                              value: patrol.location.fullAddress,
                                                                              width: .column(1),
                                                                              accessory: ItemAccessory(style: .overflow, tintColor: .secondaryGray)),
                                                
                                                IncidentOverviewItemViewModel(title: "Patrol number",
                                                                              value: patrol.identifier,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Type",
                                                                              value: patrol.type,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Subtype",
                                                                              value: patrol.subtype,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Created",
                                                                              value: patrol.createdAtString,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Last Updated",
                                                                              value: patrol.lastUpdated.elapsedTimeIntervalForHuman(),
                                                                              width: .column(3)),
                                                ]),
            
            
            CADFormCollectionSectionViewModel(title: "Patrol Details",
                                              items: [
                                                IncidentOverviewItemViewModel(title: nil,
                                                                              value: patrol.details,
                                                                              width: .column(1)),
                                                ])
        ]
    }
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
    
}
