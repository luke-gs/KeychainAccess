//
//  DefaultEventLocationViewController.swift
//  MPOLKit
//
//  Created by Kara Valentine on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

fileprivate extension EvaluatorKey {
    static let eventLocation = EvaluatorKey(rawValue: "eventLocation")
}

open class DefaultEventLocationViewController: MapFormBuilderViewController, EvaluationObserverable {
    
    weak var report: DefaultLocationReport?

    public init(report: Reportable?) {
        self.report = report as? DefaultLocationReport
        super.init(layout: DefaultMapLayout())
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
            .value("\(report?.eventLocation?.name ?? "")")
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
        let alertController = UIAlertController(title: "Location Services Disabled", message: "You need to enable location services in settings.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default))
        AlertQueue.shared.add(alertController)
    }

    private func reverseGeoCode(location: CLLocation?) {
        guard let location = location else { return }
        LocationManager.shared.requestPlacemark(from: location).then { (placemark) -> Void in
            self.report?.eventLocation = placemark
            self.reloadForm()
            }.catch { _ in }
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


public class DefaultMapLayout: MapFormBuilderViewLayout {
    override public func viewDidLoad() {
        guard let controller = controller as? DefaultEventLocationViewController, let mapView = controller.mapView, let collectionView = controller.collectionView else { return }

        controller.view.addSubview(mapView)

        controller.mapView?.translatesAutoresizingMaskIntoConstraints = false
        controller.collectionView?.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        // Horizontal
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[mapView]|", options: [], metrics: nil, views: ["mapView": mapView])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView])

        // Vertical
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[mapView(percentage)][collectionView]|",
                                                      options: [],
                                                      metrics: ["percentage": (controller.view.frame.size.height * 0.4)],
                                                      views: ["collectionView": collectionView, "mapView": mapView, "view": controller.view])

        NSLayoutConstraint.activate(constraints)
    }
}

public class DefaultLocationReport: Reportable {
    
    var eventLocation: CLPlacemark? {
        didSet {
            evaluator.updateEvaluation(for: .eventLocation)
        }
    }
    
    public weak var event: Event?
    public var evaluator: Evaluator = Evaluator()
    
    public required init(event: Event) {
        self.event = event
        
        evaluator.addObserver(event)
        evaluator.registerKey(.eventLocation) {
            return self.eventLocation != nil
        }
    }
    
    // Codable
    
    public required init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        //        eventLocation = try container.decode(CLLocation.self, forKey: .eventLocation)
    }
    
    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: Keys.self)
        //        try container.encode(eventLocation, forKey: .eventLocation)
    }
    
    enum Keys: String, CodingKey {
        case eventLocation = "eventLocation"
    }
    
    // Evaluation
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}

private class LocationAnnotation: MKPointAnnotation {

}
