//
//  TaskDetailsOverviewViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

open class TaskDetailsOverviewViewController: UIViewController, TaskDetailsLoadable {

    public let loadingManager: LoadingStateManager = LoadingStateManager()

    fileprivate struct LayoutConstants {
        static let defaultMapHeight: CGFloat = 280
        static let minimumCardHeight: CGFloat = 42
    }

    public let viewModel: TaskDetailsOverviewViewModel

    private var contentView: UIView = UIView()

    open private(set) var mapViewController: MapViewController?
    open private(set) var formViewController: FormBuilderViewController!
    open private(set) var cardView: DraggableCardView!
    open private(set) weak var containingSplitViewController: PushableSplitViewController?
    open private(set) var cardStateWhenShowingCluster: DraggableCardView.CardState?

    // MARK: - Constraints

    open private(set) var cardHeightConstraint: NSLayoutConstraint?
    open private(set) var cardBottomConstraint: NSLayoutConstraint?
    open private(set) var mapCenterYConstraint: NSLayoutConstraint?

    // MARK: - Setup

    public init(viewModel: TaskDetailsOverviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        title = viewModel.navTitle()
        sidebarItem.image = viewModel.sidebarImage()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        loadingManager.baseView = view
        loadingManager.contentView = contentView
        setupViews()
        setupConstraints()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if mapViewController == nil {
            // Maximise card if no map
            cardView.currentState = .maximised
        } else if isCompact(.vertical) {
            // Minimise card and disable normal state if compact vertical
            cardView.currentState = .minimised
            cardView.enabledStates = [.minimised, .maximised]
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

            // Prevent control center gesture interrupting card gesture while overview visible
            self.containingSplitViewController = self.pushableSplitViewController
            self.containingSplitViewController?.screenEdgesWithoutSystemGestures = [.bottom]
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Restore system gestures, using the the stored SplitViewController here,
        // as pushableSplitViewController generated property will be nil
        containingSplitViewController?.screenEdgesWithoutSystemGestures = []
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
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)

        if let mapViewModel = viewModel.mapViewModel {
            let mapViewController = mapViewModel.createViewController()
            addChildViewController(mapViewController, toView: contentView)
            mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.mapViewController = mapViewController
        }

        // Update card based on cluster popover display
        (mapViewController as? TasksMapViewController)?.clusterDelegate = self

        cardView = DraggableCardView(frame: .zero)
        cardView.delegate = self
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.dragBar.isHidden = (self.mapViewController == nil)
        contentView.addSubview(cardView)

        formViewController = viewModel.createFormViewController()
        addChildViewController(formViewController, toView: cardView.contentView)
        formViewController.collectionView?.isScrollEnabled = false
    }

    /// Activates view constraints
    private func setupConstraints() {
        guard let formCollectionView = formViewController.collectionView else { return }
        guard let formView = formViewController.view else { return }
        let mapView = mapViewController?.view

        // Change collection view to not use autoresizing mask constraints so it uses intrinsic content height
        formCollectionView.translatesAutoresizingMaskIntoConstraints = false
        formView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            formCollectionView.topAnchor.constraint(equalTo: formView.topAnchor),
            formCollectionView.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            formCollectionView.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            formCollectionView.bottomAnchor.constraint(equalTo: formView.bottomAnchor),

            formView.topAnchor.constraint(equalTo: cardView.contentView.topAnchor),
            formView.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor)
        ])

        if let mapView = mapView, let mapViewController = mapViewController {
            // Show both map and form
            mapView.translatesAutoresizingMaskIntoConstraints = false
            cardHeightConstraint = cardView.heightAnchor.constraint(equalToConstant: LayoutConstants.minimumCardHeight)
            cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
            mapCenterYConstraint = mapView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)

            // Remove existing constraints for map controls by re-adding to view hierarchy
            mapViewController.mapControlView.removeFromSuperview()
            mapViewController.view.addSubview(mapViewController.mapControlView)

            NSLayoutConstraint.activate([
                // Use full size for map even when obscured, so we can manipulate center position without zooming
                mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                mapView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 2, constant: 0),
                mapCenterYConstraint!,

                // Position map controls relative to our view, not map view which might be off screen
                mapViewController.mapControlView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
                mapViewController.mapControlView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),

                // Position card view at bottom
                cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                cardHeightConstraint!,
                cardBottomConstraint!
            ])
        } else {
            // Show just form
            NSLayoutConstraint.activate([
                cardView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
                cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                cardView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
                cardView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
            ])
        }
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
        if let mapViewModel = viewModel.mapViewModel, let mapViewController = mapViewController {
            let maximising = cardView.bounds.height > (heightForCardViewInState(.maximised) + heightForCardViewInState(.normal)) / 2
            let enabled = mapViewModel.allowsInteraction() && !maximising
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

}

// MARK: - CADFormCollectionViewModelDelegate
extension TaskDetailsOverviewViewController: CADFormCollectionViewModelDelegate {

    public func sectionsUpdated() {
        // Reload content
        formViewController?.reloadForm()
    }
}

// MARK: - DraggableCardViewDelegate
extension TaskDetailsOverviewViewController: DraggableCardViewDelegate {

    public func heightForCardViewInState(_ state: DraggableCardView.CardState) -> CGFloat {
        switch state {
        case .minimised:
            // Fixed size, enough to grab
            return LayoutConstants.minimumCardHeight
        case .normal:
            // 50% of view
            return view.bounds.height * 0.5
        case .maximised:
            // We cannot use view height for fullscreen, as card may not align to bottom (glass bar view)
            // Instead we use it's maxY to make sure it goes from where it is now up to top
            let fullScreenHeight = cardView.frame.maxY
            if isCompact(.horizontal) || isCompact(.vertical) {
                return fullScreenHeight
            }
            // Almost full screen, showing some of map when enough space
            return fullScreenHeight - 2 * LayoutConstants.minimumCardHeight
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
}

// MARK: - ClusterTasksViewControllerDelegate
extension TaskDetailsOverviewViewController: ClusterTasksViewControllerDelegate {

    public func didShowClusterDetails() {
        // Minimise card when showing cluster popover
        cardStateWhenShowingCluster = cardView.currentState
        if cardView.currentState != .minimised {
            cardView.currentState = .minimised
            didFinishDragCardView()
        }
    }

    public func didCloseClusterDetails() {
        // When dismissing cluster popover, deselect cluster
        if let mapView = mapViewController?.mapView {
            for annotation in mapView.selectedAnnotations {
                mapView.deselectAnnotation(annotation, animated: true)
            }
        }

        // Restore card state when dismissing cluster popover
        if let restoreState = cardStateWhenShowingCluster, restoreState != cardView.currentState {
            cardView.currentState = restoreState
            didFinishDragCardView()
        }
    }
}
