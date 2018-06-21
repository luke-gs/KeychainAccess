//
//  LocationMapSelectViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class LocationMapSelectionViewController: MapFormBuilderViewController, EvaluationObserverable, CLLocationManagerDelegate {

    let viewModel: LocationSelectionViewModel

    private lazy var locationAnnotation: MKPointAnnotation? = {
        let annotation = MKPointAnnotation()
        mapView?.addAnnotation(annotation)
        return annotation
    }()

    public init(viewModel: LocationSelectionViewModel) {
        self.viewModel = viewModel
        self.viewModel.type = viewModel.locationTypeOptions.first

        super.init(layout: StackMapLayout())
        
        viewModel.evaluator.addObserver(self)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneHandler))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandler))
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

        if let lat = viewModel.location?.latitude, let lon = viewModel.location?.longitude  {
            if viewModel.dropsPinAutomatically {
                reverseGeocode(coord: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
            updateRegion(for: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        } else {
            updateRegion(for: mapView.userLocation.coordinate)
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
            .options(viewModel.locationTypeOptions)
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

    private func updateRegion(for coords: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(coords, span)

        mapView?.setRegion(region, animated: true)
    }

    private func reverseGeocode(coord: CLLocationCoordinate2D) {
        viewModel.reverseGeocode(from: coord).ensure {
            self.locationAnnotation?.coordinate = coord
            self.reloadForm()
        }
    }

    @objc private func performLocationSearch(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            if let coordinate = mapView?.convert(point, toCoordinateFrom: mapView) {
                viewModel.location?.addressString = nil
                reverseGeocode(coord: coordinate)
            }
        }
    }

    @objc private func cancelHandler(sender: UIBarButtonItem) {
        viewModel.location = nil
        viewModel.completeLocationSelection()
        if let annotations = mapView?.annotations.filter({ $0 is MKUserLocation == false }) {
            mapView?.removeAnnotations(annotations)
        }
        navigationController?.popViewController(animated: true )
    }

    @objc private func doneHandler(sender: UIBarButtonItem) {
        viewModel.completeLocationSelection()
        dismiss(animated: true)
    }
}

extension LocationMapSelectionViewController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKPointAnnotation {
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
        // This is the only solution that seemed to work. 
        userLocation.title = ""
    }

}
