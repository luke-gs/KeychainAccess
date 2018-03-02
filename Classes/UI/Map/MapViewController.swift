//
//  MapViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 7/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit
import PromiseKit

/// A `UIViewController` subclass implementing `MKMapViewDelegate` which
/// contains a `MKMapView` constrained to the view edges.
open class MapViewController: UIViewController, MKMapViewDelegate {

    /// The zoom style when first loading the map
    ///
    /// - userLocation: zoom to the user's location
    /// - coordinate: zoom to a specified coordinate
    /// - annotations: zoom to display all the annotations
    /// - none: do not zoom on load
    public enum InitialLoadZoomStyle {
        case userLocation(animated: Bool)
        case coordinate(_: CLLocationCoordinate2D, animated: Bool)
        case none
    }
    
    private var performedInitialLoadAction: Bool = false
    
    private let locationManager = LocationManager.shared
    public let initialLoadZoomStyle: InitialLoadZoomStyle
    private let startingRegion: MKCoordinateRegion?
    private let settingsViewModel: MapSettingsViewModel
    
    private var initialLocation: CLLocation?
    
    // MARK: - Constants
    
    private let buttonSize = CGSize(width: 48, height: 96)
    private let buttonMargin: CGFloat = 16
    private let dividerHeight: CGFloat = 1
    
    // MARK: - Views
    
    open private(set) var mapView = MKMapView()

    private var mapControlView: MapControlView!
    
    // MARK: - Properties
    
    /// The default zoom distance to use when showing the user location
    open var defaultZoomDistance: CLLocationDistance = 3000
    
    open var showsMapButtons: Bool = true {
        didSet {
            mapControlView.isHidden = !showsMapButtons
        }
    }
    
    // MARK: - Setup
    
    public init(initialLoadZoomStyle: InitialLoadZoomStyle = .none, startingRegion: MKCoordinateRegion? = nil, settingsViewModel: MapSettingsViewModel = MapSettingsViewModel()) {
        self.initialLoadZoomStyle = initialLoadZoomStyle
        self.settingsViewModel = settingsViewModel
        self.startingRegion = startingRegion
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
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
        
        mapView.delegate = self
        mapView.userTrackingMode = .none
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        if let startingRegion = startingRegion {
            mapView.setRegion(startingRegion, animated: false)
        }
        view.addSubview(mapView)

        mapControlView = MapControlView()
        mapControlView.translatesAutoresizingMaskIntoConstraints = false
        mapControlView.locateButton.addTarget(self, action: #selector(didSelectUserTrackingButton), for: .touchUpInside)
        mapControlView.optionButton.addTarget(self, action: #selector(showMapTypePopup), for: .touchUpInside)
        view.addSubview(mapControlView)

        setupConstraints()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !performedInitialLoadAction {
            switch initialLoadZoomStyle {
            case .userLocation(let animated):
                _ = locationManager.requestLocation().then { location -> () in
                    self.zoomAndCenter(to: location.coordinate, animated: animated)
                }
                performedInitialLoadAction = true
            case .coordinate(let location, let animated):
                zoomAndCenter(to: location, animated: animated)
                performedInitialLoadAction = true
            case .none:
                performedInitialLoadAction = true
            }
        }
    }
    /// Activates the constraints for the views
    private func setupConstraints() {
        NSLayoutConstraint.activate([

            mapControlView.topAnchor.constraint(equalTo: mapView.safeAreaOrFallbackTopAnchor, constant: buttonMargin),
            mapControlView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -buttonMargin),

            // Make map view fill the view on leading and trailing, even outside safe area so it looks good on iPhone X
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
        ])
    }
    
    @objc private func interfaceStyleDidChange() {
        let currentInterfaceStyle = ThemeManager.shared.currentInterfaceStyle
        let isDark = currentInterfaceStyle.isDark
        let theme = ThemeManager.shared.theme(for: currentInterfaceStyle)

        mapView.mpl_setNightModeEnabled(isDark)
        mapControlView.applyTheme(theme, isDark: isDark)
    }
    
    public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        guard mapControlView != nil else { return }

        mapControlView.setUserLocationTrackingMode(mode, animated: true)
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
    public func centerToUserLocation(animated: Bool = true) {
        if let coordinate = locationManager.lastLocation?.coordinate {
            mapView.setCenter(coordinate, animated: animated)
        }
    }
    
    /// Centers and zooms the map to the user's location
    @objc public func zoomAndCenterToUserLocation(animated: Bool = true) {
        if let location = locationManager.lastLocation {
            zoomAndCenter(to: location.coordinate, animated: animated)
        }
    }
    
    /// Centers and zooms the map to a location
    public func zoomAndCenter(to coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, defaultZoomDistance, defaultZoomDistance)
        mapView.setRegion(coordinateRegion, animated: animated)
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
