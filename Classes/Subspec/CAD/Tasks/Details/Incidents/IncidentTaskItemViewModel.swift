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

    open var incident: CADIncidentType?
    open var resource: CADResourceType?

    open static var infoIcon: UIImage? = {
        // Use larger version of standard info icon for sidebar/glass view
        let infoIcon = AssetManager.shared.image(forKey: .info)
        return infoIcon?.resizeImageWith(newSize: CGSize(width: 32, height: 32), renderMode: .alwaysTemplate)
    }()

    public init(incidentNumber: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?) {
        let captionText = "#\(incidentNumber)"
        super.init(taskItemIdentifier: incidentNumber,
                   iconImage: iconImage,
                   iconTintColor: iconTintColor,
                   color: color,
                   statusText: statusText,
                   itemName: itemName,
                   subtitleText: captionText)
        
        self.navTitle = NSLocalizedString("Incident details", comment: "")
        self.compactNavTitle = itemName

        self.viewModels = [
            IncidentOverviewViewModel(),
            IncidentAssociationsViewModel(),
            IncidentResourcesViewModel(),
            IncidentNarrativeViewModel(),
        ]
    }

    public convenience init(incident: CADIncidentType, resource: CADResourceType?) {
        self.init(incidentNumber: incident.incidentNumber,
                  iconImage: resource?.status.icon ?? IncidentTaskItemViewModel.infoIcon,
                  iconTintColor: resource?.status.iconColors.icon ?? .white,
                  color: resource?.status.iconColors.background,
                  statusText: resource?.status.title ?? incident.status.title,
                  itemName: [incident.type, incident.resourceCountString].joined())
        self.resource = resource
    }

    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    open override func loadTaskItem() -> Promise<CADTaskListItemModelType> {
        incident = CADStateManager.shared.incidentsById[taskItemIdentifier]
        updateGlassBar()
        return Promise<CADTaskListItemModelType>.value(incident!)
    }

    override open func reloadFromModel() {
        // Reload resource for incident if current incident, or clear
        if incident?.incidentNumber == CADStateManager.shared.currentIncident?.incidentNumber {
            resource = CADStateManager.shared.currentResource
        } else {
            resource = nil
        }

        if let incident = incident {
            iconImage = resource?.status.icon ?? IncidentTaskItemViewModel.infoIcon
            iconTintColor = resource?.status.iconColors.icon ?? .white
            color = resource?.status.iconColors.background
            statusText = resource?.status.title ?? incident.status.title
            itemName = [incident.type, incident.resourceCountString].joined()

            viewModels.forEach {
                $0.reloadFromModel(incident)
            }
            updateGlassBar()
        }
        super.reloadFromModel()
    }

    open func updateGlassBar() {
        if let incident = incident, allowChangeResourceStatus() {
            // Only show compact glass bar if we can change status
            showCompactGlassBar = true

            // Customise text based on current state
            if CADStateManager.shared.currentResource == resource {
                compactTitle = statusText
                compactSubtitle = NSLocalizedString("Change status", comment: "")
            } else {
                let resources = CADStateManager.shared.resourcesForIncident(incidentNumber: incident.incidentNumber)
                if resources.count > 0 {
                    compactTitle = NSLocalizedString("Currently Resourced", comment: "")
                } else {
                    compactTitle = NSLocalizedString("Currently Unresourced", comment: "")
                }
                compactSubtitle = NSLocalizedString("Respond to this incident", comment: "")
            }
        } else {
            showCompactGlassBar = false
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
            let currentIncidentId = CADStateManager.shared.currentIncident?.incidentNumber
            if let incident = incident, (incident.incidentNumber == currentIncidentId || currentIncidentId == nil) {
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
