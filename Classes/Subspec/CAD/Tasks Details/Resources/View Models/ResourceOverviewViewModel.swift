//
//  ResourceOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 5/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOverviewViewModel: TaskDetailsViewModel {

    /// The identifier for this resource
    open let callsign: String
    
    weak var delegate: ResourceOverviewViewModelDelegate?
    
    public init(callsign: String) {
        self.callsign = callsign
        loadSections()
    }
    
    public func createViewController() -> UIViewController {
        return ResourceOverviewViewController(viewModel: self)
    }
    
    open func createFormViewController() -> FormBuilderViewController {
        let viewController = ResourceOverviewFormViewController(viewModel: self)
        delegate = viewController
        return viewController
    }
    
    /// Lazy var for creating view model content
    open var sections: [CADFormCollectionSectionViewModel<IncidentOverviewItemViewModel>] = [] {
        didSet {
            delegate?.didUpdateSections()
        }
    }
    
    open var currentIncidentViewModel: TasksListItemViewModel? {
        guard let resource = CADStateManager.shared.resourcesById[callsign],
            let incidentNumber = resource.currentIncident,
            let incident = CADStateManager.shared.incidentsById[incidentNumber]
        else {
            return nil
        }
        return TasksListItemViewModel(incident: incident)
    }
    
    open func loadSections() {
        guard let resource = CADStateManager.shared.resourcesById[callsign] else { return }
        
        sections = [
            CADFormCollectionSectionViewModel(title: "Callsign Details",
                                              items: [
                                                IncidentOverviewItemViewModel(title: "Type",
                                                                              value: resource.type.rawValue,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Station",
                                                                              value: resource.station,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Vehicle Serial",
                                                                              value: resource.serial,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Vehicle Category",
                                                                              value: resource.vehicleCategory,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Equipment",
                                                                              value: "", // TODO
                                                                              width: .column(2)),
                                                
                                                IncidentOverviewItemViewModel(title: "Remarks",
                                                                              value: resource.remarks ?? "–",
                                                                              width: .column(2)),
                                                ]),
            
            CADFormCollectionSectionViewModel(title: "Shift Details",
                                              items: [
                                                IncidentOverviewItemViewModel(title: "Start Time",
                                                                              value: resource.shiftStartString,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Estimated End Time",
                                                                              value: resource.shiftEndString,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Duration",
                                                                              value: resource.shiftDuration,
                                                                              width: .column(3)),
                                                ]),
        ]
    }
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
    
    open func respondingToHeaderTitle() -> String {
        return NSLocalizedString("Responding To", comment: "").uppercased()
    }
}

public protocol ResourceOverviewViewModelDelegate: class {
    /// Called when the section data changed
    func didUpdateSections()
}
