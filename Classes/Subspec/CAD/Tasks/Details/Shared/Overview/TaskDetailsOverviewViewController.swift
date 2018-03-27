//
//  TaskDetailsOverviewViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class TaskDetailsOverviewViewController: UIViewController {

    open let viewModel: TaskDetailsOverviewViewModel

    open private(set) var mapViewController: MapViewController?
    open private(set) var formViewController: FormBuilderViewController!
    open private(set) var cardView: DraggableCardView!
    open private(set) var mapHeightConstraint: NSLayoutConstraint?

    fileprivate struct LayoutConstants {
        static let defaultMapHeight: CGFloat = 280
        static let minimumCardHeight: CGFloat = 32
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
    
    /// Creates and styles views
    private func setupViews() {
        edgesForExtendedLayout = []
        
        view.backgroundColor = .white

        if let mapViewModel = viewModel.mapViewModel() {
            let mapViewController = mapViewModel.createViewController()
            addChildViewController(mapViewController, toView: view)
            mapViewController.showsMapButtons = false
            mapViewController.mapView.isZoomEnabled = false
            mapViewController.mapView.isPitchEnabled = false
            mapViewController.mapView.isRotateEnabled = false
            mapViewController.mapView.isScrollEnabled = false
            self.mapViewController = mapViewController
        }

        cardView = DraggableCardView(frame: .zero)
        cardView.delegate = self
        cardView.translatesAutoresizingMaskIntoConstraints = false
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

        if let mapView = mapView {
            // Show both map and form
            mapView.translatesAutoresizingMaskIntoConstraints = false
            mapHeightConstraint = mapView.heightAnchor.constraint(equalToConstant: LayoutConstants.defaultMapHeight)

            NSLayoutConstraint.activate([
                mapView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
                mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                mapView.widthAnchor.constraint(equalTo: view.widthAnchor),
                mapHeightConstraint!,

                cardView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
                cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                cardView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
                cardView.widthAnchor.constraint(equalTo: view.widthAnchor),
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
}

// MARK: - CADFormCollectionViewModelDelegate
extension TaskDetailsOverviewViewController: CADFormCollectionViewModelDelegate {
    
    public func sectionsUpdated() {
        // Reload content
        formViewController.reloadForm()
    }
}

extension TaskDetailsOverviewViewController: DraggableCardViewDelegate {

    var bottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaInsets.bottom
        } else {
            return bottomLayoutGuide.length
        }
    }

    public func didDragView(offset: CGFloat) {
        if cardView.isShowing {
            mapHeightConstraint?.constant = LayoutConstants.defaultMapHeight + offset
        } else {
            mapHeightConstraint?.constant = self.view.bounds.height - bottomInset - LayoutConstants.minimumCardHeight + offset
        }
    }

    public func didHideView() {
        UIView.animate(withDuration: 0.25) {
            self.mapHeightConstraint?.constant = self.view.bounds.height - self.bottomInset - LayoutConstants.minimumCardHeight
            self.view.layoutIfNeeded()
        }
    }

    public func didShowView() {
        UIView.animate(withDuration: 0.25) {
            self.mapHeightConstraint?.constant = LayoutConstants.defaultMapHeight
            self.view.layoutIfNeeded()
        }
    }
}
