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

    /// The default zoom distance for viewing a single task item
    open var defaultZoomDistance: CLLocationDistance = 100

    public weak var splitViewModel: TasksSplitViewModel?
    public weak var delegate: TasksMapViewModelDelegate?

    // MARK: - Filter

    public var priorityAnnotationType: MKAnnotationView.Type = IncidentAnnotationView.self {
        didSet {
            delegate?.viewModelStateChanged()
        }
    }
    
    // MARK: - Init
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadTasks), name: .CADSyncChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadTasks), name: .CADBookOnChanged, object: nil)
    }
    
    /// Create the view controller for this view model
    public func createViewController() -> MapViewController {
        return TasksMapViewController(viewModel: self, annotationsInitialLoadZoomStyle: (animated: true, includeUserLocation: false))
    }
    
    // MARK: - Annotations
    
    /// Loads the tasks from the sync and filters them
    @objc open func loadTasks() {
        guard let splitViewModel = self.splitViewModel else { return }
        
        let filter = splitViewModel.filterViewModel
        let selectedListIndex = splitViewModel.listContainerViewModel.selectedSourceIndex
        let currentListItem = TaskListType(rawValue: selectedListIndex)
        
        var annotations: [TaskAnnotation] = []
        
        if filter.showIncidents || currentListItem == .incident {
            annotations += taskAnnotations(for: splitViewModel.filteredIncidents)
        }
        
        if filter.showPatrol || currentListItem == .patrol {
            annotations += taskAnnotations(for: splitViewModel.filteredPatrols)
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
    open func viewModel(for annotation: TaskAnnotation?) -> TaskItemViewModel? {
        if let annotation = annotation as? ResourceAnnotation {
            guard let resource = CADStateManager.shared.resourcesById[annotation.identifier] else { return nil }
            
            return ResourceTaskItemViewModel(callsign: resource.callsign,
                                             iconImage: annotation.icon,
                                             iconTintColor: resource.statusType.iconColors.icon,
                                             color: resource.statusType.iconColors.background,
                                             statusText: resource.statusType.title,
                                             itemName: [annotation.title, annotation.subtitle].joined())
        } else if let annotation = annotation as? IncidentAnnotation {
            guard let incident = CADStateManager.shared.incidentsById[annotation.identifier] else { return nil }
            let resource = CADStateManager.shared.resourcesForIncident(incidentNumber: incident.identifier).first
            return IncidentTaskItemViewModel(incident: incident, resource: resource)
        } else if let annotation = annotation as? PatrolAnnotation {
            guard let patrol = CADStateManager.shared.patrolsById[annotation.identifier] else { return nil }
            return PatrolTaskItemViewModel(patrol: patrol)
        }
        
        return nil
    }
    
    /// Whether the specified annotation view can be selected
    open func canSelectAnnotationView(_ view: MKAnnotationView) -> Bool {
        return true
    }
    
    // MARK: - Mapping
    
    /// Maps incident view models to task annotations
    open func taskAnnotations(for incidents: [SyncDetailsIncident]) -> [TaskAnnotation] {
        return incidents.map { incident in
            return IncidentAnnotation(identifier: incident.identifier,
                                      coordinate: incident.coordinate,
                                      title: incident.type,
                                      subtitle: incident.resourceCountString,
                                      badgeText: incident.grade.rawValue,
                                      badgeTextColor: incident.grade.badgeColors.text,
                                      badgeFillColor: incident.grade.badgeColors.fill,
                                      badgeBorderColor: incident.grade.badgeColors.border,
                                      usesDarkBackground: incident.status == .unresourced,
                                      priority: incident.grade)
        }
    }
    
    
    /// Maps patrol view models to task annotations
    open func taskAnnotations(for patrols: [SyncDetailsPatrol]) -> [TaskAnnotation] {
        return patrols.map { patrol in
            return PatrolAnnotation(identifier: patrol.identifier,
                                    coordinate: patrol.coordinate,
                                    title: patrol.type,
                                    subtitle: nil,
                                    usesDarkBackground: patrol.status == .assigned)
        }
    }
    
    /// Maps resource view models to task annotations
    open func taskAnnotations(for resources: [SyncDetailsResource]) -> [TaskAnnotation] {
        return resources.filter{$0.location != nil}.map { resource in
            return ResourceAnnotation(identifier: resource.callsign,
                                      coordinate: resource.coordinate!,
                                      title: resource.callsign,
                                      subtitle: resource.officerCountString,
                                      icon: resource.type.icon,
                                      iconBackgroundColor: resource.statusType.iconColors.background,
                                      iconTintColor: resource.statusType.iconColors.icon,
                                      duress: resource.statusType.isDuress)
        }
    }
 
    open func isAnnotationViewDisplayedOnTop(_ annotationView: MKAnnotationView) -> Bool {
        return type(of: annotationView) == priorityAnnotationType
    }
    
    /// Whether annotations should cluster. `true` by default.
    open func shouldCluster() -> Bool {
        return true
    }
}

public protocol TasksMapViewModelDelegate: class {
    /// Called when some data or state has changed
    func viewModelStateChanged()
    
    /// Tells the map to zoom to the user location
    func zoomToUserLocation()    
}
