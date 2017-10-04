//
//  TasksMapViewController.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
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
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ResourceAnnotationView.defaultReuseIdentifier) as? ResourceAnnotationView
            
            if annotationView == nil {
                annotationView = ResourceAnnotationView(annotation: annotation, reuseIdentifier: ResourceAnnotationView.defaultReuseIdentifier)
            }
            
            annotationView?.configure(withAnnotation: annotation,
                                      circleBackgroundColor: annotation.iconBackgroundColor,
                                      resourceImage: annotation.icon)
            
            return annotationView
        } else if let annotation = annotation as? IncidentAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: IncidentAnnotationView.defaultReuseIdentifier) as? IncidentAnnotationView
            
            if annotationView == nil {
                annotationView = IncidentAnnotationView(annotation: annotation, reuseIdentifier: IncidentAnnotationView.defaultReuseIdentifier)
            }
            
            annotationView?.configure(withAnnotation: annotation,
                                      priorityColor: annotation.iconColor,
                                      priorityText: annotation.iconText,
                                      priorityFilled: annotation.iconFilled,
                                      usesDarkBackground: annotation.usesDarkBackground)
            
            return annotationView
            
        } else {
            return nil
        }
    }
}


