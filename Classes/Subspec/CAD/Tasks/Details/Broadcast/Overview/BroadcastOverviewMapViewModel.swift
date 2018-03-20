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

    private let broadcastNumber: String

    public init(broadcastNumber: String) {
        self.broadcastNumber = broadcastNumber
    }

    override open func loadTasks() {
        guard let broadcast = CADStateManager.shared.broadcastsById[broadcastNumber] else { return }

        filteredAnnotations = [broadcast.createAnnotation()].removeNils()
    }

    override open func createViewController() -> TasksMapViewController {
        if let coordinate = CADStateManager.shared.broadcastsById[broadcastNumber]?.location?.coordinate {
            let viewController = TasksMapViewController(viewModel: self, initialLoadZoomStyle: .coordinate(coordinate, animated : false))
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
