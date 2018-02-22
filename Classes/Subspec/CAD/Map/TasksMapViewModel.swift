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
        let currentListItem = CADClientModelTypes.taskListSources.allCases[selectedListIndex]
        
        var annotations: [TaskAnnotation] = []
        for sourceType in CADClientModelTypes.taskListSources.allCases {
            annotations += sourceType.filteredAnnotations(filterViewModel: filter, selectedSource: currentListItem)
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
                                             iconTintColor: resource.status.iconColors.icon,
                                             color: resource.status.iconColors.background,
                                             statusText: resource.status.title,
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
