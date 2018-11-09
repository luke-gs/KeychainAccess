//
//  BroadcastOverviewMapViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 7/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MapKit

open class BroadcastOverviewMapViewModel: TasksMapViewModel {

    private var broadcast: CADBroadcastType?

    public func reloadFromModel(_ model: CADBroadcastType) {
        self.broadcast = model
        loadTasks()
    }

    override open func loadTasks() {
        guard let broadcast = broadcast else { return }

        filteredAnnotations = [broadcast.createAnnotation()].removeNils()
    }

    override open func createViewController() -> TasksMapViewController {
        if let coordinate = broadcast?.location?.coordinate {
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
