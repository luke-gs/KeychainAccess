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

    open static var infoIcon: UIImage? = {
        // Use larger version of standard info icon for sidebar/glass view
        let infoIcon = AssetManager.shared.image(forKey: .info)
        return infoIcon?.resizeImageWith(newSize: CGSize(width: 32, height: 32), renderMode: .alwaysTemplate)
    }()

    /// The optional summary loaded during construction
    open var incidentSummary: CADIncidentType?

    // MARK: - Init

    public init(incidentNumber: String) {
        super.init(taskItemIdentifier: incidentNumber)

        self.navTitle = NSLocalizedString("Incident details", comment: "")
        self.subtitleText = "#\(incidentNumber)"

        // Load the summary if available
        incidentSummary = CADStateManager.shared.incidentsById[incidentNumber]
        if incidentSummary != nil {
            reloadFromModel()
        }
    }

    // MARK: - Generated properties

    /// Return the loaded incident details
    open var incidentDetails: CADIncidentType? {
        return taskItemDetails as? CADIncidentType
    }

    /// Return the loaded incident details or the summary if available
    open var incidentDetailsOrSummary: CADIncidentType? {
        return incidentDetails ?? incidentSummary
    }

    /// Our callsign resource if assigned to incident
    open var resourceIfAssigned: CADResourceType? {
        let resources = CADStateManager.shared.resourcesForIncident(incidentNumber: taskItemIdentifier)
        return resources.filter { $0 == CADStateManager.shared.currentResource }.first
    }

    // MARK: - Methods

    open override func createViewModels() -> [TaskDetailsViewModel] {
        return [IncidentOverviewViewModel(),
                IncidentAssociationsViewModel(),
                IncidentResourcesViewModel(),
                IncidentNarrativeViewModel()]
    }

    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    open override func loadTaskItem() -> Promise<CADTaskListItemModelType> {
        return CADStateManager.shared.getIncidentDetails(identifier: taskItemIdentifier).map { [weak self] incident in
            self?.updateGlassBar()
            return incident
        }
    }

    override open func reloadFromModel() {
        guard let incident = self.incidentDetailsOrSummary else { return }
        let resource = self.resourceIfAssigned

        iconImage = resource?.status.icon ?? IncidentTaskItemViewModel.infoIcon
        iconTintColor = resource?.status.iconColors.icon ?? .white
        color = resource?.status.iconColors.background
        statusText = resource?.status.title ?? incident.status.title
        itemName = [incident.type, incident.resourceCountString].joined()
        compactNavTitle = itemName
        compactTitle = statusText
        compactSubtitle = subtitleText

        viewModels.forEach {
            $0.reloadFromModel(incident)
        }
        updateGlassBar()
        super.reloadFromModel()
    }

    open func updateGlassBar() {
        if let incident = incidentSummary, allowChangeResourceStatus() {
            // Only show compact glass bar if we can change status
            showCompactGlassBar = true

            // Customise text based on current state
            if resourceIfAssigned != nil {
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
            delegate?.present(TaskItemScreen.resourceStatus(initialStatus: resourceIfAssigned?.status, incident: incidentDetailsOrSummary))
        }
    }

    open override func allowChangeResourceStatus() -> Bool {
        // If this task is the current incident for our booked on resource,
        // or we have no current incident, allow changing resource state
        // ... but only if incident is within our patrol group
        let incident = self.incidentDetailsOrSummary
        if CADStateManager.shared.lastBookOn != nil && incident?.patrolGroup == CADStateManager.shared.patrolGroup {
            let currentIncidentId = CADStateManager.shared.currentIncident?.incidentNumber
            if let incident = incident, (incident.incidentNumber == currentIncidentId || currentIncidentId == nil) {
                return true
            }
        }
        return false
    }
    
}
