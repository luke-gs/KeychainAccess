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

    public init(viewModel: LocationSelectionViewModel) {
        self.viewModel = viewModel
        super.init(layout: StackMapLayout())
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
    }

    override open func construct(builder: FormBuilder) {
        builder.title = "Select Location"
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "LOCATION DETAILS")
        builder += DropDownFormItem(title: "Type")
            .options(["Event Location"])
            .selectedValue(["Event Location"])
            .required()
        builder += ValueFormItem(title: "Address", value: nil, image: nil)
            .value(viewModel.composeAddress())
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

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

        let location = LocationAnnotation()
        location.coordinate = userLocation.coordinate

        mapView.addAnnotation(location)
        viewModel.reverseGeoCode(location: userLocation.location) {
            self.reloadForm()
        }
    }
}
