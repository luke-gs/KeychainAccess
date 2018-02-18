//
//  IncidentTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentTaskItemViewModel: TaskItemViewModel {

    open private(set) var incident: CADIncidentType?
    open private(set) var resource: CADResourceType?

    public init(incidentNumber: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?) {
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName)

        self.navTitle =  NSLocalizedString("Incident details", comment: "")
        self.compactNavTitle = itemName

        self.viewModels = [
            IncidentOverviewViewModel(identifier: incidentNumber),
            IncidentAssociationsViewModel(incidentNumber: incidentNumber),
            IncidentResourcesViewModel(incidentNumber: incidentNumber),
            IncidentNarrativeViewModel(incidentNumber: incidentNumber),
        ]
    }

    public convenience init(incident: CADIncidentType, resource: CADResourceType?) {
        self.init(incidentNumber: incident.identifier,
                  iconImage: resource?.statusType.icon ?? CADClientModelTypes.resourceStatus.defaultCase.icon,
                  iconTintColor: resource?.statusType.iconColors.icon ?? .white,
                  color: resource?.statusType.iconColors.background,
                  statusText: resource?.statusType.title ?? incident.statusType.title,
                  itemName: [incident.type, incident.resourceCountString].joined())
        self.incident = incident
        self.resource = resource
    }
    
    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    override open func reloadFromModel() {
        // Reload resource for incident if current incident
        if incident?.identifier == CADStateManager.shared.currentIncident?.identifier {
            resource = CADStateManager.shared.currentResource
        }

        if let incident = incident {
            iconImage = resource?.statusType.icon ?? CADClientModelTypes.resourceStatus.defaultCase.icon
            iconTintColor = resource?.statusType.iconColors.icon ?? .white
            color = resource?.statusType.iconColors.background
            statusText = resource?.statusType.title ?? incident.statusType.title
            itemName = [incident.type, incident.resourceCountString].joined()

            viewModels.forEach {
                $0.reloadFromModel()
            }
        }
    }

    override open func didTapTaskStatus() {
        if allowChangeResourceStatus() {
            let callsignStatus = CADStateManager.shared.currentResource?.statusType ?? CADClientModelTypes.resourceStatus.defaultCase
            let incidentItems = CADClientModelTypes.resourceStatus.incidentCases.map {
                return ManageCallsignStatusItemViewModel($0)
            }
            let sections = [CADFormCollectionSectionViewModel(title: "", items: incidentItems)]
            let viewModel = CallsignStatusViewModel(sections: sections, selectedStatus: callsignStatus, incident: incident)
            viewModel.showsCompactHorizontal = false
            let viewController = viewModel.createViewController()
            
            delegate?.presentStatusSelector(viewController: viewController)
        }
    }

    open override func allowChangeResourceStatus() -> Bool {
        // If this task is the current incident for our booked on resource,
        // or we have no current incident, allow changing resource state
        if CADStateManager.shared.lastBookOn != nil {
            let currentIncidentId = CADStateManager.shared.currentIncident?.identifier
            if let incident = incident, (incident.identifier == currentIncidentId || currentIncidentId == nil) {
                return true
            }
        }
        return false
    }
}
