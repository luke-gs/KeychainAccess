//
//  LocationMapSelectViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

/// View controller for a generic map location selection
open class LocationSelectionMapViewController: MapFormBuilderViewController, CLLocationManagerDelegate {

    /// The view model
    let viewModel: LocationSelectionMapViewModel

    /// Closure called when a location selection is completed
    public var selectionHandler: ((LocationSelection) -> ())?

    /// Closure called when the selection is cancelled
    public var cancelHandler: (() -> ())?

    public init(viewModel: LocationSelectionMapViewModel, layout: MapFormBuilderViewLayout? = StackMapLayout()) {
        self.viewModel = viewModel
        super.init(layout: layout)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton))
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

        initialLoad()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isValid
    }

    override open func construct(builder: FormBuilder) {
        builder.title = viewModel.navTitle
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: viewModel.headerTitle)
        builder += DropDownFormItem(title: viewModel.locationTypeTitle)
            .options(viewModel.locationTypeOptions)
            .selectedValue([viewModel.locationType].removeNils())
            .allowsMultipleSelection(false)
            .onValueChanged { [weak self] values in
                self?.viewModel.locationType = values?.first
            }
            .required()
        builder += ValueFormItem(title: viewModel.addressTitle, value: nil, image: nil)
            .value(viewModel.location?.addressString)
    }

    /// Perform the initial setup of map
    open func initialLoad() {
        guard let mapView = self.mapView else { return }
        if let coordinate = viewModel.coordinate {
            updateRegion(for: coordinate)

            // Drop an initial pin at the location if enabled
            if viewModel.dropsPinAutomatically {
                updatePin(coordinate: coordinate)
            }
            // Trigger reverse geocode if address missing
            viewModel.reverseGeocode(from: coordinate).cauterize()
        } else {
            updateRegion(for: mapView.userLocation.coordinate)
        }
    }

    // MARK: - PRIVATE

    /// The annotation for selected location on map
    private lazy var locationAnnotation: MKPointAnnotation? = {
        let annotation = MKPointAnnotation()
        mapView?.addAnnotation(annotation)
        return annotation
    }()

    private func updateRegion(for coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView?.setRegion(region, animated: true)
    }

    private func updatePin(coordinate: CLLocationCoordinate2D) {
        self.locationAnnotation?.coordinate = coordinate
    }

    @objc private func performLocationSearch(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            if let coordinate = mapView?.convert(point, toCoordinateFrom: mapView) {
                // Reset address string so lookup occurs
                viewModel.location?.addressString = nil

                // Perform lookup and update map and form when done
                viewModel.reverseGeocode(from: coordinate).ensure { [weak self] in
                    guard let `self` = self else { return }
                    self.updatePin(coordinate: coordinate)
                    self.navigationItem.rightBarButtonItem?.isEnabled = self.viewModel.isValid
                    self.reloadForm()
                }.cauterize()
            }
        }
    }
    
    @objc private func didTapCancelButton(sender: UIBarButtonItem) {
        cancelHandler?()
    }
    
    @objc private func didTapDoneButton(sender: UIBarButtonItem) {
        if let location = viewModel.location {
            selectionHandler?(location)
        }
    }
}

extension LocationSelectionMapViewController: MKMapViewDelegate {

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
        // Luke: This is the only solution that seemed to work.
        userLocation.title = ""
    }
}
