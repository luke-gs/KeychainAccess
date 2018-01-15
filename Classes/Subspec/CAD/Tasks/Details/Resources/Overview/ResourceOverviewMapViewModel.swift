//
//  ResourceOverviewMapViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 7/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class ResourceOverviewMapViewModel: TasksMapViewModel {
    
    private let callsign: String
    
    public init(callsign: String) {
        self.callsign = callsign
    }
    
    override open func loadTasks() {
        guard let resource = CADStateManager.shared.resourcesById[callsign] else { return }
        
        var annotations: [TaskAnnotation] = []
        annotations += taskAnnotations(for: [resource])
        
        if let incident = CADStateManager.shared.incidentsById[resource.currentIncident ?? ""] {
            annotations += taskAnnotations(for: [incident])
        }
        
        filteredAnnotations = annotations
    }
    
    open override func canSelectAnnotationView(_ view: MKAnnotationView) -> Bool {
        // Only allow selecting incidents
        return view is IncidentAnnotationView
    }
    
    override open func createViewController() -> TasksMapViewController {
        return TasksMapViewController(viewModel: self, initialLoadZoomStyle: .annotations(animated: false))
    }
}
