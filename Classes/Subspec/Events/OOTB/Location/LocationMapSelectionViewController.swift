//
//  LocationMapSelectViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class LocationMapSelectionViewController: MapFormBuilderViewController, EvaluationObserverable {
    var viewModel: LocationSelectionViewModel

    private lazy var locationAnnotation: LocationAnnotation? = {
        let annotation = LocationAnnotation()
        mapView?.addAnnotation(annotation)
        return annotation
    }()

    public init(viewModel: LocationSelectionViewModel) {
        self.viewModel = viewModel
        self.viewModel.type = "Event Location"

        super.init(layout: StackMapLayout())

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneHandler))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandler))

        viewModel.evaluator.addObserver(self)
    }

    deinit {
        viewModel.evaluator.removeObserver(self)
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

        if let lat = viewModel.location?.latitude, let lon = viewModel.location?.longitude {
            reverseGeocode(coord: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            updateRegion()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isEnabled = try? viewModel.evaluator.evaluationState(for: .locationType)
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled ?? false
    }

    override open func construct(builder: FormBuilder) {
        builder.title = "Select Location"
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "LOCATION DETAILS")
        builder += DropDownFormItem(title: "Type")
            .options(["Event Location"])
            .selectedValue(viewModel.selectedValues())
            .allowsMultipleSelection(false)
            .onValueChanged { values in
                self.viewModel.type = values?.first
            }
            .required()
        builder += ValueFormItem(title: "Address", value: nil, image: nil)
            .value(viewModel.location?.addressString)
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        if key == .locationType {
            navigationItem.rightBarButtonItem?.isEnabled = evaluationState
        }
    }

    // PRIVATE


    private func updateRegion() {
        guard let lat = viewModel.location?.latitude, let lon = viewModel.location?.longitude else { return }

        let span = MKCoordinateSpanMake(0.005, 0.005)
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegionMake(coord, span)

        mapView?.setRegion(region, animated: true)
    }

    private func reverseGeocode(coord: CLLocationCoordinate2D) {
            viewModel.reverseGeoCode(location: CLLocation(latitude: coord.latitude, longitude: coord.longitude),
                                     completion: {
                                        self.locationAnnotation?.coordinate = coord
                                        self.reloadForm()
            })
    }

    @objc private func performLocationSearch(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            if let coordinate = mapView?.convert(point, toCoordinateFrom: mapView) {
                reverseGeocode(coord: coordinate)
            }
        }
    }

    @objc private func cancelHandler(sender: UIBarButtonItem) {
        viewModel.location = nil
        viewModel.completeLocationSelection()
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
        userLocation.title = ""

        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(userLocation.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}
