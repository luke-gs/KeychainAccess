//
//  TaskDetailsOverviewViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class TaskDetailsOverviewViewController: UIViewController {

    fileprivate struct LayoutConstants {
        static let defaultMapHeight: CGFloat = 280
        static let minimumCardHeight: CGFloat = 42
    }

    open let viewModel: TaskDetailsOverviewViewModel

    open private(set) var mapViewController: MapViewController?
    open private(set) var formViewController: FormBuilderViewController!
    open private(set) var cardView: DraggableCardView!

    // Layout
    open private(set) var cardHeightConstraint: NSLayoutConstraint?
    open private(set) var cardBottomConstraint: NSLayoutConstraint?
    open private(set) var mapCenterYConstraint: NSLayoutConstraint?

    open var defaultCardHeight: CGFloat {
        let maxCardSize = cardView.scrollView.contentSize.height + 16
        return min(view.bounds.height - LayoutConstants.defaultMapHeight, maxCardSize)
    }

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
        
        setupViews()
        setupConstraints()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Dispatch main here to allow VC to be added to parent split
        DispatchQueue.main.async {
            // Make allowance for compact status change bar
            if let splitViewController = self.pushableSplitViewController as? TaskItemSidebarSplitViewController,
                let compactStatusChangeBar = splitViewController.compactStatusChangeBar {
                self.cardBottomConstraint?.constant = -compactStatusChangeBar.bounds.height
            }
            // Size the details card and update map controls
            self.didUpdateCardView()
        }
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (context) in
            self.didUpdateCardView()
        }, completion: nil)
    }
    
    /// Creates and styles views
    private func setupViews() {
        edgesForExtendedLayout = []
        
        view.backgroundColor = .white

        if let mapViewModel = viewModel.mapViewModel {
            let mapViewController = mapViewModel.createViewController()
            addChildViewController(mapViewController, toView: view)
            mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.mapViewController = mapViewController
        }

        cardView = DraggableCardView(frame: .zero)
        cardView.delegate = self
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.dragBar.isHidden = (self.mapViewController == nil)
        view.addSubview(cardView)

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
            formCollectionView.topAnchor.constraint(equalTo: formView.topAnchor),
            formCollectionView.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            formCollectionView.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            formCollectionView.bottomAnchor.constraint(equalTo: formView.bottomAnchor),

            formView.topAnchor.constraint(equalTo: cardView.contentView.topAnchor),
            formView.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor),
        ])

        if let mapView = mapView, let mapViewController = mapViewController {
            // Show both map and form
            mapView.translatesAutoresizingMaskIntoConstraints = false
            cardHeightConstraint = cardView.heightAnchor.constraint(equalToConstant: defaultCardHeight)
            cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
            mapCenterYConstraint = mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor)

            // Remove existing constraints for map controls by re-adding to view hierarchy
            mapViewController.mapControlView.removeFromSuperview()
            mapViewController.view.addSubview(mapViewController.mapControlView)
            mapViewController.mapControlView.isHidden = true

            NSLayoutConstraint.activate([
                // Use full size for map even when obscured, so we can manipulate center position without zooming
                mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                mapView.heightAnchor.constraint(equalTo: view.heightAnchor),
                mapCenterYConstraint!,

                // Position map controls relative to our view, not map view which might be off screen
                mapViewController.mapControlView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor, constant: 16),
                mapViewController.mapControlView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

                // Position card view at bottom
                cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                cardHeightConstraint!,
                cardBottomConstraint!
            ])
        } else {
            // Show just form
            NSLayoutConstraint.activate([
                cardView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
                cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                cardView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
                cardView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
        }
    }

    open func updateMapInteraction() {
        if let mapViewModel = viewModel.mapViewModel, let mapViewController = mapViewController {
            let enabled = mapViewModel.allowsInteraction() || !cardView.isShowing
            UIView.transition(with: mapViewController.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
                mapViewController.showsMapButtons = enabled
            }, completion: nil)
            mapViewController.mapView.isZoomEnabled = enabled
            mapViewController.mapView.isPitchEnabled = enabled
            mapViewController.mapView.isRotateEnabled = enabled
            mapViewController.mapView.isScrollEnabled = enabled
        }
    }

}

// MARK: - CADFormCollectionViewModelDelegate
extension TaskDetailsOverviewViewController: CADFormCollectionViewModelDelegate {
    
    public func sectionsUpdated() {
        // Reload content
        formViewController.reloadForm()
    }
}

extension TaskDetailsOverviewViewController: DraggableCardViewDelegate {

    public func didDragCardView(translation: CGFloat) {
        // Update card size
        if cardView.isShowing {
            cardHeightConstraint?.constant = defaultCardHeight - translation
        } else {
            cardHeightConstraint?.constant = LayoutConstants.minimumCardHeight - translation
        }
    }

    public func didUpdateCardView() {
        UIView.animate(withDuration: 0.25, animations: {
            // Update card size
            if self.cardView.isShowing {
                self.cardHeightConstraint?.constant = self.defaultCardHeight
            } else {
                self.cardHeightConstraint?.constant = LayoutConstants.minimumCardHeight
            }
            // Move map so that it is centered in the remaining space (without changing size)
            self.mapCenterYConstraint?.constant = -(self.cardHeightConstraint?.constant ?? 0) / 2
            self.view.layoutIfNeeded()
        }) { _ in
            // Animate showing or hiding map buttons
            self.updateMapInteraction()
        }
    }
}
