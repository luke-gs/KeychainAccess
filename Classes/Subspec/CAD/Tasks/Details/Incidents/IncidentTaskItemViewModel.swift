//
//  IncidentTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol TaskItemViewModelDelegate: class {
    func presentStatusSelector(viewController: UIViewController)
}

open class IncidentTaskItemViewModel: TaskItemViewModel {

    open weak var delegate: TaskItemViewModelDelegate?

    open private(set) var incident: SyncDetailsIncident?
    open private(set) var resource: SyncDetailsResource?

    public init(incidentNumber: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?) {
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName)

        self.navTitle =  NSLocalizedString("Incident details", comment: "")
        self.compactNavTitle = itemName

        self.viewModels = [
            IncidentOverviewViewModel(incidentNumber: incidentNumber),
            IncidentAssociationsViewModel(incidentNumber: incidentNumber),
            IncidentResourcesViewModel(incidentNumber: incidentNumber),
            IncidentNarrativeViewModel(incidentNumber: incidentNumber),
        ]
    }

    public convenience init(incident: SyncDetailsIncident, resource: SyncDetailsResource?) {
        self.init(incidentNumber: incident.identifier,
                  iconImage: resource?.status.icon ?? ResourceStatus.unavailable.icon,
                  iconTintColor: resource?.status.iconColors.icon ?? .white,
                  color: resource?.status.iconColors.background,
                  statusText: resource?.status.title ?? incident.status.rawValue,
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
            iconImage = resource?.status.icon ?? ResourceStatus.unavailable.icon
            iconTintColor = resource?.status.iconColors.icon ?? .white
            color = resource?.status.iconColors.background
            statusText = resource?.status.title ?? incident.status.rawValue
            itemName = [incident.type, incident.resourceCountString].joined()

            viewModels.forEach {
                $0.reloadFromModel()
            }
        }
    }

    override open func didTapTaskStatus() {
        if allowChangeResourceStatus() {
            let callsignStatus = CADStateManager.shared.currentResource?.status ?? .unavailable
            let sections = [CADFormCollectionSectionViewModel(
                title: "",
                items: [
                    ManageCallsignStatusItemViewModel(.proceeding),
                    ManageCallsignStatusItemViewModel(.atIncident),
                    ManageCallsignStatusItemViewModel(.finalise),
                    ManageCallsignStatusItemViewModel(.inquiries2) ])
            ]
            let viewModel = CallsignStatusViewModel(sections: sections, selectedStatus: callsignStatus, incident: incident)
            viewModel.showsCompactHorizontal = false
            let viewController = viewModel.createViewController()
            
            delegate?.presentStatusSelector(viewController: viewController)
        }
    }

    open func allowChangeResourceStatus() -> Bool {
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
