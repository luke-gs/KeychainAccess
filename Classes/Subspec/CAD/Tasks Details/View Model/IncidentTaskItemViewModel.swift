//
//  IncidentTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentTaskItemViewModel: TaskItemViewModel {

    open private(set) var incident: SyncDetailsIncident?

    public init(incidentNumber: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?, lastUpdated: String?) {
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName, lastUpdated: lastUpdated)
        
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
                  itemName: [incident.type, incident.resourceCountString].joined(),
                  lastUpdated: incident.lastUpdated.elapsedTimeIntervalForHuman())
        self.incident = incident
    }

    override open func didTapTaskStatus(presenter: PopoverPresenter) {
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
            let viewModel = CallsignStatusViewModel(sections: sections, selectedStatus: callsignStatus)
            let viewController = viewModel.createViewController()

            // Add done button
            if let dismisser = presenter as? TargetActionDismisser {
                viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: dismisser, action: #selector(dismissAnimated))
            }

            // Manually create form sheet to give custom size
            let nav = PopoverNavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .formSheet
            nav.preferredContentSize = CGSize(width: 540.0, height: 120)

            presenter.present(nav, animated: true, completion: nil)
        }
    }

    open func allowChangeResourceStatus() -> Bool {
        // If this task is the current incident for our booked on resource, allow changing resource state
        if let incident = incident, incident.identifier == CADStateManager.shared.currentIncident?.identifier {
            return true
        }
        return false
    }

    /// Swift compiler complains if this doesn't exist, even though it's never called!
    @objc public func dismissAnimated() {}
}
