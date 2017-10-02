//
//  TasksMapViewController.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import MapKit

open class TasksMapViewController: MapViewController {
    let viewModel = TasksMapViewModel()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Activities"
        self.isUserLocationButtonHidden = false
        isMapTypeButtonHidden = false
        
        viewModel.loadDummyData()
        mapView.addAnnotations(viewModel.filteredAnnotations)
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ResourceAnnotation {
            return ResourceAnnotationView(annotation: annotation,
                                          reuseIdentifier: "ResourceAnnotationView",
                                          circleBackgroundColor: annotation.iconBackgroundColor,
                                          resourceImage: annotation.icon)
        } else if let annotation = annotation as? IncidentAnnotation {
            return IncidentAnnotationView.init(annotation: annotation,
                                               reuseIdentifier: "IncidentAnnotationView",
                                               priorityColor: annotation.iconColor,
                                               priorityText: annotation.iconText,
                                               priorityFilled: annotation.iconFilled,
                                               usesDarkBackground: annotation.usesDarkBackground)
        }
        else {
            return nil
        }
    }
}
