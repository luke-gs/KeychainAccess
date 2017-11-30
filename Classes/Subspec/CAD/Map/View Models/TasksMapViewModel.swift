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

    // MARK: - Data Source
    
    private var patrol: [PatrolMapViewModel] = []
    private var broadcast: [BroadcastMapViewModel] = []
    private var resources: [ResourceMapViewModel] = []
    
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
        guard let filter = splitViewModel?.filterViewModel,
              let sync = CADStateManager.shared.lastSync
        else { return }

        var annotations: [TaskAnnotation] = []
        
        let currentListItem: TaskListType?
        if let selectedListIndex = splitViewModel?.listContainerViewModel.selectedSourceIndex {
            currentListItem = TaskListType(rawValue: selectedListIndex)
        } else {
            currentListItem = nil
        }
        
        if filter.showIncidents || currentListItem == .incident {
            
            let filteredIncidents = sync.incidents.filter { incident in
                let priorityFilter = filter.priorities.contains(incident.grade)
                let resourcedFilter = filter.resourcedIncidents.contains(incident.status)

                // If status is not in filter options always show
                let isOther = incident.status != .resourced && incident.status != .unresourced
                
                return isOther || (priorityFilter && resourcedFilter)
            }
            
            annotations += taskAnnotations(for: filteredIncidents)
        }
        
        if filter.showPatrol || currentListItem == .patrol {
            annotations += taskAnnotations(for: patrol)
        }
        
        if filter.showBroadcasts || currentListItem == .broadcast {
            annotations += taskAnnotations(for: broadcast)
        }

        if filter.showResources || currentListItem == .resource {
            let filteredResources = resources.filter { model in
                // TODO: Replace with enum when model classes created
                let taskedFilter = filter.taskedResources.contains(model.status)
                
                // If status is not in filter options always show
                let isOther = model.status != "Tasked" && model.status != "Untasked"
                
                return isOther || taskedFilter
            }
            
            annotations += taskAnnotations(for: filteredResources)
        }
        
        filteredAnnotations = annotations
    }

    /// Annotations matching the current filter
    var filteredAnnotations: [TaskAnnotation] = [] {
        didSet {
            delegate?.viewModelStateChanged()
        }
    }
    
    /// Creates a view model from an annotation
    public func viewModel(for annotation: TaskAnnotation?) -> TaskItemViewModel? {
        if let annotation = annotation as? ResourceAnnotation {
            return ResourceTaskItemViewModel(iconImage: annotation.icon,
                                             iconTintColor: .white,
                                             color: .disabledGray, // TODO: Find out which to use
                                             statusText: annotation.status, // FIXME: Get real text
                                             itemName: "\(annotation.title ?? "") \(annotation.subtitle ?? "")",
                                             lastUpdated: "Updated 2 mins ago")  // FIXME: Get real text
        } else if let annotation = annotation as? IncidentAnnotation {
            return IncidentTaskItemViewModel(iconImage: nil, // TODO: Get image
                                             iconTintColor: .white, // TODO: Get color
                                             color: .disabledGray, // TODO: Get color
                                             statusText: annotation.status, // TODO: Get text
                                             itemName: "\(annotation.title ?? "") \(annotation.subtitle ?? "")", // TODO: Get text
                                             lastUpdated: "Updated 2 mins ago")
        }
        
        return nil
    }
    
    // MARK: - Mapping
    
    /// Maps incident view models to task annotations
    func taskAnnotations(for incidents: [SyncDetailsIncident]) -> [TaskAnnotation] {
        return incidents.map { incident in
            return IncidentAnnotation(identifier: incident.incidentNumber,
                                      coordinate: incident.coordinate,
                                      title: incident.incidentType,
                                      subtitle: incident.resourceCount > 0 ? "(\(incident.resourceCount))" : "",
                                      status: nil, // TODO: Remove this property
                                      iconText: incident.grade.rawValue,
                                      iconColor: incident.grade.color,
                                      iconFilled: incident.grade.filled,
                                      usesDarkBackground: incident.status == .unresourced)
        }
    }
    
    /// Maps incident view models to task annotations
    func taskAnnotations(for patrol: [PatrolMapViewModel]) -> [TaskAnnotation] {
        return patrol.map { model in
            return TaskAnnotation(identifier: model.identifier,
                                  coordinate: model.coordinate,
                                  title: model.title,
                                  subtitle: model.subtitle,
                                  status: nil)
        }
    }
    
    /// Maps incident view models to task annotations
    func taskAnnotations(for broadcasts: [BroadcastMapViewModel]) -> [TaskAnnotation] {
        return broadcasts.map { model in
            return TaskAnnotation(identifier: model.identifier,
                                  coordinate: model.coordinate,
                                  title: model.title,
                                  subtitle: model.subtitle,
                                  status: nil)
        }
    }
    /// Maps incident view models to task annotations
    func taskAnnotations(for resources: [ResourceMapViewModel]) -> [TaskAnnotation] {
        return resources.map { model in
            return ResourceAnnotation(identifier: model.identifier,
                                      coordinate: model.coordinate,
                                      title: model.title,
                                      subtitle: model.subtitle,
                                      status: model.status,
                                      icon: model.iconImage,
                                      iconBackgroundColor: model.iconBackgroundColor,
                                      iconTintColor: model.iconTintColor,
                                      pulsing: model.pulsing)
        }
    }
    
    // MARK: - Debug
    
    func loadDummyData() {
//        incidents = [
//            IncidentMapViewModel(identifier: "i1",
//                               title: "Assault",
//                               subtitle: "(2)",
//                               status: "Current Incident",
//                               coordinate: CLLocationCoordinate2D(latitude: -37.803166, longitude: 144.983696),
//                               priority: "P1",
//                               iconColor: .orangeRed,
//                               iconFilled: true,
//                               usesDarkBackground: false),
//
//            IncidentMapViewModel(identifier: "i2",
//                                 title: "Trespassing",
//                                 subtitle: "(1)",
//                                 status: "Resourced",
//                                 coordinate: CLLocationCoordinate2D(latitude: -37.797547, longitude: 144.985428),
//                                 priority: "P3",
//                                 iconColor: .secondaryGray,
//                                 iconFilled: false,
//                                 usesDarkBackground: false),
//
//            IncidentMapViewModel(identifier: "i3",
//                                 title: "Vandalism",
//                                 subtitle: nil,
//                                 status: "Unresourced",
//                                 coordinate: CLLocationCoordinate2D(latitude: -37.802759, longitude: 144.995149),
//                                 priority: "P4",
//                                 iconColor: .secondaryGray,
//                                 iconFilled: false,
//                                 usesDarkBackground: true),
//
//            IncidentMapViewModel(identifier: "i4",
//                                 title: "Traffic Crash",
//                                 subtitle: nil,
//                                 status: "Unresourced",
//                                 coordinate: CLLocationCoordinate2D(latitude: -37.807550, longitude: 144.975053),
//                                 priority: "P3",
//                                 iconColor: .secondaryGray,
//                                 iconFilled: false,
//                                 usesDarkBackground: false),
//
//
//            IncidentMapViewModel(identifier: "i5",
//                               title: "Domestic Violence",
//                               subtitle: "(2)",
//                               status: "Resourced",
//                               coordinate: CLLocationCoordinate2D(latitude: -37.800077, longitude: 144.976741),
//                               priority: "P2",
//                               iconColor: .sunflowerYellow,
//                               iconFilled: true,
//                               usesDarkBackground: false),
//
//
//            IncidentMapViewModel(identifier: "i6",
//                               title: "Public Nuisance",
//                               subtitle: "(1)",
//                               status: "Resourced",
//                               coordinate: CLLocationCoordinate2D(latitude: -37.808979, longitude: 144.978205),
//                               priority: "P3",
//                               iconColor: .secondaryGray,
//                               iconFilled: false,
//                               usesDarkBackground: true),
//        ]
//
        patrol = [
        ]
        
        broadcast = [
        ]
        
        resources = [
            
            ResourceMapViewModel(identifier: "r1",
                                 title: "P03",
                                 subtitle: "(3)",
                                 status: "In Duress 2:45", // TODO: Countdown...
                                 coordinate: CLLocationCoordinate2D(latitude: -37.807014, longitude: 144.973212),
                                 iconImage: AssetManager.shared.image(forKey: .resourceCar),
                                 iconBackgroundColor: .orangeRed,
                                 iconTintColor: .black,
                                 pulsing: true),
            
            ResourceMapViewModel(identifier: "r2",
                                 title: "P07",
                                 subtitle: "(2)",
                                 status: "At Incident",
                                 coordinate: CLLocationCoordinate2D(latitude: -37.802314, longitude: 144.975459),
                                 iconImage: AssetManager.shared.image(forKey: .resourceCar),
                                 iconBackgroundColor: .primaryGray,
                                 iconTintColor: .white,
                                 pulsing: false),
            
            ResourceMapViewModel(identifier: "r3",
                                 title: "K12",
                                 subtitle: "(1)",
                                 status: "On Air",
                                 coordinate: CLLocationCoordinate2D(latitude: -37.799788, longitude: 144.992054),
                                 iconImage: AssetManager.shared.image(forKey: .resourceDog),
                                 iconBackgroundColor: .midGreen,
                                 iconTintColor: .black,
                                 pulsing: false),
            
            ResourceMapViewModel(identifier: "r4",
                                 title: "K14",
                                 subtitle: "(2)",
                                 status: "Tasked",
                                 coordinate: CLLocationCoordinate2D(latitude: -37.801455, longitude: 144.977965),
                                 iconImage: AssetManager.shared.image(forKey: .resourceDog),
                                 iconBackgroundColor: .primaryGray,
                                 iconTintColor: .white,
                                 pulsing: false),
        ]
        
        loadTasks()
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
