//
//  LocationSelectViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class LocationMapSelectionViewController: MapFormBuilderViewController, EvaluationObserverable {
    var viewModel: LocationSelectionViewModel

    public var locationAnnotation: LocationAnnotation?

    public init(viewModel: LocationSelectionViewModel) {
        self.viewModel = viewModel
        super.init(layout: StackMapLayout(mapPercentage: 50))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneHandler))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandler))

        viewModel.evaluator.addObserver(self)
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

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(performLocationSearch(gesture:)))
        mapView.addGestureRecognizer(longPressGesture)
    }

    override open func construct(builder: FormBuilder) {
        builder.title = "Select Location"
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "LOCATION DETAILS")
        builder += DropDownFormItem(title: "Type")
            .options(["Event Location"])
            .selectedValue(["Event Location"])
            .allowsMultipleSelection(false)
            .onValueChanged { values in
                self.viewModel.type = values?.first
            }
            .required()
        builder += ValueFormItem(title: "Address", value: nil, image: nil)
            .value(viewModel.composeAddress())
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        if key == .locationType {
            navigationItem.rightBarButtonItem?.isEnabled = evaluationState
        }
    }

    // PRIVATE

    @objc private func performLocationSearch(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            if let coordinate = mapView?.convert(point, toCoordinateFrom: mapView) {
                viewModel.reverseGeoCode(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude),
                                         completion: {
                                            self.locationAnnotation?.coordinate = coordinate
                                            self.reloadForm()
                })
            }
        }
    }

    @objc private func cancelHandler(sender: UIBarButtonItem) {
        dismissAnimated()
    }

    @objc private func doneHandler(sender: UIBarButtonItem) {
        viewModel.completeLocationSelection()
        dismissAnimated()
    }
}

extension LocationMapSelectionViewController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? LocationAnnotation {
            let pinView: PinAnnotationView
            let identifier = MapSummaryAnnotationViewIdentifier.single.rawValue
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PinAnnotationView {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            } else {
                pinView = PinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            return pinView
        }

        return nil
    }

    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(userLocation.coordinate, span)
        mapView.setRegion(region, animated: true)

        locationAnnotation = LocationAnnotation()
        locationAnnotation?.coordinate = userLocation.coordinate
        mapView.addAnnotation(locationAnnotation!)

        viewModel.reverseGeoCode(location: userLocation.location) {
            self.reloadForm()
        }
    }
}
