//
//  IncidentOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentOverviewViewModel: TaskDetailsViewModel {
    
    /// The identifier for this incident
    open let incidentNumber: String
    
    open weak var delegate: CADFormCollectionViewModelDelegate?
    
    public init(incidentNumber: String) {
        self.incidentNumber = incidentNumber
        loadData()
    }
    
    open func createViewController() -> TaskDetailsViewController {
        return IncidentOverviewViewController(viewModel: self)
    }
    
    open func reloadFromModel() {
        loadData()
    }

    open func createFormViewController() -> FormBuilderViewController {
        return IncidentOverviewFormViewController(viewModel: self)
    }
    
    /// Lazy var for creating view model content
    open var sections: [CADFormCollectionSectionViewModel<IncidentOverviewItemViewModel>] = [] {
        didSet {
            delegate?.sectionsUpdated()
        }
    }
    
    open func loadData() {
        guard let incident = CADStateManager.shared.incidentsById[incidentNumber] else { return }
        
        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
                                                IncidentOverviewItemViewModel(title: "Incident Location",
                                                                              value: incident.location.fullAddress,
                                                                              image: AssetManager.shared.image(forKey: .location),
                                                                              width: .column(1)),
                                                
                                                IncidentOverviewItemViewModel(title: "Priority",
                                                                              value: incident.grade.rawValue,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Primary Code",
                                                                              value: incident.identifier,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Secondary Code",
                                                                              value: incident.secondaryCode,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Patrol Area",
                                                                              value: incident.patrolGroup,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Created",
                                                                              value: incident.createdAtString,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Last Updated",
                                                                              value: incident.lastUpdated.elapsedTimeIntervalForHuman(),
                                                                              width: .column(4)),
            ]),
            
            CADFormCollectionSectionViewModel(title: "Informant Details",
                                              items: [
                                                IncidentOverviewItemViewModel(title: "Name",
                                                                              value: incident.informant?.fullName ?? "",
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Contact Number",
                                                                              value: incident.informant?.primaryPhone ?? "",
                                                                              width: .column(3)),
            ]),
            
            CADFormCollectionSectionViewModel(title: "Incident Details",
                                              items: [
                                                IncidentOverviewItemViewModel(title: nil,
                                                                              value: incident.details,
                                                                              width: .column(1)),
            ])
        ]
    }
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
}

