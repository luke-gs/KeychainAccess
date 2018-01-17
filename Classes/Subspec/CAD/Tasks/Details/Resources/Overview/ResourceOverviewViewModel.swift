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
    
    open weak var delegate: CADFormCollectionViewModelDelegate?
    
    public init(callsign: String) {
        self.callsign = callsign
        loadData()
    }
    
    open func createViewController() -> TaskDetailsViewController {
        return ResourceOverviewViewController(viewModel: self)
    }
    
    open func reloadFromModel() {
        loadData()
    }

    open func createFormViewController() -> FormBuilderViewController {
        return ResourceOverviewFormViewController(viewModel: self)
    }
    
    /// Lazy var for creating view model content
    open var sections: [CADFormCollectionSectionViewModel<IncidentOverviewItemViewModel>] = [] {
        didSet {
            delegate?.sectionsUpdated()
        }
    }
    
    open var currentIncidentViewModel: TasksListIncidentViewModel? {
        guard let resource = CADStateManager.shared.resourcesById[callsign],
            let incidentNumber = resource.currentIncident,
            let incident = CADStateManager.shared.incidentsById[incidentNumber]
        else {
            return nil
        }
        return TasksListIncidentViewModel(incident: incident, showsDescription: false, showsResources: false, hasUpdates: false)
    }
    
    open func loadData() {
        guard let resource = CADStateManager.shared.resourcesById[callsign] else { return }
        
        sections = [
            CADFormCollectionSectionViewModel(title: NSLocalizedString("Call Sign Details", comment: ""),
                                              items: [
                                                IncidentOverviewItemViewModel(title: NSLocalizedString("Type", comment: ""),
                                                                              value: resource.type.rawValue,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: NSLocalizedString("Station", comment: ""),
                                                                              value: resource.station,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: NSLocalizedString("Fleet ID", comment: ""),
                                                                              value: resource.serial,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: NSLocalizedString("Vehicle Category", comment: ""),
                                                                              value: resource.vehicleCategory,
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: NSLocalizedString("Equipment", comment: ""),
                                                                              value: resource.equipmentListString(separator: ", "),
                                                                              width: .column(2)),
                                                
                                                IncidentOverviewItemViewModel(title: NSLocalizedString("Remarks", comment: ""),
                                                                              value: resource.remarks ?? "–",
                                                                              width: .column(2)),
                                                ]),
            
            CADFormCollectionSectionViewModel(title: NSLocalizedString("Shift Details", comment: ""),
                                              items: [
                                                IncidentOverviewItemViewModel(title: NSLocalizedString("Start Time", comment: ""),
                                                                              value: resource.shiftStartString,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: NSLocalizedString("Estimated End Time", comment: ""),
                                                                              value: resource.shiftEndString,
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: NSLocalizedString("Duration", comment: ""),
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

