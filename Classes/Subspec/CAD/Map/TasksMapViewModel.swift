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
    open var defaultZoomDistance: CLLocationDistance = 150

    public weak var splitViewModel: TasksSplitViewModel?
    public weak var delegate: TasksMapViewModelDelegate?

    // MARK: - Filter

    public var priorityAnnotationType: MKAnnotationView.Type = IncidentAnnotationView.self {
        didSet {
            delegate?.priorityAnnotationChanged()
        }
    }
    
    // MARK: - Init
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadTasks), name: .CADSyncChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadTasks), name: .CADBookOnChanged, object: nil)
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> MapViewController {
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
                delegate?.annotationsChanged()
            }
        }
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
    
    /// Whether the map should allow user interaction. `true` by default
    open func allowsInteraction() -> Bool {
        return true
    }
}

public protocol TasksMapViewModelDelegate: class {

    /// Called when the annotations have changed
    func annotationsChanged()

    /// Called when the priority annotation type has changed
    func priorityAnnotationChanged()
    
    /// Tells the map to zoom to the user location
    func zoomToUserLocation()    
}
