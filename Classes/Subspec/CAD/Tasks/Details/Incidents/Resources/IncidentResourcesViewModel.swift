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
    
    open func createViewController() -> TaskDetailsViewController {
        return IncidentResourcesViewController(viewModel: self)
    }

    open func reloadFromModel() {
        loadData()
    }

    open func loadData() {
        guard CADStateManager.shared.incidentsById[incidentNumber] != nil else { return }

        let resourceViewModels = CADStateManager.shared.resourcesForIncident(incidentNumber: incidentNumber)
            .map { resource -> CADFormCollectionSectionViewModel<IncidentResourceItemViewModel> in
                let officerViewModels = CADStateManager.shared.officersForResource(callsign: resource.callsign).map { officer in
                    return ResourceOfficerViewModel(officer: officer, resource: resource)
                }
                
                let (tintColor, circleColor) = resource.statusType.iconColors
                let iconImage = resource.type.icon?
                    .withCircleBackground(tintColor: tintColor,
                                          circleColor: circleColor,
                                          style: .auto(padding: CGSize(width: 24, height: 24),
                                                       shrinkImage: false),
                                          shouldCenterImage: true)
                
                let resourceViewModel = IncidentResourceItemViewModel(callsign: resource.callsign,
                                                                      title: [resource.callsign, resource.officerCountString].joined(),
                                                                      subtitle: resource.statusType.title,
                                                                      icon: iconImage,
                                                                      officers: officerViewModels)
                
                return CADFormCollectionSectionViewModel(title: resource.callsign, items: [resourceViewModel])
        }
        
        sections = resourceViewModels
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
