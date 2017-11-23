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

    private var isInitialViewLoad: Bool = true
    
    private let locationManager = LocationManager.shared
    private let zoomsToUserLocationOnLoad: Bool
    private let settingsViewModel: MapSettingsViewModel
    
    // MARK: - Constants
    
    private let buttonSize = CGSize(width: 48, height: 96)
    private let buttonMargin: CGFloat = 16
    private let dividerHeight: CGFloat = 1
    
    // MARK: - Views
    
    open private(set) var mapView: MKMapView!
    
    private var buttonPill: UIView!
    private var buttonDivider: UIView!
    private var userLocationButton: UIButton!
    private var mapTypeButton: UIButton!
    
    // MARK: - Properties
    
    /// The default zoom distance to use when showing the user location
    open var defaultZoomDistance: CLLocationDistance = 3000
    
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
    
    public init(zoomsToUserLocationOnLoad: Bool = true, settingsViewModel: MapSettingsViewModel = MapSettingsViewModel()) {
        self.zoomsToUserLocationOnLoad = zoomsToUserLocationOnLoad
        self.settingsViewModel = settingsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        settingsViewModel.delegate = self
        
        edgesForExtendedLayout = []

        // Use background color for when non safe area is visible
        view.backgroundColor = .white
        
        mapView = MKMapView()
        mapView.delegate = self
        mapView.userTrackingMode = .none
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        buttonPill = UIView()
        buttonPill.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        buttonPill.layer.shadowRadius = 4
        buttonPill.layer.shadowOffset = CGSize(width: 0, height: 2)
        buttonPill.layer.cornerRadius = 8
        buttonPill.layer.shadowOpacity = 1
        buttonPill.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        buttonPill.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonPill)
        
        buttonDivider = UIView()
        buttonDivider.backgroundColor = #colorLiteral(red: 0.8549019608, green: 0.8549019608, blue: 0.8470588235, alpha: 1)
        buttonDivider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonDivider)

        userLocationButton = UIButton()
        userLocationButton.setImage(AssetManager.shared.image(forKey: .mapUserLocation), for: .normal)
        userLocationButton.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        userLocationButton.translatesAutoresizingMaskIntoConstraints = false
        userLocationButton.addTarget(self, action: #selector(didSelectUserTrackingButton), for: .touchUpInside)
        buttonPill.addSubview(userLocationButton)
        
        mapTypeButton = UIButton()
        mapTypeButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)
        mapTypeButton.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        mapTypeButton.isHidden = isMapTypeButtonHidden
        mapTypeButton.translatesAutoresizingMaskIntoConstraints = false
        mapTypeButton.addTarget(self, action: #selector(showMapTypePopup), for: .touchUpInside)
        buttonPill.addSubview(mapTypeButton)
        
        setupConstraints()
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isInitialViewLoad {
            isInitialViewLoad = false
            if zoomsToUserLocationOnLoad {
                _ = locationManager.requestLocation().then { location in
                    self.zoomAndCenterToUserLocation()
                }
            }
        }
    }
    
    /// Activates the constraints for the views
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonPill.heightAnchor.constraint(equalToConstant: buttonSize.height),
            buttonPill.widthAnchor.constraint(equalToConstant: buttonSize.width),
            buttonPill.topAnchor.constraint(equalTo: mapView.safeAreaOrFallbackTopAnchor, constant: buttonMargin),
            buttonPill.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -buttonMargin),
            
            userLocationButton.topAnchor.constraint(equalTo: buttonPill.topAnchor),
            userLocationButton.leadingAnchor.constraint(equalTo: buttonPill.leadingAnchor),
            userLocationButton.trailingAnchor.constraint(equalTo: buttonPill.trailingAnchor),
            userLocationButton.heightAnchor.constraint(equalToConstant: buttonSize.height / 2),
            
            buttonDivider.topAnchor.constraint(equalTo: userLocationButton.bottomAnchor),
            buttonDivider.leadingAnchor.constraint(equalTo: buttonPill.leadingAnchor),
            buttonDivider.trailingAnchor.constraint(equalTo: buttonPill.trailingAnchor),
            buttonDivider.heightAnchor.constraint(equalToConstant: dividerHeight),
            
            mapTypeButton.topAnchor.constraint(equalTo: buttonDivider.bottomAnchor),
            mapTypeButton.leadingAnchor.constraint(equalTo: buttonPill.leadingAnchor),
            mapTypeButton.trailingAnchor.constraint(equalTo: buttonPill.trailingAnchor),
            mapTypeButton.heightAnchor.constraint(equalToConstant: buttonSize.height / 2 - 1),
            mapTypeButton.bottomAnchor.constraint(equalTo: buttonPill.bottomAnchor),

            // Make map view fill the view on leading and trailing, even outside safe area so it looks good on iPhone X
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).withPriority(.almostRequired),
            mapView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
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
            self.userLocationButton.setImage(image, for: .normal)
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
        let mapSettingsViewController = settingsViewModel.settingsViewController()
        let mapSettingsNavController = PopoverNavigationController(rootViewController: mapSettingsViewController)
        mapSettingsNavController.modalPresentationStyle = .formSheet
        
        present(mapSettingsNavController, animated: true, completion: nil)
    }

    /// Centers the map to the user's location. Note: this method does not zoom.
    public func centerToUserLocation() {
        if let coordinate = locationManager.lastLocation?.coordinate {
            mapView.setCenter(coordinate, animated: true)
        }
    }
    
    /// Centers and zooms the map to the user's location
    @objc public func zoomAndCenterToUserLocation() {
        if let location = locationManager.lastLocation {
            zoomAndCenter(to: location)
        }
    }
    
    /// Centers and zooms the map to a location
    public func zoomAndCenter(to location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, defaultZoomDistance, defaultZoomDistance)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MapViewController: MapSettingsViewModelDelegate {
    public func modeDidChange(to mode: MKMapType, showsTraffic: Bool) {
        mapView.mapType = mode
        // Toggle to fix stupid bug where traffic sometimes does not show. Thanks Apple.
        mapView.showsTraffic = false
        mapView.showsTraffic = showsTraffic
    }
}
