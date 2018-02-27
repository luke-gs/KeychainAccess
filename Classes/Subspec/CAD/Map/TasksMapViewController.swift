//
//  TasksMapViewController.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit
import Cluster

open class TasksMapViewController: MapViewController {
    public typealias AnnotationsInitialLoadZoomStyle = (animated: Bool, includeUserLocation: Bool)
    
    private var annotationsInitialLoadZoomStyle: AnnotationsInitialLoadZoomStyle?
    private var performedInitialLoadAction: Bool = false
    private var addedFirstAnnotations: Bool = false
    private var savedRegion: MKCoordinateRegion?
    private var zPositionObservers: [NSKeyValueObservation] = []

    public let viewModel: TasksMapViewModel
    public var mapLayerFilterButton: UIBarButtonItem!
    
    private let clusterManager: ClusterManager = {
        let clusterManager = ClusterManager()
        clusterManager.cellSize = nil
        clusterManager.minCountForClustering = 2
        clusterManager.shouldRemoveInvisibleAnnotations = false
        clusterManager.clusterPosition = .average
        return clusterManager
    }()
    
    public init(viewModel: TasksMapViewModel, initialLoadZoomStyle: InitialLoadZoomStyle, startingRegion: MKCoordinateRegion? = nil, settingsViewModel: MapSettingsViewModel = MapSettingsViewModel()) {
        self.viewModel = viewModel
        super.init(initialLoadZoomStyle: initialLoadZoomStyle, startingRegion: startingRegion, settingsViewModel: settingsViewModel)
    }
    
    public init(viewModel: TasksMapViewModel, annotationsInitialLoadZoomStyle: AnnotationsInitialLoadZoomStyle, startingRegion: MKCoordinateRegion? = nil, settingsViewModel: MapSettingsViewModel = MapSettingsViewModel()) {
        self.viewModel = viewModel
        self.annotationsInitialLoadZoomStyle = annotationsInitialLoadZoomStyle
        super.init(initialLoadZoomStyle: .none, startingRegion: startingRegion, settingsViewModel: settingsViewModel)
        
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        navigationItem.title = "Activities"
        mapView.showsCompass = false
        
        if #available(iOS 11.0, *) {
            mapView.register(ResourceAnnotationView.self, forAnnotationViewWithReuseIdentifier: ResourceAnnotationView.defaultReuseIdentifier)
            mapView.register(IncidentAnnotationView.self, forAnnotationViewWithReuseIdentifier: IncidentAnnotationView.defaultReuseIdentifier)
            mapView.register(PatrolAnnotationView.self, forAnnotationViewWithReuseIdentifier: PatrolAnnotationView.defaultReuseIdentifier)
        }
        
        mapLayerFilterButton = UIBarButtonItem.init(image: AssetManager.shared.image(forKey: .filter), style: .plain, target: self, action: #selector(showMapLayerFilter))
        navigationItem.rightBarButtonItem = mapLayerFilterButton
        
        viewModel.loadTasks()
        addAnnotations(viewModel.filteredAnnotations)
        addedFirstAnnotations = true
    }
    
    /// Shows the layer filter popover
    @objc private func showMapLayerFilter() {
        present(TaskListScreen.mapFilter(delegate: viewModel.splitViewModel))
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ClusterAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ClusterAnnotationView.defaultReuseIdentifier) as? ClusterAnnotationView
            annotationView?.annotation =  annotation
            
            if annotationView == nil {
                annotationView = ClusterAnnotationView(annotation: annotation, reuseIdentifier: ClusterAnnotationView.defaultReuseIdentifier)
            }

            let priorities = annotation.annotations.map { ($0 as? IncidentAnnotation)?.priority }.removeNils()
            let allGrades = CADClientModelTypes.incidentGrade.allCases
            let sortedPriorities = priorities.sorted { (lhs, rhs) in allGrades.index(where: { $0 == lhs }) ?? 0 < allGrades.index(where: { $0 == rhs }) ?? 0 }
            let highestPriority = sortedPriorities.first
            
            annotationView?.color = highestPriority?.badgeColors.border ?? .disabledGray

            return annotationView
        } else if let annotation = annotation as? TaskAnnotation {
            return annotation.dequeueReusableAnnotationView(mapView: mapView)
        } else {
            return nil
        }
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !(view is ClusterAnnotationView) {
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
        
        guard viewModel.canSelectAnnotationView(view) else { return }
        
        if let annotation = view.annotation as? TaskAnnotation, let viewModel = annotation.createItemViewModel() {
            present(TaskItemScreen.landing(viewModel: viewModel))
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
                            
                            // Bring duress to front
                            if (annotationView as? ResourceAnnotationView)?.duress == true {
                                layer.zPosition += 1000
                            }
                        }
                    })
                }
            }
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Animate and reload clusters
        UIView.transition(with: mapView, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.clusterManager.reload(mapView, visibleMapRect: mapView.visibleMapRect)
        }, completion: nil)

        // Keep resource annotations on top by bringing subview to front
        // This is needed for iOS 10
        if #available(iOS 11.0, *) { return }
        for annotation in mapView.annotations {
            guard let annotationView = mapView.view(for: annotation) else { continue }
            if viewModel.isAnnotationViewDisplayedOnTop(annotationView) {
                annotationView.superview?.bringSubview(toFront: annotationView)
            }
        }
        
        // Bring duress to front
        for annotation in mapView.annotations {
            guard (annotation as? ResourceAnnotationView)?.duress == true,
                let annotationView = mapView.view(for: annotation)
            else { continue }

            annotationView.superview?.bringSubview(toFront: annotationView)
        }
    }
    
    /// Zooms to the annotations when they are loaded for the first time
    private func zoomToAnnotationsOnLoad() {
        if let annotationsInitialLoadZoomStyle = annotationsInitialLoadZoomStyle,
            !performedInitialLoadAction,
            addedFirstAnnotations
        {
            if annotationsInitialLoadZoomStyle.includeUserLocation && mapView.userLocation.location == nil {
                return
            }
            
            let annotations = viewModel.shouldCluster() ? clusterManager.annotations : mapView.annotations
            
            var zoomRect = MKMapRectNull
            for annotation in annotations {
                if annotation is MKUserLocation && !annotationsInitialLoadZoomStyle.includeUserLocation { continue }
                let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
                zoomRect = MKMapRectUnion(zoomRect, pointRect)
            }

            // Inset the map rect to make a buffer around the annotations
            let inset = max(zoomRect.size.width, zoomRect.size.height) / 2
            zoomRect = MKMapRectInset(zoomRect, -inset, -inset)
            
            mapView.setVisibleMapRect(zoomRect, animated: annotationsInitialLoadZoomStyle.animated)
            performedInitialLoadAction = true
        }
    }
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        zoomToAnnotationsOnLoad()
    }
    
    /// Adds annotations to cluster manager or map view depending on view model
    private func addAnnotations(_ annotations: [MKAnnotation]) {
        if viewModel.shouldCluster() {
            clusterManager.add(annotations)
            UIView.transition(with: mapView, duration: 0.1, options: .transitionCrossDissolve, animations: {
                self.clusterManager.reload(self.mapView, visibleMapRect: self.mapView.visibleMapRect)
            }, completion: nil)
        } else {
            mapView.addAnnotations(annotations)
        }
    }
    
    /// Removes all annotations from cluster manager and map view
    private func removeAllAnnotations() {
        clusterManager.removeAll()
        mapView.removeAnnotations(mapView.annotations)
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
        } else {
            // Changing split but no saved region, probably the first time so we should clear performed initial load
            performedInitialLoadAction = false
        }
    }
    
    public func didFinishAnimatingSplitWidth() {
        zoomToAnnotationsOnLoad()
    }
}

extension TasksMapViewController: TasksMapViewModelDelegate {
    public func viewModelStateChanged() {
        // Zoom to anotations if they have changed due to change to book on or filter
        performedInitialLoadAction = false

        DispatchQueue.main.async {
            self.zPositionObservers.removeAll()
            self.removeAllAnnotations()
            self.addAnnotations(self.viewModel.filteredAnnotations)
            self.addedFirstAnnotations = true
            self.zoomToAnnotationsOnLoad()
        }
    }
    
    public func zoomToUserLocation() {
        DispatchQueue.main.async {
            self.zoomAndCenterToUserLocation(animated: true)
        }
    }
}
