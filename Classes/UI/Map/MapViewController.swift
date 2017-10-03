//
//  MapViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 7/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

/// A `UIViewController` subclass implementing `MKMapViewDelegate` which
/// contains a `MKMapView` constrained to the view edges.
open class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Constants
    
    private let buttonSize = CGSize(width: 48, height: 48)
    private let buttonMargin: CGFloat = 16
    
    // MARK: - Views
    
    open private(set) var mapView: MKMapView!
    
    private var userLocationButton: MapImageButton!
    private var mapTypeButton: MapImageButton!
    
    // MARK: - Properties
    
    /// The default zoom distance to use when showing the user location
    open var defaultZoomDistance: CLLocationDistance = 800
    
    open var isUserLocationButtonHidden: Bool = true {
        didSet {
            userLocationButton.isHidden = isUserLocationButtonHidden
        }
    }
    open var isMapTypeButtonHidden: Bool = true {
        didSet {
            mapTypeButton.isHidden = isMapTypeButtonHidden
        }
    }
    
    // MARK: - Setup
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView()
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        userLocationButton = MapImageButton(frame: CGRect(origin: .zero, size: buttonSize), image: AssetManager.shared.image(forKey: .mapUserTracking))
        userLocationButton.isHidden = isUserLocationButtonHidden
        userLocationButton.translatesAutoresizingMaskIntoConstraints = false
        userLocationButton.addTarget(self, action: #selector(zoomAndCenterToUserLocation), for: .touchUpInside)
        mapView.addSubview(userLocationButton)
        
        mapTypeButton = MapImageButton(frame: CGRect(origin: .zero, size: buttonSize), image: AssetManager.shared.image(forKey: .info))
        mapTypeButton.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        mapTypeButton.isHidden = isMapTypeButtonHidden
        mapTypeButton.translatesAutoresizingMaskIntoConstraints = false
        // TODO: Add target
        mapView.addSubview(mapTypeButton)
        
        setupConstraints()
    }
    
    /// Activates the constraints for the views
    private func setupConstraints() {

        // Remove once iOS 11+
        let bottomOffset: CGFloat
        if #available(iOS 11, *) {
            bottomOffset = 0.0
        } else {
            // The status tab bar controller cannot set the bottom layout guide on iOS 10, so make allowance for it
            bottomOffset = statusTabBarController?.tabBar.frame.height ?? statusTabBarController?.tabBar.frame.height ?? 0
        }

        NSLayoutConstraint.activate([
            mapTypeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -buttonMargin),
            mapTypeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: buttonMargin),
            mapTypeButton.heightAnchor.constraint(equalToConstant: userLocationButton.frame.height),
            mapTypeButton.widthAnchor.constraint(equalToConstant: userLocationButton.frame.width),
            
            userLocationButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -buttonMargin),
            userLocationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -buttonMargin),
            userLocationButton.heightAnchor.constraint(equalToConstant: mapTypeButton.frame.height),
            userLocationButton.widthAnchor.constraint(equalToConstant: mapTypeButton.frame.width),
            
            mapView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor, constant: -bottomOffset),
        ])
    }

    /// Centers the map to the user's location. Note: this method does not zoom.
    public func centerToUserLocation() {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    /// Centers and zooms the map to the user's location
    public func zoomAndCenterToUserLocation() {
        centerToUserLocation()
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, defaultZoomDistance, defaultZoomDistance)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
