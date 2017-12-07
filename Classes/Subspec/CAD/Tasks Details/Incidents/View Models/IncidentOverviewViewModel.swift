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
    
    weak var delegate: IncidentOverviewViewModelDelegate?
    
    public init(incidentNumber: String) {
        self.incidentNumber = incidentNumber
        loadSections()
    }
    
    public func createViewController() -> UIViewController {
        return IncidentOverviewViewController(viewModel: self)
    }
    
    open func createFormViewController() -> FormBuilderViewController {
        let viewController = IncidentOverviewFormViewController(viewModel: self)
        delegate = viewController
        return viewController
    }
    
    /// Lazy var for creating view model content
    open var sections: [CADFormCollectionSectionViewModel<IncidentOverviewItemViewModel>] = [] {
        didSet {
            delegate?.didUpdateSections()
        }
    }
    
    open func loadSections() {
        guard let incident = CADStateManager.shared.incidentsById[incidentNumber] else { return }
        
        sections = [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
                                                IncidentOverviewItemViewModel(title: "Incident Location",
                                                                              value: incident.location.fullAddress,
                                                                              image: AssetManager.shared.image(forKey: .location),
                                                                              width: .column(1),
                                                                              selectAction: { [unowned self] cell in
                                                                                self.presentAddressPopover(from: cell, for: incident)
                                                                              }),
                                                
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
    
    /// Present "Directions, Street View, Search" options on address
    open func presentAddressPopover(from cell: CollectionViewFormCell, for incident: SyncDetailsIncident) {
        let actionSheetVC = ActionSheetViewController(buttons: [
            ActionSheetButton(title: "Directions", icon: AssetManager.shared.image(forKey: .route), action: {
                let url = "http://maps.apple.com/"
                print("Something")
            }),
            ActionSheetButton(title: "Street View", icon: AssetManager.shared.image(forKey: .streetView), action: nil),
            ActionSheetButton(title: "Search", icon: AssetManager.shared.image(forKey: .tabBarSearch), action: nil),
        ])
        delegate?.presentPopover(actionSheetVC, sourceView: cell, sourceRect: cell.bounds, animated: true)
    }
}

public protocol IncidentOverviewViewModelDelegate: PopoverPresenter {
    /// Called when the section data changed
    func didUpdateSections()
}

