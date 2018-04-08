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
        
        filteredAnnotations = [patrol.createAnnotation()].removeNils()
    }
    
    override open func createViewController() -> TasksMapViewController {
        if let coordinate = CADStateManager.shared.patrolsById[patrolNumber]?.location?.coordinate {
            let viewController = TasksMapViewController(viewModel: self, initialLoadZoomStyle: .coordinate(coordinate, animated : false))
            viewController.defaultZoomDistance = defaultZoomDistance
            return viewController
        }
        return TasksMapViewController(viewModel: self, annotationsInitialLoadZoomStyle: (animated: false, includeUserLocation: true))
    }
    
    open override func canSelectAnnotationView(_ view: MKAnnotationView) -> Bool {
        return false
    }
}
