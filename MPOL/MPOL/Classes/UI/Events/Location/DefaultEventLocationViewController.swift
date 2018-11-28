//
//  DefaultEventLocationViewController.swift
//  MPOLKit
//
//  Created by Kara Valentine on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit
import PublicSafetyKit
import Cluster

open class DefaultEventLocationViewController: MapFormBuilderViewController, EvaluationObserverable {

    var viewModel: DefaultEventLocationViewModel

    private let clusterManager: ClusterManager = {
        let clusterManager = ClusterManager()
        clusterManager.maxZoomLevel = 20
        clusterManager.minCountForClustering = 2
        clusterManager.shouldRemoveInvisibleAnnotations = true
        clusterManager.clusterPosition = .average
        return clusterManager
    }()

    public init(viewModel: DefaultEventLocationViewModel) {
        self.viewModel = viewModel
        super.init(layout: StackMapLayout())
        viewModel.report.evaluator.addObserver(self)

        sidebarItem.regularTitle = NSLocalizedString("Location", comment: "")
        sidebarItem.compactTitle = NSLocalizedString("Location", comment: "")
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.location)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        guard let mapView = self.mapView else { return }
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.userTrackingMode = .none
        mapView.isUserInteractionEnabled = true

        _ = CLLocationManager.requestAuthorization(type: .whenInUse)

        // Set initial annotation
        self.updateAnnotations()
        self.sidebarItem.count = self.viewModel.displayCount
    }

    override open func construct(builder: FormBuilder) {
        viewModel.construct(for: self, with: builder)
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    private func showLocationServicesDisabledPrompt() {
        let alertController = UIAlertController(title: NSLocalizedString("Location Services Disabled", comment: ""),
                                                message: NSLocalizedString("You need to enable location services in settings.", comment: ""),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""),
                                                style: .default))
        AlertQueue.shared.add(alertController)
    }

    public func updateAnnotations() {

        guard let mapView = mapView else { return }
        clusterManager.removeAll()

        for location in viewModel.report.eventLocations {

            let coord = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)

            let locationAnnotation = MKPointAnnotation()
            locationAnnotation.coordinate = coord
            locationAnnotation.title = location.involvements.joined(separator: ", ")
            clusterManager.add(locationAnnotation)
        }

        clusterManager.reload(mapView: mapView)
    }

    public func addLocation() {
        let presentable = LocationSelectionScreen.locationSelectionLanding(
            LocationSelectionPresenter.eventWorkflowId,
            nil) { [weak self] selection in
                guard let self = self else { return }
                if let selection = selection as? LocationSelectionCore {

                    guard let eventLocation = EventLocation(locationSelection: selection) else { return }
                    self.viewModel.report.eventLocations.append(eventLocation)
                    self.updateAnnotations()
                }
                self.sidebarItem.count = self.viewModel.displayCount
                self.reloadForm()
            }
        present(presentable)
    }

    public func onSelection(_ cell: CollectionViewFormCell) {
        guard let index = self.collectionView?.indexPath(for: cell)?.row else { return }

        let selectionType: LocationSelectionCore? = {
            guard let location = self.viewModel.report.eventLocations[ifExists: index] else { return nil }
            return LocationSelectionCore(eventLocation: location)
        }()

        let presentable = LocationSelectionScreen.locationSelectionLanding(
             LocationSelectionPresenter.eventWorkflowId,
             selectionType) { [weak self] selection in
                guard let self = self else { return }
                if let selection = selection as? LocationSelectionCore {

                    guard let index = self.collectionView?.indexPath(for: cell)?.row else { return }
                    guard let eventLocation = EventLocation(locationSelection: selection) else { return }
                    if self.viewModel.report.eventLocations[ifExists: index] != nil {
                        self.viewModel.report.eventLocations[index] = eventLocation
                    } else {
                        self.viewModel.report.eventLocations.append(eventLocation)
                    }
                    self.updateAnnotations()
                }
                self.sidebarItem.count = self.viewModel.displayCount
                self.reloadForm()
            }
        present(presentable)
    }
}

extension DefaultEventLocationViewController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if let annotation = annotation as? ClusterAnnotation {
            
            annotation.title = annotation.annotations.compactMap({ $0.title }).joined(separator: ", ")
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MPOLClusterAnnotationView.defaultReuseIdentifier) as? MPOLClusterAnnotationView
            annotationView?.annotation =  annotation

            if annotationView == nil {
                annotationView = MPOLClusterAnnotationView(annotation: annotation, reuseIdentifier: MPOLClusterAnnotationView.defaultReuseIdentifier)
            }

            annotationView?.color = .disabledGray
            return annotationView
        } else if let annotation = annotation as? MKPointAnnotation {
            let pinView: MKAnnotationView
            let identifier = LocationSelectionAnnotationView.defaultReuseIdentifier
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocationSelectionAnnotationView {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            } else {
                pinView = LocationSelectionAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            return pinView
        }
        return nil
    }

    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusterManager.reload(mapView: mapView)
    }
}
