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

        builder += HeaderFormItem(text: "LOCATIONS")
        builder += ValueFormItem(title: "Event Location", value: nil, image: nil)
            .value(composeAddress())
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

    private func reverseGeoCode(location: CLLocation?) {
        guard let location = location else { return }
        LocationManager.shared.requestPlacemark(from: location).then { (placemark) -> Void in
            self.report?.eventLocation = EventLocation(latitude: placemark.location?.coordinate.latitude,
                                                       longitude: placemark.location?.coordinate.longitude,
                                                       altitude: placemark.location?.altitude,
                                                       horizontalAccuracy: placemark.location?.horizontalAccuracy,
                                                       verticalAccuracy: placemark.location?.verticalAccuracy,
                                                       speed: placemark.location?.speed,
                                                       course: placemark.location?.course,
                                                       timestamp: placemark.location?.timestamp)
            self.report?.eventPlacemark = placemark
            self.reloadForm()
            }.catch { _ in }
    }

    private func composeAddress() -> String {
        guard let dictionary = report?.eventPlacemark?.addressDictionary else { return "-" }
        guard let formattedAddress = dictionary["FormattedAddressLines"] as? [String] else { return "-" }

        let fullAddress = formattedAddress.reduce("") { result, string  in
            return result + "\(string) "
        }

        return fullAddress
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

        let location = LocationAnnotation()
        location.coordinate = userLocation.coordinate

        mapView.addAnnotation(location)
        reverseGeoCode(location: userLocation.location)
    }
}

fileprivate class LocationAnnotation: MKPointAnnotation { }
