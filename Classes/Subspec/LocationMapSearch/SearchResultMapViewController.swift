//
//  SearchResultMapViewController.swift
//  MPOL
//
//  Created by RUI WANG on 1/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
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
    
    public var selectedLocation: CLLocation? {
        didSet {
            if oldValue != selectedLocation {
                guard let selectedLocation = selectedLocation else {
                    resetLocationDetailView()
                    searchFieldPlaceholder = nil
                    return
                }
                
                let entity = viewModel?.entity(for: selectedLocation.coordinate)
                searchFieldPlaceholder = entity?.title
            }
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
    
    public init() {
        super.init(layout: LocationSearchMapCollectionViewSideBarLayout())
        title = NSLocalizedString("Location Search", comment: "Location Search Title")
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        let searchFieldButton = SearchFieldButton(frame: .zero)
        searchFieldButton.placeholder = searchFieldPlaceholder
        searchFieldButton.translatesAutoresizingMaskIntoConstraints = false
        searchFieldButton.titleLabel?.font = .systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        searchFieldButton.addTarget(self, action: #selector(searchFieldButtonDidSelect), for: .primaryActionTriggered)
        self.searchFieldButton = searchFieldButton
        
        guard let mapView = self.mapView, let collectionView = self.collectionView else { return }
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        trackMyLocation()

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(performRadiusSearchOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPressGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action:#selector(resetLocationDetailView))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.delegate = self
        mapView.addGestureRecognizer(singleTapGesture)
        
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(EntityListCollectionViewCell.self)
        collectionView.register(LocationMapDirectionCollectionViewCell.self)
        
        super.viewDidLoad()
    }
    
    override open func viewDidLayoutSubviews() {
        let insets: UIEdgeInsets = .zero
        collectionViewInsetManager?.standardContentInset   = insets
        collectionViewInsetManager?.standardIndicatorInset = insets
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
        return (viewModel?.results.count ?? 0) > 0 ? 1 : 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let result = viewModel?.results[section] {
            switch result.state {
            case .finished where result.error != nil:
                return 0
            case .finished:
                if section == 0 {
                    return 2
                } else {
                    return result.entities.count
                }
            default:
                break
            }
            return 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let entity = viewModel!.results[indexPath.section].entities[indexPath.item]
        delegate?.searchResultsController(self, didSelectEntity: entity)
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
        let entity = viewModel!.entity(for: selectedLocation!.coordinate)!
        
        if indexPath.item == LocationOverview.detail.rawValue {
            let cell = collectionView.dequeueReusableCell(of: EntityListCollectionViewCell.self, for: indexPath)
            cell.decorate(with: entity )
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(of: LocationMapDirectionCollectionViewCell.self, for: indexPath)
        cell.decorate(with: entity )
        
        // TODO: Wrap it into VM without expose plugin?
        if let destination = selectedLocation, let currentLocation = mapView?.userLocation.location {
            viewModel?.travelEstimationPlugin.calculateDistance(from: currentLocation, to: destination, completionHandler: { (distance) in
                DispatchQueue.main.async {
                    cell.distanceLabel.text = distance
                }
            })
            
            viewModel?.travelEstimationPlugin.calculateETA(from: currentLocation, to: destination, transportType: .walking, completionHandler: { (estimateTime) in
                DispatchQueue.main.async {
                    cell.walkingEstButton.bottomLabel.text = estimateTime
                }
            })
            
            viewModel?.travelEstimationPlugin.calculateETA(from: currentLocation, to: destination, transportType: .automobile, completionHandler: { (estimateTime) in
                DispatchQueue.main.async {
                    cell.automobileEstButton.bottomLabel.text = estimateTime
                }
            })
        }
        // FIXME: Move it to VM
        cell.streetViewButton.bottomLabel.text = "Street View"
        cell.descriptionLabel.textColor = secondaryTextColor
        cell.distanceLabel.textColor = secondaryTextColor
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
            selectedLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            collectionView?.reloadData()
            showLocationDetailView()
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
        var pinView: MKPinAnnotationView
        let identifier = "locationPinAnnotationView"
        
        if annotation is MKPointAnnotation {
            if let dequeueView =  mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeueView.annotation = annotation
                pinView = dequeueView
            } else {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView.animatesDrop = false
                pinView.canShowCallout = true
                
                if let entity = viewModel?.entity(for: annotation.coordinate), let image = entity.mapAnnotationThumbnail() {
                    pinView.leftCalloutAccessoryView = UIImageView(image: image)
                }
            }
            
            return pinView
        }
        
        return nil
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
        if let _ = selectedLocation {
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
        
        switch type {
        case .radiusSearch(let coordinate, let radius):
            radiusCircleOverlay = MKCircle(center: coordinate, radius: radius)
            mapView?.add(radiusCircleOverlay!)
        }
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
        selectedLocation = nil
        setMapRegion()
        drawMapOverlays()
        addAnnotations()
    }
    
    /// Center the map region to the search location
    private func setMapRegion() {
        guard let type = viewModel?.searchType else { return }
        
        var region: MKCoordinateRegion
        switch type {
        case .radiusSearch(let coordinate, let radius):
            let distance = radius * 2.0 + 100.0
            region = MKCoordinateRegionMakeWithDistance(coordinate, distance, distance)
        }
        mapView?.setRegion(region, animated: true)
        
    }
    
    /// Add annotations based on the location search results
    private func addAnnotations() {
        
        /// Remove all the existing annotations, except current user location
        if let annotations = mapView?.annotations {
            let anotationsToRemove = annotations.filter { !($0 is MKUserLocation) }
            mapView?.removeAnnotations(anotationsToRemove)
        }
        guard let results = viewModel?.results, let locationResult = results.first, !locationResult.entities.isEmpty else {
            return
        }
        
        let annotations = locationResult.entities.flatMap {
            viewModel?.mapAnnotation(for: $0)
        }
        mapView?.addAnnotations(annotations)
    }
    
    /// long press on the map to perform a radius search using default settings
    @objc
    private func performRadiusSearchOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            if let coordinate = mapView?.convert(point, toCoordinateFrom: mapView) {
                let radiusSearch = LocationMapSearchType.make.radiusSearch(coordinate: coordinate)
                viewModel?.fetchResults(with: radiusSearch)
            }
        }
    }
    
    /// Show & dimiss the sidebar detailed view
    @objc
    private func resetLocationDetailView() {
        (layout as! LocationSearchMapCollectionViewSideBarLayout).resetSideBar()
    }
    
    @objc
    private func showLocationDetailView() {
        (layout as! LocationSearchMapCollectionViewSideBarLayout).showSideBar()
    }
    
}
