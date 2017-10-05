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
    var mapLayerFilterButton: UIBarButtonItem!
    var zPositionObservers: [NSKeyValueObservation] = []

    open override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        navigationItem.title = "Activities"
        isUserLocationButtonHidden = false
        isMapTypeButtonHidden = false
        
        mapLayerFilterButton = UIBarButtonItem.init(image: AssetManager.shared.image(forKey: .filter), style: .plain, target: self, action: #selector(showMapLayerFilter))
        navigationItem.rightBarButtonItem = mapLayerFilterButton
        
        viewModel.loadDummyData()
        mapView.addAnnotations(viewModel.filteredAnnotations)
    }
    
    /// Shows the layer filter popover
    @objc private func showMapLayerFilter() {
        let filterViewController = MapFilterViewController(with: viewModel.filterViewModel)
        let filterNav = PopoverNavigationController(rootViewController: filterViewController)
        filterNav.modalPresentationStyle = .popover
        filterNav.popoverPresentationController?.barButtonItem = mapLayerFilterButton
        
        present(filterNav, animated: true, completion: nil)
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
    
    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        // Keep resource annotations on top by observing changes to the layer's zPosition
        // This is needed for iOS 11
        if #available(iOS 11.0, *) {
            for annotationView in views {
                if annotationView.annotation is ResourceAnnotation {
                    zPositionObservers.append(annotationView.layer.observe(\.zPosition) { (layer, change) in
                        if layer.zPosition < 1000 {
                            layer.zPosition += 1000
                        }
                    })
                }
            }
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Keep resource annotations on top by bringing subview to front
        // This is needed for iOS 10
        if #available(iOS 11.0, *) { return }
        for annotation in mapView.annotations {
            guard let annotationView = mapView.view(for: annotation) else { continue }
            if annotationView is ResourceAnnotationView {
                annotationView.superview?.bringSubview(toFront: annotationView)
            }
        }
    }

}

extension TasksMapViewController: TasksMapViewModelDelegate {
    func viewModelStateChanged() {
        DispatchQueue.main.async {
            self.zPositionObservers.removeAll()
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(self.viewModel.filteredAnnotations)
        }
    }
}
