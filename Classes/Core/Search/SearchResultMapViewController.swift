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
import Cluster

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

    private lazy var mapSettingModel: MapSettingsViewModel = { [unowned self] in
        let model = MapSettingsViewModel()
        model.delegate = self
        return model
    }()
    
    weak var delegate: SearchDelegate?

    var sidebarDelegate: LocationSearchSidebarDelegate?

    public var selectedAnnotation: MKAnnotation? {
        didSet {
            guard selectedAnnotation !== oldValue && isViewLoaded else { return }

            if (selectedAnnotation is ClusterAnnotation) != (oldValue is ClusterAnnotation) {
                reloadForm()
            }
        }
    }
    
    public var radiusCircleOverlay: MKCircle?
    
    public lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        return locationManager
    }()

    internal private(set) var searchFieldButton: SearchFieldButton?

    private var locateButton: UIButton?

    private var optionButton: UIButton?

    private var buttonsSeparator: UIView?

    private let clusterManager: ClusterManager = {
        let clusterManager = ClusterManager()
        clusterManager.cellSize = nil
        clusterManager.maxZoomLevel = 20
        clusterManager.minCountForClustering = 2
        clusterManager.shouldRemoveInvisibleAnnotations = false
        clusterManager.clusterPosition = .average
        return clusterManager
    }()

    // MARK: - Radius Search Properties

    private var radiusButton: UIButton?

    public let radiusOptions: [CLLocationDistance] = [100, 500, 1000]

    public private(set) var selectedRadiusIndex: Int = 0 {
        didSet {
            let distance = distanceFormatter.string(fromDistance: radiusOptions[selectedRadiusIndex])
            radiusButton?.setTitle(distance, for: .normal)
        }
    }

    public let distanceFormatter: MKDistanceFormatter = {
        let formatter = MKDistanceFormatter()
        formatter.units = .metric
        formatter.unitStyle = .abbreviated
        return formatter
    }()

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
        searchFieldButton.placeholder = NSLocalizedString("Search location", comment: "")
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
        locateButton.setImage(AssetManager.shared.image(forKey: .mapUserLocation), for: .normal)
        locateButton.addTarget(self, action: #selector(locateButtonTapped(_:)), for: .touchUpInside)

        let optionButton = UIButton(type: .system)
        optionButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)
        optionButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)

        let separator = UIView()
        separator.backgroundColor = .gray

        self.locateButton = locateButton
        self.optionButton = optionButton
        self.buttonsSeparator = separator

        let mapControlView = UIView(frame: .zero)
        mapControlView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        mapControlView.layer.cornerRadius = 8.0
        mapControlView.layer.shadowRadius = 4.0
        mapControlView.layer.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        mapControlView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        mapControlView.layer.shadowOpacity = 0.1
        mapControlView.addSubview(locateButton)
        mapControlView.addSubview(separator)
        mapControlView.addSubview(optionButton)

        let radiusButton = UIButton(type: .system)
        radiusButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        radiusButton.addTarget(self, action: #selector(radiusButtonTapped(_:)), for: .touchUpInside)
        radiusButton.setTitle(distanceFormatter.string(fromDistance: radiusOptions[selectedRadiusIndex]), for: .normal)
        radiusButton.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        radiusButton.layer.cornerRadius = 24.0
        radiusButton.layer.shadowRadius = 4.0
        radiusButton.layer.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        radiusButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        radiusButton.layer.shadowOpacity = 0.1

        self.radiusButton = radiusButton

        let accessoryView = UIView(frame: .zero)
        accessoryView.addSubview(mapControlView)
        accessoryView.addSubview(radiusButton)

        locateButton.translatesAutoresizingMaskIntoConstraints = false
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        mapControlView.translatesAutoresizingMaskIntoConstraints = false
        radiusButton.translatesAutoresizingMaskIntoConstraints = false

        let views = ["lb": locateButton, "ob": optionButton, "rb": radiusButton, "mv": mapControlView, "sp": separator]
        let metrics = ["size": 48.0, "padding": 16.0, "sw": (1.0 / traitCollection.currentDisplayScale)]

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[lb(size,==ob,==rb)][sp(sw)][ob]|", options: [.alignAllLeading, .alignAllTrailing], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[lb(size)]|", options: [], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[mv]-padding-[rb(size)]|", options: [.alignAllLeading, .alignAllTrailing], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[rb(size)]|", options: [], metrics: metrics, views: views)

        NSLayoutConstraint.activate(constraints)

        self.accessoryView = accessoryView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        guard let mapView = self.mapView else { return }
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = false

        requestLocationServices()

        view.bringSubview(toFront: searchFieldButton!)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(performRadiusSearchOnLongPress(gesture:)))
        mapView.addGestureRecognizer(longPressGesture)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        cleanAndRefreshMapView()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = searchFieldButton?.frame.height ?? 0.0

            if let collectionView = collectionView, let mapView = mapView {
                let rect = collectionView.convert(collectionView.bounds, to: mapView)
                mapView.layoutMargins = UIEdgeInsetsMake(0.0, rect.maxX, 0.0, 0.0)
            }
        } else {
            legacy_additionalSafeAreaInsets.top = searchFieldButton?.frame.height ?? 0.0

            if let collectionView = collectionView, let mapView = mapView {
                let rect = collectionView.convert(collectionView.bounds, to: mapView)
                mapView.layoutMargins = UIEdgeInsetsMake(searchFieldButton!.frame.height, rect.maxX, 0.0, 0.0)
            }
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

        if let selectedAnnotation = selectedAnnotation as? ClusterAnnotation {
            builder += viewModel.itemsForClusteredAnnotations(selectedAnnotation.annotations)
        } else {
            builder += viewModel.results.flatMap { viewModel.itemsForResultsInSection($0) }
        }
    }

    public override func apply(_ theme: Theme) {
        super.apply(theme)

        if let searchField = searchFieldButton {
            searchField.backgroundColor = theme.color(forKey: .searchFieldBackground)
            searchField.fieldColor = theme.color(forKey: .searchField)
            searchField.textColor  = theme.color(forKey: .primaryText)
            searchField.placeholderTextColor = theme.color(forKey: .placeholderText)
        }

        buttonsSeparator?.backgroundColor = theme.color(forKey: .separator)
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
        reloadAnnotations()
        reloadForm()
        reloadSearchText()
    }
    
    // MARK: MKMapViewDelegate

    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        selectedAnnotation = annotation
        viewModel?.annotationViewDidSelect(annotationView: view, in: mapView)
    }

    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        selectedAnnotation = nil
        viewModel?.annotationViewDidDeselect(annotationView: view, in: mapView)
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

    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusterManager.reload(mapView, visibleMapRect: mapView.visibleMapRect)
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
        delegate?.beginSearch(with: Searchable(text: nil, type: LocationSearchDataSourceSearchableType))
    }

    private func reloadMapOverlays() {
        
        /// Remove all of existing map overlays
        removeMapOverlays()
        guard let type = viewModel?.searchType else { return }

        switch type {
        case .radius(let coordinate, let radius):
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
        reloadMapRegion()
        reloadMapOverlays()
        reloadAnnotations()
        reloadSearchText()
        reloadForm()

        if viewModel?.searchType != nil {
            sidebarDelegate?.showSidebar(adjustMapInsets: false)
        } else {
            sidebarDelegate?.hideSidebar(adjustMapInsets: false)
        }
    }

    private func reloadSearchText() {
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
    private func reloadMapRegion() {
        guard let mapView = mapView, let region = viewModel?.searchType?.region else { return }
        mapView.setRegion(region, animated: true)
    }
    
    /// Add annotations based on the location search results
    private func reloadAnnotations() {
        selectedAnnotation = nil

        /// Remove all the existing annotations, except current user location
        clusterManager.removeAll()

        if let annotations = viewModel?.allAnnotations {
            clusterManager.add(annotations)
        }

        if let mapView = mapView {
            mapView.selectedAnnotations = []
            clusterManager.reload(mapView, visibleMapRect: mapView.visibleMapRect)
        }
    }
    
    /// long press on the map to perform a radius search using default settings
    @objc
    private func performRadiusSearchOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            if let coordinate = mapView?.convert(point, toCoordinateFrom: mapView) {
                performRadiusSearchOnCoordinate(coordinate, withRadius: radiusOptions[selectedRadiusIndex])
            }
        }
    }

    // MARK: - Private

    @objc private func locateButtonTapped(_ button: UIButton) {
        guard let mapView = mapView else { return }

        let coordinate = mapView.userLocation.coordinate

        if CLLocationCoordinate2DIsValid(coordinate) {
            mapView.setCenter(coordinate, animated: true)
        }
    }

    @objc private func optionButtonTapped(_ button: UIButton) {
        let viewController = MapSettingsViewController(viewModel: mapSettingModel)

        let navigationController = PopoverNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .popover

        if let presentationController = navigationController.popoverPresentationController {
            presentationController.sourceView = button
            presentationController.sourceRect = button.bounds
        }

        present(navigationController, animated: true, completion: nil)
    }

    @objc private func radiusButtonTapped(_ button: UIButton) {
        let viewController = PickerTableViewController(style: .plain, items: radiusOptions.map { self.distanceFormatter.string(fromDistance: $0) })
        viewController.title = NSLocalizedString("Radius", comment: "")
        viewController.selectedIndexes = IndexSet(integer: selectedRadiusIndex)
        viewController.selectionUpdateHandler = { [unowned self] in
            guard let selectedIndex = $1.first else { return }

            self.selectedRadiusIndex = selectedIndex
            if let coordinate = self.viewModel?.searchType?.coordinate {
                self.performRadiusSearchOnCoordinate(coordinate, withRadius: self.radiusOptions[self.selectedRadiusIndex])
            }
        }

        let navigationController = PopoverNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .popover

        if let presentationController = navigationController.popoverPresentationController {
            presentationController.sourceView = button
            presentationController.sourceRect = button.bounds
        }

        present(navigationController, animated: true, completion: nil)
    }

    private func performRadiusSearchOnCoordinate(_ coordinate: CLLocationCoordinate2D, withRadius radius: CLLocationDistance) {
        let radiusSearch = LocationMapSearchType.radius(coordinate: coordinate, radius: radius)
        let newModel = viewModel?.searchStrategy.resultModelForSearchOnLocation(withSearchType: radiusSearch)
        self.viewModel = newModel
    }

}

extension SearchResultMapViewController: MapSettingsViewModelDelegate {

    public func modeDidChange(to mode: MKMapType, showsTraffic: Bool) {
        guard let mapView = mapView else { return }

        mapView.mapType = mode
        mapView.showsTraffic = showsTraffic
    }

}
