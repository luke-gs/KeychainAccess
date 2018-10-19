//
//  EntityLocationInformationViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

public protocol EntityLocationMapDisplayable {
    func mapSummaryDisplayable() -> EntityMapSummaryDisplayable?
}

// TODO: Pretty much copy pasta from other class, should probably refactor.
public class EntityLocationInformationViewController: UIViewController, EntityDetailSectionUpdatable, DraggableCardViewDelegate, MKMapViewDelegate {

    public typealias LocationEntityDetailFormViewModel = EntityDetailFormViewModel & EntityLocationMapDisplayable

    struct LayoutConstants {
        static let defaultMapHeight: CGFloat = 280
        static let minimumCardHeight: CGFloat = 42
    }

    public let viewModel: LocationEntityDetailFormViewModel

    open private(set) var mapViewController: MapViewController!
    open private(set) var formViewController: EntityDetailFormViewController!
    open private(set) var cardView: DraggableCardView!

    // MARK: - Constraints

    open private(set) var cardHeightConstraint: NSLayoutConstraint?
    open private(set) var cardBottomConstraint: NSLayoutConstraint?
    open private(set) var mapCenterYConstraint: NSLayoutConstraint?

    public var entity: MPOLKitEntity? {
        get {
            return viewModel.entity
        }
        set {
            viewModel.entity = newValue as? Entity
        }
    }

    open lazy var loadingManager: LoadingStateManager = {
        return formViewController.loadingManager
    }()

    public init(viewModel: LocationEntityDetailFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        formViewController = EntityDetailFormViewController(viewModel: viewModel)
        // Take the delegate back!! No one is allowed to take it away.
        viewModel.delegate = self
        viewModel.traitCollectionDidChange(traitCollection, previousTraitCollection: nil)

        title = viewModel.title

        let sidebarItem = self.sidebarItem
        sidebarItem.regularTitle =  viewModel.regularTitle
        sidebarItem.compactTitle =  viewModel.compactTitle
        sidebarItem.image =         viewModel.sidebarImage
        sidebarItem.selectedImage = viewModel.sidebarImage
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Minimise card if compact vertical
        if isCompact(.vertical) {
            cardView.currentState = .minimised
            DispatchQueue.main.async {
                // Workaround for Roddy manual layout bug
                self.formViewController.reloadForm()
            }
        }

        // Size the details card and update map controls
        UIView.performWithoutAnimation {
            self.didFinishDragCardView()
            self.updateCardBottomIfInSplit()
        }

        // Dispatch main here to allow VC to be added to parent split
        DispatchQueue.main.async {
            self.updateCardBottomIfInSplit()
        }
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Update card position when view size changes
        coordinator.animate(alongsideTransition: { (_) in
            self.didFinishDragCardView()
        }, completion: nil)
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Update card position when view trait changes, due to compact mode split view behaviour
        self.updateCardBottomIfInSplit()
    }

    /// Creates and styles views
    private func setupViews() {
        edgesForExtendedLayout = []

        view.backgroundColor = .white

        let mapViewController = MapViewController()
        addChildViewController(mapViewController, toView: view)
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        mapViewController.mapView.delegate = self
        self.mapViewController = mapViewController

        cardView = DraggableCardView(frame: .zero)
        cardView.delegate = self
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.dragBar.isHidden = (self.mapViewController == nil)
        view.addSubview(cardView)

        addChildViewController(formViewController, toView: cardView.contentView)
        formViewController.collectionView?.isScrollEnabled = false
    }

    /// Activates view constraints
    private func setupConstraints() {
        guard let formCollectionView = formViewController.collectionView else { return }
        guard let formView = formViewController.view else { return }
        //View holds both the MKMapView and the mapOptionsView
        guard let mapView = mapViewController.view else { return }

        // Change collection view to not use autoresizing mask constraints so it uses intrinsic content height
        formCollectionView.translatesAutoresizingMaskIntoConstraints = false
        formView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            formView.topAnchor.constraint(equalTo: cardView.contentView.topAnchor),
            formView.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor),

            formView.topAnchor.constraint(equalTo: cardView.topAnchor),
            formView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        // Show both map and form
        mapView.translatesAutoresizingMaskIntoConstraints = false
        cardHeightConstraint = cardView.heightAnchor.constraint(equalToConstant: LayoutConstants.minimumCardHeight)
        cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
        mapCenterYConstraint = mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor)

        // Remove existing constraints for map controls by re-adding to view hierarchy
        mapViewController.mapControlView.removeFromSuperview()
        mapViewController.view.addSubview(mapViewController.mapControlView)

        NSLayoutConstraint.activate([
            // Use full size for map even when obscured, so we can manipulate center position without zooming
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2, constant: 0),
            mapCenterYConstraint!,

            // Position map controls relative to our view, not map view which might be off screen
            mapViewController.mapControlView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor, constant: 16),
            mapViewController.mapControlView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor, constant: -16),

            // Position card view at bottom
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardHeightConstraint!,
            cardBottomConstraint!
        ])

    }

    open func updateCardBottomIfInSplit() {
        // Make allowance for compact status change bar (not pretty, but Jase didn't have better idea)
        if let splitViewController = self.pushableSplitViewController as? TaskItemSidebarSplitViewController,
            let compactStatusChangeBar = splitViewController.compactStatusChangeBar {
            self.cardBottomConstraint?.constant = -compactStatusChangeBar.bounds.height
            self.didFinishDragCardView()
        } else {
            self.cardBottomConstraint?.constant = 0
        }
    }

    // MARK: - Map

    open func updateMapInteraction() {
        if let mapViewController = mapViewController {
            let maximising = cardView.bounds.height > (heightForCardViewInState(.maximised) + heightForCardViewInState(.normal)) / 2
            let enabled = !maximising
            if enabled != mapViewController.mapView.isZoomEnabled {
                UIView.animate(withDuration: 0.3, animations: {
                    mapViewController.mapControlView.alpha = enabled ? 1.0 : 0.0
                    mapViewController.mapView.isZoomEnabled = enabled
                    mapViewController.mapView.isPitchEnabled = enabled
                    mapViewController.mapView.isRotateEnabled = enabled
                    mapViewController.mapView.isScrollEnabled = enabled
                })
            }
        }
    }

    // MARK: - DraggableCardViewDelegate

    public func heightForCardViewInState(_ state: DraggableCardView.CardState) -> CGFloat {
        switch state {
        case .minimised:
            // Fixed size, enough to grab
            return LayoutConstants.minimumCardHeight
        case .normal:
            // 50% of view
            return view.bounds.height * 0.5
        case .maximised:
            if isCompact(.vertical) {
                // Full screen
                return view.bounds.height
            }
            // Almost full screen
            return view.bounds.height - 2 * LayoutConstants.minimumCardHeight
        }
    }

    public func didDragCardView(translation: CGFloat) {
        // Move card to match drag translation
        let preDragHeight = heightForCardViewInState(cardView.currentState)
        cardHeightConstraint?.constant = preDragHeight - translation
        view.layoutIfNeeded()

        // Hide interaction when moving towards being maximised
        self.updateMapInteraction()
    }

    public func didFinishDragCardView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            // Move card to match new state with no translation
            self.didDragCardView(translation: 0)

            // Move map so that it is centered in the remaining space (without changing size)
            self.mapCenterYConstraint?.constant = -(self.cardHeightConstraint?.constant ?? 0) / 2
            self.view.layoutIfNeeded()
        }) { _ in
            // Animate showing or hiding map buttons
            self.updateMapInteraction()
        }
    }

    private func zoom(to mapDisplayable: EntityMapSummaryDisplayable?, animated: Bool) {

        if let mapDisplayable = mapDisplayable, let coordinate = mapDisplayable.coordinate, coordinate != kCLLocationCoordinate2DInvalid {
            mapViewController.zoomAndCenter(to: coordinate, animated: true)
        } else {
            mapViewController.zoomAndCenterToUserLocation(animated: true)
        }

    }

    // MARK: - MKMapViewDelegate

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? EntityMapSummaryAnnotation {

            let pinView: LocationAnnotationView
            let identifier = MapSummaryAnnotationViewIdentifier.single.rawValue
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocationAnnotationView {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            } else {
                pinView = LocationAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            pinView.borderColor = annotation.mapSummaryDisplayable?.borderColor ?? .gray

            return pinView
        }
        return nil
    }
}

extension EntityLocationInformationViewController: EntityDetailFormViewModelDelegate {

    // Just foward it to formViewController. I'm a MANAGER.
    open func updateSidebarItemCount(_ count: UInt?) {
        formViewController.updateSidebarItemCount(count)
    }

    open func updateSidebarAlertColor(_ color: UIColor?) {
        formViewController.updateSidebarAlertColor(color)
    }

    open func updateLoadingState(_ state: LoadingStateManager.State) {
        formViewController.updateLoadingState(state)
    }

    open func reloadData() {
        formViewController.reloadData()

        let mapView = mapViewController.mapView
        mapView.removeAnnotations(mapView.annotations)

        let mapDisplayable = viewModel.mapSummaryDisplayable()
        if let mapDisplayable = mapDisplayable {
            let newAnnotation = EntityMapSummaryAnnotation()
            newAnnotation.mapSummaryDisplayable = mapDisplayable
            mapView.addAnnotation(newAnnotation)
        }
        zoom(to: mapDisplayable, animated: true)
    }

    open func updateNoContentDetails(title: String?, subtitle: String? = nil) {
        formViewController.updateNoContentDetails(title: title, subtitle: subtitle)
    }

    open func updateBarButtonItems() {
        formViewController.updateBarButtonItems()
    }

}
