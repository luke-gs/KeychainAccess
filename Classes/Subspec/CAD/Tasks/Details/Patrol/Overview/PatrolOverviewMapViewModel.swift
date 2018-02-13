//
//  PatrolOverviewMapViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class PatrolOverviewMapViewModel: TasksMapViewModel {

    private let patrolNumber: String
    
    public init(patrolNumber: String) {
        self.patrolNumber = patrolNumber
    }
    
    override open func loadTasks() {
        guard let patrol = CADStateManager.shared.patrolsById[patrolNumber] else { return }
        
        var annotations: [TaskAnnotation] = []
//        annotations += taskAnnotations(for: [patrol])
        
        filteredAnnotations = annotations
    }
    
    override open func createViewController() -> TasksMapViewController {
        if let incidentLocation = CADStateManager.shared.patrolsById[patrolNumber]?.location {
            let location = CLLocation(latitude: CLLocationDegrees(incidentLocation.latitude), longitude: CLLocationDegrees(incidentLocation.longitude))
            let viewController = TasksMapViewController(viewModel: self, initialLoadZoomStyle: .coordinate(location, animated : false))
            viewController.defaultZoomDistance = defaultZoomDistance
            return viewController
        }
        return TasksMapViewController(viewModel: self, annotationsInitialLoadZoomStyle: (animated: false, includeUserLocation: true))
    }
    
    open override func canSelectAnnotationView(_ view: MKAnnotationView) -> Bool {
        return false
    }
    
    open override func shouldCluster() -> Bool {
        return false
    }
}
