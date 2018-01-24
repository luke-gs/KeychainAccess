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

public class SearchResultMapViewController: MapFormBuilderViewController, MapResultViewModelDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    private enum LocationOverview: Int {
        case detail
        case direction
    }

    public var viewModel: MapResultViewModelable? {
        willSet {
            viewModel?.delegate = nil
        }

        didSet {
            viewModel?.delegate = self

            if isViewLoaded {
                searchFieldButton?.text = viewModel?.title
            }

            cleanAndRefreshMapView()
        }
    }
    
    weak var delegate: SearchDelegate?
    var sidebarDelegate: LocationSearchSidebarDelegate?

    public var selectedAnnotation: MKAnnotation? {
        didSet {
            guard let _ = selectedAnnotation else {
                sidebarDelegate?.hideSidebar(adjustMapInsets: true)
                searchFieldPlaceholder = nil
                return
            }

//            let entity = viewModel?.entityDisplayable(for: selectedAnnotation)
//            searchFieldPlaceholder = entity?.title
        }
    }
    
    public var radiusCircleOverlay: MKCircle?
    
    public lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        return locationManager
    }()

    public var searchFieldPlaceholder: String? = "" {
        didSet {
            searchFieldButton?.placeholder = searchFieldPlaceholder
        }
    }

    internal private(set) var searchFieldButton: SearchFieldButton?
    
    public init(layout: LocationSearchMapCollectionViewSideBarLayout = LocationSearchMapCollectionViewSideBarLayout()) {
        super.init(layout: layout)
        sidebarDelegate = layout
        title = NSLocalizedString("Location Search", comment: "Location Search Title")
        userInterfaceStyle = .light
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public override func loadView() {
        super.loadView()

        let searchFieldButton = SearchFieldButton(frame: .zero)
        searchFieldButton.text = viewModel?.title
        searchFieldButton.placeholder = searchFieldPlaceholder
        searchFieldButton.translatesAutoresizingMaskIntoConstraints = false
        searchFieldButton.addTarget(self, action: #selector(searchFieldButtonDidSelect), for: .primaryActionTriggered)
        self.searchFieldButton = searchFieldButton
        view.addSubview(searchFieldButton)

        NSLayoutConstraint.activate([
            searchFieldButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchFieldButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            constraintAboveSafeAreaOrBelowTopLayout(searchFieldButton)
        ])

        let locateButton = UIButton(type: .system)
        locateButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)

        let optionButton = UIButton(type: .system)
        optionButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)

        let accessoryView = UIView(frame: .zero)
        accessoryView.addSubview(locateButton)
        accessoryView.addSubview(optionButton)
        accessoryView.backgroundColor = .white

        locateButton.translatesAutoresizingMaskIntoConstraints = false
        optionButton.translatesAutoresizingMaskIntoConstraints = false

        let views = ["lb": locateButton, "ob": optionButton]

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[lb(48,==ob)][ob]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[lb(48,==ob)]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints)

        self.accessoryView = accessoryView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        guard let mapView = self.mapView else { return }
        mapView.delegate = self
        mapView.showsUserLocation = true
        requestLocationServices()

        view.bringSubview(toFront: searchFieldButton!)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(performRadiusSearchOnLongPress(gesture:)))
        mapView.addGestureRecognizer(longPressGesture)
        updateSearchText()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

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

    public override func construct(builder: FormBuilder) {
        guard let viewModel = viewModel else { return }
        builder += viewModel.results.flatMap { viewModel.itemsForResultsInSection($0) }
    }

    public override func apply(_ theme: Theme) {
        super.apply(theme)

        guard let searchField = searchFieldButton else { return }

        searchField.backgroundColor = theme.color(forKey: .searchFieldBackground)
        searchField.fieldColor = theme.color(forKey: .searchField)
        searchField.textColor  = theme.color(forKey: .primaryText)
        searchField.placeholderTextColor = theme.color(forKey: .placeholderText)
    }

    // MARK: - Common methods

    public func requestToEdit() {
        delegate?.beginSearch(reset: false)
    }

    public func requestToPresent(_ presentable: Presentable) {
        delegate?.handlePresentable(presentable)
    }

    // MapResultViewModelDelegate
    
    public func mapResultViewModelDidUpdateResults(_ viewModel: MapResultViewModelable) {
        guard isViewLoaded else { return }
        cleanAndRefreshMapView()
    }
    
    // MARK: MKMapViewDelegate
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            sidebarDelegate?.showSidebar(adjustMapInsets: selectedAnnotation == nil)
            selectedAnnotation = annotation
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

    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {

        /// Zoom to the current user location if no specific searchType request at the beginning.
        guard let _ = viewModel?.searchType else {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(userLocation.coordinate, span)
            mapView.setRegion(region, animated: true)
            return
        }

        /// Update ETA information
        if isViewLoaded {
            reloadForm()
        }

    }
    
    // MARK: - Private methods
    
    private func requestLocationServices() {
        guard CLLocationManager.locationServicesEnabled() else {
            showLocationServicesDisabledPrompt()
            return
        }

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationServicesDisabledPrompt()
        default: break
        }
    }

    private func showLocationServicesDisabledPrompt() {
        let alertController = UIAlertController(title: "Location Services Disabled", message: "You need to enable location services in settings.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default))
        AlertQueue.shared.add(alertController)
    }
    
    @objc
    private func searchFieldButtonDidSelect() {

        if let text = searchFieldButton?.placeholder, !text.isEmpty {
            let search = Searchable(text: text, type: LocationSearchDataSourceSearchableType)
            delegate?.beginSearch(with: search)
        } else {
            delegate?.beginSearch(reset: false)
        }
    }

    private func drawMapOverlays() {
        
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
        updateSearchText()
        reloadForm()
    }

    private func updateSearchText() {
        let label = RoundedRectLabel(frame: CGRect(x: 10, y: 10, width: 120, height: 16))
        label.backgroundColor = .clear
        label.borderColor = viewModel?.status?.colour
        label.textColor = viewModel?.status?.colour
        label.text = viewModel?.status?.searchText
        label.cornerRadius = 2.0
        label.sizeToFit()

        searchFieldButton?.accessoryView = label
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
            let annotationsToRemove = annotations.filter { !($0 is MKUserLocation) }
            mapView?.removeAnnotations(annotationsToRemove)
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
                let newModel = viewModel?.searchStrategy.resultModelForSearchOnLocation(withSearchType: radiusSearch)
                self.viewModel = newModel
            }
        }
    }
}
