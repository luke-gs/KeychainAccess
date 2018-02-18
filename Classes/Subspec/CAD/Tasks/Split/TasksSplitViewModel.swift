//
//  TasksSplitViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Delegate protocol for updating UI
public protocol TasksSplitViewModelDelegate: PopoverPresenter {
    /// Called when the sections data is updated
    func sectionsUpdated()
}


open class TasksSplitViewModel {

    /// Delegate for UI updates
    open weak var delegate: TasksSplitViewModelDelegate?

    /// Container view model
    public let listContainerViewModel: TasksListContainerViewModel
    public let mapViewModel: TasksMapViewModel
    public let filterViewModel: TaskMapFilterViewModel

    public init(listContainerViewModel: TasksListContainerViewModel, mapViewModel: TasksMapViewModel, filterViewModel: TaskMapFilterViewModel) {
        self.listContainerViewModel = listContainerViewModel
        self.mapViewModel = mapViewModel
        self.filterViewModel = filterViewModel
        
        self.listContainerViewModel.splitViewModel = self
        self.mapViewModel.splitViewModel = self

        // Observe sync changes
        NotificationCenter.default.addObserver(self, selector: #selector(syncChanged), name: .CADSyncChanged, object: nil)
    }

    @objc open func syncChanged() {
        self.delegate?.sectionsUpdated()
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        let vc = TasksSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    /// Create the view controller for the master side of split view
    public func createMasterViewController() -> UIViewController {
        return listContainerViewModel.createViewController()
    }

    /// Create the view controller for the detail side of the split view
    public func createDetailViewController() -> UIViewController {
        return mapViewModel.createViewController()
    }

    /// The title to use in the navigation bar
    public func navTitle() -> String {
        return NSLocalizedString("Tasks", comment: "Tasks navigation title")
    }
    
    /// Title for the master view to be displayed in the segmented control
    public func masterSegmentTitle() -> String {
        return NSLocalizedString("List", comment: "Task list segment title")
    }
    
    /// Title for the detail view to be displayed in the segmented control
    public func detailSegmentTitle() -> String {
        return NSLocalizedString("Map", comment: "Map list segment title")
    }
    
    // MARK: - Filter
    
    /// Shows the map filter popup
    public func presentMapFilter() {
        let viewController = filterViewModel.createViewController(delegate: self)
        delegate?.presentFormSheet(viewController, animated: true)
    }
    
    /// Applies the filter to the map and task list
    public func applyFilter() {
        delegate?.dismiss(animated: true, completion: nil)
        mapViewModel.loadTasks()
        listContainerViewModel.updateSections()
    }
    
    // MARK: Filter Data
    
    /// Sync incidents filtered
    open var filteredIncidents: [CADIncidentType] {
        let incidents = Array(CADStateManager.shared.incidentsById.values)
        return incidents.filter { incident in
            // TODO: remove this once filtered by CAD system
            if !filterViewModel.showResultsOutsidePatrolArea && incident.patrolGroup != CADStateManager.shared.patrolGroup {
                return false
            }

            let priorityFilter = filterViewModel.priorities.contains(where: { $0 == incident.grade })
            let resourcedFilter = filterViewModel.resourcedIncidents.contains(where: { $0 == incident.statusType })
            
            // If status is not in filter options always show
            // TODO: move to client kit
            let isOther = incident.statusType.rawValue != "Resourced" && incident.statusType.rawValue != "Unresourced"
            let isCurrent = incident.statusType == CADClientModelTypes.incidentStatus.currentCase
            
            var hasResourceInDuress: Bool = false
            
            for resource in CADStateManager.shared.resourcesForIncident(incidentNumber: incident.identifier) {
                if resource.statusType.isDuress {
                    hasResourceInDuress = true
                    break
                }
            }
            
            return isCurrent || hasResourceInDuress || (priorityFilter && (resourcedFilter || isOther))
        }
    }
    
    /// Sync patrols filtered
    open var filteredPatrols: [CADPatrolType] {
        let patrols = Array(CADStateManager.shared.patrolsById.values)
        return patrols.filter { patrol in
            // TODO: remove this once filtered by CAD system
            if !filterViewModel.showResultsOutsidePatrolArea && patrol.patrolGroup != CADStateManager.shared.patrolGroup {
                return false
            }
            
            return true
        }
    }
    
    /// Sync broadcasts filtered
    open var filteredBroadcasts: [CADBroadcastType] {
        let broadcasts = Array(CADStateManager.shared.broadcastsById.values)
        return broadcasts
    }
    
    /// Sync incidents filtered
    open var filteredResources: [CADResourceType] {
        let resources = Array(CADStateManager.shared.resourcesById.values)
        return resources.filter { resource in
            // TODO: remove this once filtered by CAD system
            if !filterViewModel.showResultsOutsidePatrolArea && resource.patrolGroup != CADStateManager.shared.patrolGroup {
                return false
            }

            // Ignore off duty resources
            guard resource.statusType != CADClientModelTypes.resourceStatus.offDutyCase else { return false }

            let isTasked = resource.currentIncident != nil
            let isDuress = resource.statusType.isDuress

            return filterViewModel.taskedResources.tasked && isTasked ||
                filterViewModel.taskedResources.untasked && !isTasked ||
                isDuress
        }
    }
}


extension TasksSplitViewModel: MapFilterViewControllerDelegate {
    public func didSelectDone() {
        applyFilter()
    }
}
