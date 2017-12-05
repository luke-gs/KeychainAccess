//
//  TasksMapViewModel.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

open class TasksMapViewModel {

    public weak var splitViewModel: TasksSplitViewModel?
    public weak var delegate: TasksMapViewModelDelegate?

    // MARK: - Filter

    // TODO: Set from split view table
    var priorityAnnotationType = ResourceAnnotationView.self
    
    // MARK: - Init
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadTasks), name: .CADSyncChanged, object: nil)
    }
    
    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        return TasksMapViewController(viewModel: self)
    }
    
    // MARK: - Annotations
    
    /// Loads the tasks from the sync and filters them
    @objc public func loadTasks() {
        guard let splitViewModel = self.splitViewModel else { return }
        
        let filter = splitViewModel.filterViewModel
        let selectedListIndex = splitViewModel.listContainerViewModel.selectedSourceIndex
        let currentListItem = TaskListType(rawValue: selectedListIndex)
        
        var annotations: [TaskAnnotation] = []
        
        if filter.showIncidents || currentListItem == .incident {
            annotations += taskAnnotations(for: splitViewModel.filteredIncidents)
        }
        
        if filter.showPatrol || currentListItem == .patrol {
            // TODO: Get patrol from sync
        }
        
        if filter.showBroadcasts || currentListItem == .broadcast {
            // TODO: Get broadcasts from sync
        }

        if filter.showResources || currentListItem == .resource {
            annotations += taskAnnotations(for: splitViewModel.filteredResources)
        }
        
        filteredAnnotations = annotations
    }

    /// Annotations matching the current filter
    var filteredAnnotations: [TaskAnnotation] = [] {
        didSet {
            if oldValue != filteredAnnotations {
                delegate?.viewModelStateChanged()
            }
        }
    }
    
    /// Creates a view model from an annotation
    public func viewModel(for annotation: TaskAnnotation?) -> TaskItemViewModel? {
        if let annotation = annotation as? ResourceAnnotation {
            guard let resource = CADStateManager.shared.resourcesById[annotation.identifier] else { return nil }
            
            return ResourceTaskItemViewModel(callsign: resource.callsign,
                                             iconImage: annotation.icon,
                                             iconTintColor: resource.status.iconColors.icon,
                                             color: resource.status.iconColors.background,
                                             statusText: resource.status.title,
                                             itemName: [annotation.title, annotation.subtitle].removeNils().joined(separator: " "),
                                             lastUpdated: "Updated 2 mins ago")  // FIXME: Get real text
        } else if let annotation = annotation as? IncidentAnnotation {
            guard let incident = CADStateManager.shared.incidentsById[annotation.identifier],
                let resource = CADStateManager.shared.resourcesForIncident(incidentNumber: incident.identifier).first
            else { return nil }
            return IncidentTaskItemViewModel(incident: incident, resource: resource)
        }
        
        return nil
    }
    
    // MARK: - Mapping
    
    /// Maps incident view models to task annotations
    func taskAnnotations(for incidents: [SyncDetailsIncident]) -> [TaskAnnotation] {
        return incidents.map { incident in
            return IncidentAnnotation(identifier: incident.identifier,
                                      coordinate: incident.coordinate,
                                      title: incident.type,
                                      subtitle: incident.resourceCountString,
                                      badgeText: incident.grade.rawValue,
                                      badgeTextColor: incident.grade.badgeColors.text,
                                      badgeFillColor: incident.grade.badgeColors.fill,
                                      badgeBorderColor: incident.grade.badgeColors.border,
                                      usesDarkBackground: incident.status == .unresourced)
        }
    }
    
    /// Maps resource view models to task annotations
    func taskAnnotations(for resources: [SyncDetailsResource]) -> [TaskAnnotation] {
        return resources.map { resource in
            return ResourceAnnotation(identifier: resource.callsign,
                                      coordinate: resource.coordinate,
                                      title: resource.callsign,
                                      subtitle: resource.officerCountString,
                                      icon: resource.type.icon,
                                      iconBackgroundColor: resource.status.iconColors.background,
                                      iconTintColor: resource.status.iconColors.icon,
                                      pulsing: false) // TODO: Get duress state
        }
    }
 
    func isAnnotationViewDisplayedOnTop(_ annotationView: MKAnnotationView) -> Bool {
        return type(of: annotationView) == priorityAnnotationType
    }
}

public protocol TasksMapViewModelDelegate: class {
    /// Called when some data or state has changed
    func viewModelStateChanged()
    
    /// Tells the map to zoom to the user location
    func zoomToUserLocation()
}
