//
//  IncidentResourcesViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentResourcesViewModel: CADFormCollectionViewModel<IncidentResourceItemViewModel>, TaskDetailsViewModel {

    /// The identifier for this incident
    open let incidentNumber: String
    
    public init(incidentNumber: String) {
        self.incidentNumber = incidentNumber
        super.init()
        loadData()
    }
    
    open func loadData() {
        guard CADStateManager.shared.incidentsById[incidentNumber] != nil else { return }
        sections = []
        
        let resourceViewModels = CADStateManager.shared.resourcesForIncident(incidentNumber: incidentNumber)
            .map { resource -> CADFormCollectionSectionViewModel<IncidentResourceItemViewModel> in
                let officerViewModels = CADStateManager.shared.officersForResource(callsign: resource.callsign).map { officer in
                    return ResourceOfficerViewModel(title: officer.firstLastName,
                                                    subtitle: [officer.rank, officer.payrollIdDisplayString, officer.licenceTypeId]
                                                        .removeNils().joined(separator: "  •  "),
                                                    badgeText: resource.driver == officer.payrollId ? "DRIVER": nil,
                                                    commsEnabled: (false, officer.contactNumber != nil))
                }
                
                let resourceViewModel = IncidentResourceItemViewModel(title: [resource.callsign, resource.officerCountString]
                                                                             .removeNils().joined(separator: " "),
                                                                      subtitle: resource.status.title,
                                                                      officers: officerViewModels)
                
                return CADFormCollectionSectionViewModel(title: resource.callsign, items: [resourceViewModel])
        }
        
        sections = resourceViewModels
    }
    
    public func createViewController() -> UIViewController {
        return IncidentResourcesViewController(viewModel: self)
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Resources", comment: "Resources sidebar title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Resources Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }
}
