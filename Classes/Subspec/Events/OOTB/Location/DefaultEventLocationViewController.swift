//
//  DefaultEventLocationViewController.swift
//  MPOLKit
//
//  Created by Kara Valentine on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class DefaultEventLocationViewController: MapFormBuilderViewController, EvaluationObserverable {
    
    weak var report: DefaultLocationReport?

    public init(report: Reportable?) {
        self.report = report as? DefaultLocationReport
        super.init(layout: StackMapLayout())
        report?.evaluator.addObserver(self)
        
        sidebarItem.regularTitle = "Location"
        sidebarItem.compactTitle = "Location"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.location)!
        sidebarItem.color = .red
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
        mapView.isUserInteractionEnabled = false

        requestLocationServices()
    }

    override open func construct(builder: FormBuilder) {
        builder.title = "Locations"
        builder.forceLinearLayout = true

        let viewModel = LocationSelectionViewModel()
        viewModel.delegate = self

        builder += HeaderFormItem(text: "LOCATIONS")
        builder += PickerFormItem(pickerAction: LocationAction(viewModel: viewModel))
            .title("Event location")
            .selectedValue(report?.eventLocation)
            .accessory(ImageAccessoryItem(image: AssetManager.shared.image(forKey: .iconPencil)!))
            .required()
    }
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .green : .red
    }

    //MARK: Private

    private func requestLocationServices() {
        guard CLLocationManager.locationServicesEnabled() else {
            showLocationServicesDisabledPrompt()
            return
        }

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            LocationManager.shared.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationServicesDisabledPrompt()
        default:
            break
        }
    }

    private func showLocationServicesDisabledPrompt() {
        let alertController = UIAlertController(title: "Location Services Disabled",
                                                message: "You need to enable location services in settings.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay",
                                                style: .default))
        AlertQueue.shared.add(alertController)
    }
}

extension DefaultEventLocationViewController: LocationSelectionViewModelDelegate {
    public func didSelect(location: EventLocation) {
        report?.eventLocation = location
        reloadForm()
    }
}

extension DefaultEventLocationViewController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? LocationAnnotation {
            let pinView: LocationAnnotationView
            let identifier = MapSummaryAnnotationViewIdentifier.single.rawValue
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocationAnnotationView {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            } else {
                pinView = LocationAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            return pinView
        }

        return nil
    }

    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(userLocation.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

public class LocationAnnotation: MKPointAnnotation { }

