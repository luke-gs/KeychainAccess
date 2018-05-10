//
//  IncidentTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class IncidentTaskItemViewModel: TaskItemViewModel {

    open private(set) var incident: CADIncidentType?
    open private(set) var resource: CADResourceType?

    public init(incidentNumber: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?) {
        let captionText = "#\(incidentNumber)"
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName, subtitleText: captionText)

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
        self.init(incidentNumber: incident.incidentNumber,
                  iconImage: resource?.status.icon ?? CADClientModelTypes.resourceStatus.defaultCase.icon,
                  iconTintColor: resource?.status.iconColors.icon ?? .white,
                  color: resource?.status.iconColors.background,
                  statusText: resource?.status.title ?? incident.status.title,
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
        // Reload resource for incident if current incident, or clear
        if incident?.identifier == CADStateManager.shared.currentIncident?.identifier {
            resource = CADStateManager.shared.currentResource
        } else {
            resource = nil
        }

        if let incident = incident {
            iconImage = resource?.status.icon ?? CADClientModelTypes.resourceStatus.defaultCase.icon
            iconTintColor = resource?.status.iconColors.icon ?? .white
            color = resource?.status.iconColors.background
            statusText = resource?.status.title ?? incident.status.title
            itemName = [incident.type, incident.resourceCountString].joined()

            viewModels.forEach {
                $0.reloadFromModel()
            }
        }
    }

    override open func didTapTaskStatus() {
        if allowChangeResourceStatus() {
            delegate?.present(TaskItemScreen.resourceStatus(initialStatus: resource?.status, incident: incident))
        }
    }

    open override func allowChangeResourceStatus() -> Bool {
        // If this task is the current incident for our booked on resource,
        // or we have no current incident, allow changing resource state
        // ... but only if incident is within our patrol group
        if CADStateManager.shared.lastBookOn != nil && incident?.patrolGroup == CADStateManager.shared.patrolGroup {
            let currentIncidentId = CADStateManager.shared.currentIncident?.identifier
            if let incident = incident, (incident.identifier == currentIncidentId || currentIncidentId == nil) {
                return true
            }
        }
        return false
    }
    
    open override func refreshTask() -> Promise<Void> {
        // TODO: Add method to CADStateManager to fetch individual incident
        return Promise<Void>()
    }
}
