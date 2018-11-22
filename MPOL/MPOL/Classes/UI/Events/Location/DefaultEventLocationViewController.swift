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

open class DefaultEventLocationViewController: MapFormBuilderViewController, EvaluationObserverable {

    var viewModel: DefaultEventLocationViewModel
    private var locationAnnotation: MKPointAnnotation?

    public init(viewModel: DefaultEventLocationViewModel) {
        self.viewModel = viewModel
        super.init(layout: StackMapLayout())
        viewModel.report.evaluator.addObserver(self)

        sidebarItem.regularTitle = "Location"
        sidebarItem.compactTitle = "Location"
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
        mapView.isUserInteractionEnabled = false

        _ = CLLocationManager.requestAuthorization(type: .whenInUse)

        // Set initial annotation
        self.updateAnnotation()
        self.updateRegion()
    }

    override open func construct(builder: FormBuilder) {
        builder.title = "Locations"
        builder.enforceLinearLayout = .always

        builder += LargeTextHeaderFormItem(text: "Locations")
            .separatorColor(.clear)
            .actionButton(title: NSLocalizedString("Add", comment: ""),
                          handler: { [weak self] _ in
                                      guard let `self` = self else { return }
                                      self.addLocation()
                                   })

        // if we have no location add empty location to list
        if viewModel.report.eventLocations.isEmpty {
            builder += SubtitleFormItem(title: "Not Yet Specified")
                .subtitle("No Involvements")
                .image(AssetManager.shared.image(forKey: .entityLocation))
                .accessory(ItemAccessory.pencil)
                .onSelection({ [weak self] cell in
                    guard let `self` = self else { return }
                    self.onSelection(cell)
                })
        // else add location to list for each in array
        } else {
            viewModel.report.eventLocations.forEach { location in
                builder += SubtitleFormItem(title: location.addressString)
                    .subtitle(LocationSelectionCore(eventLocation: location)?.type?.title ?? "No Involvements")
                    .image(AssetManager.shared.image(forKey: .entityLocation))
                    .accessory(ItemAccessory.pencil)
                    .onSelection({ [weak self] cell in
                        guard let `self` = self else { return }
                        self.onSelection(cell)
                    })
            }
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    private func showLocationServicesDisabledPrompt() {
        let alertController = UIAlertController(title: "Location Services Disabled",
                                                message: "You need to enable location services in settings.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay",
                                                style: .default))
        AlertQueue.shared.add(alertController)
    }

    private func updateAnnotation() {
        guard let lat = viewModel.report.eventLocations.first?.latitude,
            let lon = viewModel.report.eventLocations.first?.longitude
            else { return }

        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)

        if let locationAnnotation = locationAnnotation {
            locationAnnotation.coordinate = coord
        } else {
            locationAnnotation = MKPointAnnotation()
            locationAnnotation?.coordinate = coord
            mapView?.addAnnotation(locationAnnotation!)
        }
    }

    private func updateRegion() {
        guard let lat = viewModel.report.eventLocations.first?.latitude,
            let lon = viewModel.report.eventLocations.first?.longitude
            else { return }

        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: coord, span: span)

        mapView?.setRegion(region, animated: true)
    }

    private func addLocation() {
        let presentable = LocationSelectionScreen.locationSelectionLanding(LocationSelectionPresenter.eventWorkflowId,
                                                                            nil) { [weak self] selection in
                                                                                guard let `self` = self else { return }
                                                                                if let selection = selection {

                                                                                    guard let eventLocation = EventLocation(locationSelection: selection) else { return }
                                                                                    self.viewModel.report.eventLocations.append(eventLocation)
                                                                                    self.updateAnnotation()
                                                                                    self.updateRegion()
                                                                                }
                                                                                self.reloadForm()
                                                                            }
        present(presentable)
    }

    private func onSelection(_ cell: CollectionViewFormCell) {
        guard let index = self.collectionView?.indexPath(for: cell)?.row else { return }

        let selectionType: LocationSelectionCore? = {
            guard let location = self.viewModel.report.eventLocations[ifExists: index] else { return nil }
            return LocationSelectionCore(eventLocation: location)
        }()

        let presentable = LocationSelectionScreen.locationSelectionLanding(LocationSelectionPresenter.eventWorkflowId,
                                                                             selectionType) { [weak self] selection in
                                                                                guard let `self` = self else { return }
                                                                                if let selection = selection {

                                                                                    guard let index = self.collectionView?.indexPath(for: cell)?.row else { return }
                                                                                    guard let eventLocation = EventLocation(locationSelection: selection) else { return }
                                                                                    if self.viewModel.report.eventLocations[ifExists: index] != nil {
                                                                                        self.viewModel.report.eventLocations[index] = eventLocation
                                                                                    } else {
                                                                                        self.viewModel.report.eventLocations.append(eventLocation)
                                                                                    }
                                                                                    self.updateAnnotation()
                                                                                    self.updateRegion()
                                                                                }
                                                                                self.reloadForm()
                                                                            }
        present(presentable)
    }
}

extension DefaultEventLocationViewController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKPointAnnotation {
            let pinView: LocationSelectionAnnotationView
            let identifier = LocationSelectionAnnotationView.defaultReuseIdentifier
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocationSelectionAnnotationView {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            } else {
                pinView = LocationSelectionAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            // Do not show address
            annotation.title = ""

            return pinView
        }
        return nil
    }

    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
