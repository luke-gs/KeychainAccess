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
    
    private var performedInitialLoadAction: Bool = false
    private var addedFirstAnnotations: Bool = false
    private var savedRegion: MKCoordinateRegion?
    
    let viewModel: TasksMapViewModel
    var mapLayerFilterButton: UIBarButtonItem!
    var zPositionObservers: [NSKeyValueObservation] = []

    public init(viewModel: TasksMapViewModel, initialLoadZoomStyle: InitialLoadZoomStyle, startingRegion: MKCoordinateRegion? = nil, settingsViewModel: MapSettingsViewModel = MapSettingsViewModel()) {
        self.viewModel = viewModel
        super.init(initialLoadZoomStyle: initialLoadZoomStyle, startingRegion: startingRegion, settingsViewModel: settingsViewModel)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        navigationItem.title = "Activities"
        isUserLocationButtonHidden = false
        isMapTypeButtonHidden = false
        mapView.showsCompass = false
        
        mapLayerFilterButton = UIBarButtonItem.init(image: AssetManager.shared.image(forKey: .filter), style: .plain, target: self, action: #selector(showMapLayerFilter))
        navigationItem.rightBarButtonItem = mapLayerFilterButton
        
        viewModel.loadTasks()
        mapView.addAnnotations(viewModel.filteredAnnotations)
    }
    
    /// Shows the layer filter popover
    @objc private func showMapLayerFilter() {
        viewModel.splitViewModel?.presentMapFilter()
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ResourceAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ResourceAnnotationView.defaultReuseIdentifier) as? ResourceAnnotationView
            
            if annotationView == nil {
                annotationView = ResourceAnnotationView(annotation: annotation, reuseIdentifier: ResourceAnnotationView.defaultReuseIdentifier)
            }
            
            annotationView?.configure(withAnnotation: annotation,
                                      circleBackgroundColor: annotation.iconBackgroundColor,
                                      resourceImage: annotation.icon,
                                      imageTintColor: annotation.iconTintColor)
            
            return annotationView
        } else if let annotation = annotation as? IncidentAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: IncidentAnnotationView.defaultReuseIdentifier) as? IncidentAnnotationView
            
            if annotationView == nil {
                annotationView = IncidentAnnotationView(annotation: annotation, reuseIdentifier: IncidentAnnotationView.defaultReuseIdentifier)
            }

            annotationView?.configure(withAnnotation: annotation,
                                      priorityText: annotation.badgeText,
                                      priorityTextColor: annotation.badgeTextColor,
                                      priorityFillColor: annotation.badgeFillColor,
                                      priorityBorderColor: annotation.badgeBorderColor,
                                      usesDarkBackground: annotation.usesDarkBackground)
            
            return annotationView
            
        } else {
            return nil
        }
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
       
        if let viewModel = viewModel.viewModel(for: view.annotation as? TaskAnnotation) {
            let vc = TasksItemSidebarViewController(viewModel: viewModel)
            splitViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        // Keep resource annotations on top by observing changes to the layer's zPosition
        // This is needed for iOS 11
        if #available(iOS 11.0, *) {
            for annotationView in views {
                if viewModel.isAnnotationViewDisplayedOnTop(annotationView) {
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
            if viewModel.isAnnotationViewDisplayedOnTop(annotationView) {
                annotationView.superview?.bringSubview(toFront: annotationView)
            }
        }
    }
    
    private func zoomToAnnotations() {
        if case let InitialLoadZoomStyle.annotations(animated) = initialLoadZoomStyle,
            mapView.userLocation.location != nil,
            !performedInitialLoadAction
        {
            let annotations = self.mapView.annotations
            
            var zoomRect = MKMapRectNull
            for annotation in annotations {
                let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
                zoomRect = MKMapRectUnion(zoomRect, pointRect)
            }
            let inset = -zoomRect.size.width
            
            mapView.setVisibleMapRect(MKMapRectInset(zoomRect, inset, inset), animated: animated)
        }
    }
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.zoomToAnnotations()
    }
}

extension TasksMapViewController: TasksSplitViewControllerDelegate {
    public func willChangeSplitWidth(from oldSize: CGFloat, to newSize: CGFloat) {
        // Store the current region if we are growing split
        if newSize > oldSize && mapView.bounds.width > 1 {
            savedRegion = mapView.region
        }
    }
    
    public func didChangeSplitWidth(from oldSize: CGFloat, to newSize: CGFloat) {
        // Restore the region if we are shrinking split
        if let region = savedRegion, newSize < oldSize, mapView.bounds.width > 1 {
            mapView.setRegion(region, animated: false)
        }
    }
}

extension TasksMapViewController: TasksMapViewModelDelegate {
    public func viewModelStateChanged() {
        DispatchQueue.main.async {
            self.zPositionObservers.removeAll()
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(self.viewModel.filteredAnnotations)
            self.addedFirstAnnotations = true
            self.zoomToAnnotations()
        }
    }
    
    public func zoomToUserLocation() {
        DispatchQueue.main.async {
            self.zoomAndCenterToUserLocation(animated: true)
        }
    }
}
