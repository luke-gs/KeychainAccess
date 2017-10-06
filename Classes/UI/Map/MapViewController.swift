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

    private var locationManager: CLLocationManager?
    private var settingsViewModel = MapSettingsViewModel()
    
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

            // Use layout margin to position legal text above map type button
            let bottomMargin = isMapTypeButtonHidden ? buttonMargin : buttonMargin + userLocationButton.frame.height
            mapView.layoutMargins = UIEdgeInsets(top: 0, left: buttonMargin, bottom: bottomMargin, right: 0)
        }
    }
    
    // MARK: - Setup
    
    public init(withLocationManager locationManager: CLLocationManager?) {
        self.locationManager = locationManager
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        settingsViewModel.delegate = self

        // Use background color for when non safe area is visible
        view.backgroundColor = .white

        mapView = MKMapView()
        mapView.delegate = self
        mapView.userTrackingMode = .none
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        userLocationButton = MapImageButton(frame: CGRect(origin: .zero, size: buttonSize), image: AssetManager.shared.image(forKey: .mapUserLocation))
        userLocationButton.isHidden = isUserLocationButtonHidden
        userLocationButton.translatesAutoresizingMaskIntoConstraints = false
        userLocationButton.addTarget(self, action: #selector(didSelectUserTrackingButton), for: .touchUpInside)
        mapView.addSubview(userLocationButton)
        
        mapTypeButton = MapImageButton(frame: CGRect(origin: .zero, size: buttonSize), image: AssetManager.shared.image(forKey: .info))
        mapTypeButton.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        mapTypeButton.isHidden = isMapTypeButtonHidden
        mapTypeButton.translatesAutoresizingMaskIntoConstraints = false
        mapTypeButton.addTarget(self, action: #selector(showMapTypePopup), for: .touchUpInside)
        mapView.addSubview(mapTypeButton)
        
        setupConstraints()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.zoomAndCenterToUserLocation()
        }
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
            // Make sure buttons are within safe area
            mapTypeButton.bottomAnchor.constraint(equalTo: mapView.safeAreaOrFallbackBottomAnchor, constant: -buttonMargin),
            mapTypeButton.leadingAnchor.constraint(equalTo: mapView.safeAreaOrFallbackLeadingAnchor, constant: buttonMargin),

            userLocationButton.bottomAnchor.constraint(equalTo: mapView.safeAreaOrFallbackBottomAnchor, constant: -buttonMargin),
            userLocationButton.trailingAnchor.constraint(equalTo: mapView.safeAreaOrFallbackTrailingAnchor, constant: -buttonMargin),

            // Make map view fill the view on leading and trailing, even outside safe area so it looks good on iPhone X
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor, constant: -bottomOffset)
        ])
    }
    
    public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        guard userLocationButton != nil else { return }

        let image: UIImage?
        
        switch mode {
        case .none:
            image = AssetManager.shared.image(forKey: .mapUserLocation)
        case .follow:
            image = AssetManager.shared.image(forKey: .mapUserTracking)
        case .followWithHeading:
            image = AssetManager.shared.image(forKey: .mapUserTrackingWithHeading)
        }
        
        UIView.transition(with: userLocationButton, duration: 0.15, options: .transitionCrossDissolve, animations: {
            self.userLocationButton.image = image
        }, completion: nil)
    }

    @objc private func didSelectUserTrackingButton() {
        // Cycle through the user tracking mode enum
        switch mapView.userTrackingMode {
        case .none:
            mapView.setUserTrackingMode(.follow, animated: true)
        case .follow:
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
        case .followWithHeading:
            mapView.setUserTrackingMode(.none, animated: true)
        }
    }
    
    @objc func showMapTypePopup() {
        let mapSettingsViewController = MapSettingsViewController(viewModel: settingsViewModel)
        let mapSettingsNavController = PopoverNavigationController(rootViewController: mapSettingsViewController)
        mapSettingsNavController.modalPresentationStyle = .formSheet
        
        present(mapSettingsNavController, animated: true, completion: nil)
    }

    /// Centers the map to the user's location. Note: this method does not zoom.
    public func centerToUserLocation() {
        if let coordinate = locationManager?.location?.coordinate {
            mapView.setCenter(coordinate, animated: true)
        }
    }
    
    /// Centers and zooms the map to the user's location
    @objc public func zoomAndCenterToUserLocation() {
        centerToUserLocation()
        if let coordinate = locationManager?.location?.coordinate {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, defaultZoomDistance, defaultZoomDistance)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
}

extension MapViewController: MapSettingsViewModelDelegate {
    public func modeDidChange() {
        mapView.mapType = settingsViewModel.mode
        mapView.showsTraffic = settingsViewModel.isTrafficEnabled()
    }
}
