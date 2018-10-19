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

    open weak var clusterDelegate: ClusterTasksViewControllerDelegate?

    open private(set) var annotationsInitialLoadZoomStyle: AnnotationsInitialLoadZoomStyle?
    open var performedInitialLoadAction: Bool = false
    open private(set) var addedFirstAnnotations: Bool = false
    open private(set) var savedRegion: MKCoordinateRegion?
    open private(set) var zPositionObservers: [NSKeyValueObservation] = []

    public let viewModel: TasksMapViewModel

    public let clusterManager: ClusterManager = {
        let clusterManager = ClusterManager()
        clusterManager.minCountForClustering = 2
        clusterManager.shouldRemoveInvisibleAnnotations = false
        clusterManager.clusterPosition = .average
        return clusterManager
    }()

    /// Button for showing map layer filter
    private var filterButton: UIBarButtonItem {
        var image = AssetManager.shared.image(forKey: .filter)
        if let filterViewModel = viewModel.splitViewModel?.filterViewModel, !filterViewModel.isDefaultState {
            image = AssetManager.shared.image(forKey: .filterFilled)
        }
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showMapLayerFilter))
    }

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
            mapView.register(BroadcastAnnotationView.self, forAnnotationViewWithReuseIdentifier: BroadcastAnnotationView.defaultReuseIdentifier)
        }

        navigationItem.rightBarButtonItem = filterButton

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
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MPOLClusterAnnotationView.defaultReuseIdentifier) as? MPOLClusterAnnotationView
            annotationView?.annotation =  annotation

            if annotationView == nil {
                annotationView = MPOLClusterAnnotationView(annotation: annotation, reuseIdentifier: MPOLClusterAnnotationView.defaultReuseIdentifier)
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

    open func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let clusterView = view as? MPOLClusterAnnotationView {
            present(TaskListScreen.clusterDetails(annotationView: clusterView, delegate: clusterDelegate ?? self))
            return
        }

        if view is MPOLMarkerAnnotationView {
            return
        }

        mapView.deselectAnnotation(view.annotation, animated: false)

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
                    zPositionObservers.append(annotationView.layer.observe(\.zPosition, options: [.initial]) { (layer, _) in
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

    open func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Animate and reload clusters
        UIView.transition(with: mapView, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.clusterManager.reload(mapView: mapView)
        }, completion: nil)

        if (viewModel.splitViewModel?.filterViewModel.showResultsOutsidePatrolArea).isTrue {
            CADStateManager.shared.syncMode = .map(boundingBox: mapView.visibleBoundingBox())
        }

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
    open func zoomToAnnotationsOnLoad() {
        if let annotationsInitialLoadZoomStyle = annotationsInitialLoadZoomStyle,
            !performedInitialLoadAction,
            addedFirstAnnotations {
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

            // Inset the map rect to make a buffer around the annotations (more horizontal for labels on map items)
            zoomRect = MKMapRectInset(zoomRect, -zoomRect.size.width * 0.2, -zoomRect.size.height * 0.1)

            // Dispatch the actual zooming as the map can't handle zoom while loading :(
            DispatchQueue.main.async {
                self.mapView.setVisibleMapRect(zoomRect, animated: annotationsInitialLoadZoomStyle.animated)
            }
            performedInitialLoadAction = true
        }
    }

    open func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        zoomToAnnotationsOnLoad()
    }

    /// Adds annotations to cluster manager or map view depending on view model
    open func addAnnotations(_ annotations: [MKAnnotation]) {
        if viewModel.shouldCluster() {
            clusterManager.add(annotations)
            UIView.transition(with: mapView, duration: 0.1, options: .transitionCrossDissolve, animations: {
                // Cluster manager crashes app if visible map rect origin is < 0. Most likely Tim Cook's direct fault. 
                if self.mapView.visibleMapRect.origin.x >= 0 && self.mapView.visibleMapRect.origin.y >= 0 {
                    self.clusterManager.reload(mapView: self.mapView)
                }
            }, completion: nil)
        } else {
            mapView.addAnnotations(annotations)
        }
    }

    /// Removes all annotations from cluster manager and map view
    private func removeAllAnnotations() {
        clusterManager.removeAll()
        mapView.removeAnnotations(mapView.annotations)

        // Due to bug in cluster manager, clear the visible annotations as well or differences will be incorrect
        // Submitted PR: https://github.com/efremidze/Cluster/pull/70
        clusterManager.visibleAnnotations.removeAll()
    }
}

// MARK: - TasksSplitViewControllerDelegate
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

// MARK: - TasksMapViewModelDelegate
extension TasksMapViewController: TasksMapViewModelDelegate {

    public func boundingBox() -> MKMapRect.BoundingBox {
        return mapView.visibleBoundingBox()
    }

    public func filterChanged() {
        // Update filter icon
        navigationItem.rightBarButtonItem = filterButton
    }

    public func annotationsChanged() {
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

    public func priorityAnnotationChanged() {
        DispatchQueue.main.async {
            self.zPositionObservers.removeAll()
            self.removeAllAnnotations()
            self.addAnnotations(self.viewModel.filteredAnnotations)
        }
    }

    public func zoomToUserLocation() {
        DispatchQueue.main.async {
            self.zoomAndCenterToUserLocation(animated: true)
        }
    }
}

// MARK: - ClusterTasksViewControllerDelegate
extension TasksMapViewController: ClusterTasksViewControllerDelegate {
    public func didShowClusterDetails() {
    }

    public func didCloseClusterDetails() {
        // When dismissing cluster popover, deselect cluster
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
}
