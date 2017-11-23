//
//  SearchResultMapViewController.swift
//  MPOL
//
//  Created by RUI WANG on 1/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol LocationMapSearchDelegate: class {
    func locationMapViewController(_ controller: UIViewController, didRequestToEdit search: Searchable?)
    func searchResultsController(_ controller: UIViewController, didSelectEntity entity: MPOLKitEntity)
}

open class SearchResultMapViewController: MapCollectionViewController, MapResultViewModelDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    
    private enum LocationOverview: Int {
        case detail
        case direction
    }
    
    public var viewModel: MapResultViewModelable? {
        didSet {
            cleanAndRefreshMapView()
            viewModel?.delegate = self
        }
    }
    
    weak var delegate: LocationMapSearchDelegate?
    var sidebarDelegate: LocationSearchSidebarDelegate?

    public var selectedAnnotation: MKAnnotation? {
        didSet {
            guard let selectedAnnotation = selectedAnnotation else {
                sidebarDelegate?.hideSidebar(adjustMapInsets: true)
                searchFieldPlaceholder = nil
                return
            }

            let entity = viewModel?.entityDisplayable(for: selectedAnnotation)
            searchFieldPlaceholder = entity?.title
        }
    }
    
    public var radiusCircleOverlay: MKCircle?
    
    public lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0
        return locationManager
    }()

    public var searchFieldPlaceholder: String? = "" {
        didSet {
            searchFieldButton?.placeholder = searchFieldPlaceholder
        }
    }
    
    public init(layout: LocationSearchMapCollectionViewSideBarLayout = LocationSearchMapCollectionViewSideBarLayout()) {
        super.init(layout: layout)
        sidebarDelegate = layout
        title = NSLocalizedString("Location Search", comment: "Location Search Title")
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        let searchFieldButton = SearchFieldButton(frame: .zero)
        searchFieldButton.placeholder = searchFieldPlaceholder
        searchFieldButton.translatesAutoresizingMaskIntoConstraints = false
        searchFieldButton.titleLabel?.font = .systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        searchFieldButton.addTarget(self, action: #selector(searchFieldButtonDidSelect), for: .primaryActionTriggered)
        self.searchFieldButton = searchFieldButton

        view.addSubview(searchFieldButton)

        guard let mapView = self.mapView, let collectionView = self.collectionView else { return }
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        trackMyLocation()

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(performRadiusSearchOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)

        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(EntityListCollectionViewCell.self)
        collectionView.register(LocationMapDirectionCollectionViewCell.self)

        NSLayoutConstraint.activate([
            searchFieldButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchFieldButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            constraintAboveSafeAreaOrBelowTopLayout(searchFieldButton)
        ])
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = searchFieldButton?.frame.height ?? 0.0
        } else {
            legacy_additionalSafeAreaInsets.top = searchFieldButton?.frame.height ?? 0.0
        }
    }

    /// Hide the location details view if touches on the map without pin location selected
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            let touchPoint = gestureRecognizer.location(in: gestureRecognizer.view)
            if let subview = mapView!.hitTest(touchPoint, with: nil),
                subview is MKPinAnnotationView {
                return false
            }
        }
        return true
    }
    
    // MARK: - UICollectionViewDataSource methods
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.numberOfSections() ?? 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfItems(in: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        if let selectedAnnotation = selectedAnnotation, let entity = viewModel?.entity(for: selectedAnnotation) {
            delegate?.searchResultsController(self, didSelectEntity: entity)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            let sectionResult = viewModel!.results[indexPath.section]
            header.text = sectionResult.title
            header.isExpanded = true
            header.showsExpandArrow = false
            return header
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let displayable = viewModel!.entityDisplayable(for: selectedAnnotation!)!

        if indexPath.item == LocationOverview.detail.rawValue {
            let cell = collectionView.dequeueReusableCell(of: EntityListCollectionViewCell.self, for: indexPath)
            cell.decorate(with: displayable)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(of: LocationMapDirectionCollectionViewCell.self, for: indexPath)
        cell.decorate(with: displayable)
        cell.streetViewHandler = {

            // Implement google maps handler?
        }

        if let destination = selectedAnnotation, let currentLocation = mapView?.userLocation.location {
            let coordinate = destination.coordinate
            let destinationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            viewModel?.travelEstimationPlugin.calculateDistance(from: currentLocation, to: destinationLocation)
                .then { cell.distanceLabel.text = $0 }
                .catch { _ in cell.distanceLabel.text = "Unknown" }
            viewModel?.travelEstimationPlugin.calculateETA(from: currentLocation, to: destinationLocation, transportType: .walking)
                .then { cell.walkingEstButton.bottomLabel.text = $0 }
                .catch { _ in cell.distanceLabel.text = "Unknown" }
            viewModel?.travelEstimationPlugin.calculateETA(from: currentLocation, to: destinationLocation, transportType: .automobile)
                .then { cell.automobileEstButton.bottomLabel.text = $0 }
                .catch { _ in cell.distanceLabel.text = "Unknown" }
        }
        return cell
    }
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        return collectionView.bounds.width
    }
    
    override open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if indexPath.item == LocationOverview.direction.rawValue {
            return LocationMapDirectionCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
        }
        return EntityListCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
    }
    
    // MapResultViewModelDelegate
    
    public func mapResultViewModelDidUpdateResults(_ viewModel: MapResultViewModelable) {
        cleanAndRefreshMapView()
    }
    
    // MARK: MKMapViewDelegate
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            sidebarDelegate?.showSidebar(adjustMapInsets: selectedAnnotation == nil)
            selectedAnnotation = annotation
            collectionView?.reloadData()
        }
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
            circleRenderer.fillColor = #colorLiteral(red: 0.5782904958, green: 0.8795785133, blue: 1, alpha: 0.15)
            circleRenderer.strokeColor = #colorLiteral(red: 0.4895583987, green: 0.7623061538, blue: 1, alpha: 1)
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return viewModel?.annotationView(for: annotation, in: mapView)
    }
    
    // MARK: CLLocationManagerDelegate

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first else { return }
        
        /// Zoom to the current user location if no specific searchType request at the beginning.
        guard let _ = viewModel?.searchType else {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(userLocation.coordinate, span)
            mapView?.setRegion(region, animated: true)
            return
        }
        
        /// Update ETA information
        if let _ = selectedAnnotation {
            collectionView?.reloadData()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    // MARK: - Private methods
    
    private func trackMyLocation() {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                let alertController = UIAlertController(title: "Location Services Disabled", message: "You need to enable location services in settings.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default))
                AlertQueue.shared.add(alertController)
            }
        } else {
            let alertController = UIAlertController(title: "Location Services Disabled", message: "You need to enable location services in settings.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default))
            AlertQueue.shared.add(alertController)
        }
    }
    
    
    @objc
    private func searchFieldButtonDidSelect() {
        var search: Searchable?
        if let text = searchFieldButton?.placeholder, !text.isEmpty {
            search = Searchable(text: text, type: LocationSearchDataSourceSearchableType)
        }
        delegate?.locationMapViewController(self, didRequestToEdit: search)
    }
    
    private func drawMapOverlays(){
        
        /// Remove all of existing map overlays
        removeMapOverlays()
        guard let type = viewModel?.searchType else { return }
        radiusCircleOverlay = MKCircle(center: type.coordinate, radius: type.radius)
        mapView?.add(radiusCircleOverlay!)
    }
    
    /// Remove existing map overlays.
    /// e.g circle overlays, polygon, polyline, paths etc
    private func removeMapOverlays() {
        if let radiusCircleOverlay = radiusCircleOverlay {
            mapView?.remove(radiusCircleOverlay)
        }
    }
    
    @objc
    private func cleanAndRefreshMapView() {
        selectedAnnotation = nil
        setMapRegion()
        drawMapOverlays()
        addAnnotations()
    }
    
    /// Center the map region to the search location
    private func setMapRegion() {
        guard let mapSearchType = viewModel?.searchType else { return }
        mapView?.setRegion(mapSearchType.region(), animated: true)
    }
    
    /// Add annotations based on the location search results
    private func addAnnotations() {
        /// Remove all the existing annotations, except current user location
        if let annotations = mapView?.annotations {
            let anotationsToRemove = annotations.filter { !($0 is MKUserLocation) }
            mapView?.removeAnnotations(anotationsToRemove)
        }
        if let annotations = viewModel?.allAnnotations {
            mapView?.addAnnotations(annotations)
        }
    }
    
    /// long press on the map to perform a radius search using default settings
    @objc
    private func performRadiusSearchOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            if sidebarDelegate?.isShowing == true {
                sidebarDelegate?.showSidebar(adjustMapInsets: true)
            }

            let point = gesture.location(in: mapView)
            if let coordinate = mapView?.convert(point, toCoordinateFrom: mapView) {
                let radiusSearch = LocationMapSearchType.radiusSearch(from: coordinate)
                viewModel?.fetchResults(with: radiusSearch)
            }
        }
    }
}
