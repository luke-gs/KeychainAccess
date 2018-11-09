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

        builder += PickerFormItem(pickerAction: LocationSelectionFormAction(workflowId: LocationSelectionPresenter.eventWorkflowId))
            .title("Event Location")
            .selectedValue(LocationSelectionCore(eventLocation: viewModel.report.eventLocation))
            .accessory(ImageAccessoryItem(image: AssetManager.shared.image(forKey: .iconPencil)!))
            .required()
            .onValueChanged({ [weak self] (location) in
                guard let `self` = self else { return }
                if let location = location {
                    self.viewModel.report.eventLocation = EventLocation(locationSelection: location)
                    self.updateAnnotation()
                    self.updateRegion()
                }
                self.reloadForm()
            })
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
        guard let lat = viewModel.report.eventLocation?.latitude,
            let lon = viewModel.report.eventLocation?.longitude
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
        guard let lat = viewModel.report.eventLocation?.latitude,
            let lon = viewModel.report.eventLocation?.longitude
            else { return }

        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: coord, span: span)

        mapView?.setRegion(region, animated: true)
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
