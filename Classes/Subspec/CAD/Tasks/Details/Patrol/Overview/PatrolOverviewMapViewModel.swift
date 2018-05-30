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

    private var patrol: CADPatrolType?
    
    open func reloadFromModel(_ model: CADPatrolType) {
        self.patrol = model
    }
    
    override open func loadTasks() {
        guard let patrol = patrol else { return }
        
        filteredAnnotations = [patrol.createAnnotation()].removeNils()
    }
    
    override open func createViewController() -> TasksMapViewController {
        if let coordinate = patrol?.location?.coordinate {
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
