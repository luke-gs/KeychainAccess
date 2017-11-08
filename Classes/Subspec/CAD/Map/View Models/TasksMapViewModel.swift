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

    public weak var delegate: TasksMapViewModelDelegate?

    // MARK: - Data Source
    
    private var incidents: [IncidentMapViewModel] = []
    private var patrol: [PatrolMapViewModel] = []
    private var broadcast: [BroadcastMapViewModel] = []
    private var resources: [ResourceMapViewModel] = []
    
    // MARK: - Filter

    public private(set) var filterViewModel = TasksMapFilterViewModel()
    private var filter: TasksMapFilterViewModel.Filter {
        return filterViewModel.currentFilter
    }

    // TODO: Set from split view table
    var priorityAnnotationType = ResourceAnnotationView.self
    
    // MARK: - Init
    
    public init() {
        filterViewModel.delegate = self
    }
    
    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        return TasksMapViewController(viewModel: self)
    }

    // MARK: - Annotations

    /// Annotations matching the current filter
    var filteredAnnotations: [TaskAnnotation] {
        /// Annotations of the incidents type
        let incidentsAnnotations = incidents.map { model in
            return IncidentAnnotation(identifier: model.identifier,
                                      coordinate: model.coordinate,
                                      title: model.title,
                                      subtitle: model.subtitle,
                                      iconText: model.iconText,
                                      iconColor: model.iconColor,
                                      iconFilled: model.iconFilled,
                                      usesDarkBackground: model.usesDarkBackground)
        }
        
        /// Annotations of the patrol type
        let patrolAnnotations = patrol.map { model in
            return TaskAnnotation(identifier: model.identifier,
                                          coordinate: model.coordinate,
                                          title: model.title,
                                          subtitle: model.subtitle)
        }
        
        /// Annotations of the broadcast type
        let broadcastAnnotations = broadcast.map { model in
            return TaskAnnotation(identifier: model.identifier,
                                          coordinate: model.coordinate,
                                          title: model.title,
                                          subtitle: model.subtitle)
        }
        
        /// Annotations of the resource type
        let resourceAnnotations = resources.map { model in
            return ResourceAnnotation(identifier: model.identifier,
                                          coordinate: model.coordinate,
                                          title: model.title,
                                          subtitle: model.subtitle,
                                          icon: model.iconImage,
                                          iconBackgroundColor: model.iconColor,
                                          pulsing: model.pulsing)
        }
        
        var annotations: [TaskAnnotation] = []
        
        if filter.contains(.incidents) {
            annotations += incidentsAnnotations as [TaskAnnotation]
        }
        
        if filter.contains(.patrol) {
            annotations += patrolAnnotations
        }
        
        if filter.contains(.broadcast) {
            annotations += broadcastAnnotations
        }
        
        if filter.contains(.resources) {
            annotations += resourceAnnotations  as [TaskAnnotation]
        }
        
        return annotations
    }
    
    // MARK: - Debug
    
    func loadDummyData() {
        incidents = [
            IncidentMapViewModel(identifier: "i1",
                               title: "Assult",
                               subtitle: "Resourced (2)",
                               coordinate: CLLocationCoordinate2D(latitude: -37.803258, longitude: 144.983707),
                               iconText: "P1",
                               iconColor: .orangeRed,
                               iconFilled: true,
                               usesDarkBackground: false),

            IncidentMapViewModel(identifier: "i2",
                               title: "Domestic Violence",
                               subtitle: "Assigned",
                               coordinate: CLLocationCoordinate2D(latitude: -37.808173, longitude: 144.978827),
                               iconText: "P2",
                               iconColor: .sunflowerYellow,
                               iconFilled: true,
                               usesDarkBackground: false),

            IncidentMapViewModel(identifier: "i3",
                               title: "Trespassing",
                               subtitle: "Assigned",
                               coordinate: CLLocationCoordinate2D(latitude: -37.797528, longitude: 144.985450),
                               iconText: "P3",
                               iconColor: .brightBlue,
                               iconFilled: false,
                               usesDarkBackground: false),

            IncidentMapViewModel(identifier: "i4",
                               title: "Unassigned",
                               subtitle: "Resourced (2)",
                               coordinate: CLLocationCoordinate2D(latitude: -37.802048, longitude: 144.987646),
                               iconText: "P4",
                               iconColor: .brightBlue,
                               iconFilled: false,
                               usesDarkBackground: true),
        ]
        
        patrol = [
        ]
        
        broadcast = [
        ]
        
        resources = [
            
            ResourceMapViewModel(identifier: "r1",
                                 title: "P03",
                                 subtitle: "(3)",
                                 coordinate: CLLocationCoordinate2D(latitude: -37.807014, longitude: 144.973212),
                                 iconImage: AssetManager.shared.image(forKey: .resourceCar),
                                 iconColor: .orangeRed,
                                 pulsing: true),
            
            ResourceMapViewModel(identifier: "r2",
                                 title: "P07",
                                 subtitle: "(2)",
                                 coordinate: CLLocationCoordinate2D(latitude: -37.802314, longitude: 144.975459),
                                 iconImage: AssetManager.shared.image(forKey: .resourceCar),
                                 iconColor: #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1),
                                 pulsing: false),
            
            ResourceMapViewModel(identifier: "r3",
                                 title: "K12",
                                 subtitle: "(1)",
                                 coordinate: CLLocationCoordinate2D(latitude: -37.799788, longitude: 144.992054),
                                 iconImage: AssetManager.shared.image(forKey: .resourceDog),
                                 iconColor: .midGreen,
                                 pulsing: false),
        ]
    }
    
    func isAnnotationViewDisplayedOnTop(_ annotationView: MKAnnotationView) -> Bool {
        return type(of: annotationView) == priorityAnnotationType
    }
}

extension TasksMapViewModel: TasksMapFilterViewModelDelegate {
    public func filterDidChange(to filter: TasksMapFilterViewModel.Filter) {
        delegate?.viewModelStateChanged()
    }
}

public protocol TasksMapViewModelDelegate: class {
    /// Called when some data or state has changed
    func viewModelStateChanged()
}
