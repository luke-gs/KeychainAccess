//
//  MapFormBuilderCollectionViewDraggableCardLayout.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MapKit


open class MapFormBuilderCollectionViewDraggableCardLayout: MapFormBuilderViewLayout {

    // MARK: - Private properties
    private var cardView: DraggableCardView!
    private var cardBottomConstraint: NSLayoutConstraint?
    private var cardHeightConstraint: NSLayoutConstraint?
    private var formHeightConstraint: NSLayoutConstraint?
    private var mapCenterYConstraint: NSLayoutConstraint?

    var minCardHeight: CGFloat = 42 {
        didSet {
            if cardView.currentState == .minimised {
                cardHeightConstraint?.constant = minCardHeight
            }
        }
    }

    public var view: UIView!

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        guard let controller = controller as? SearchResultMapViewController, let searchFieldButton = controller.searchFieldButton else { return }

        view = controller.view!

        var constraints: [NSLayoutConstraint] = []

        let collectionView = controller.collectionView!
        let mapView = controller.mapView!
        mapView.frame = view.bounds
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        if let accessoryView = controller.accessoryView {
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(accessoryView)

            constraints += [
                accessoryView.topAnchor.constraint(equalTo: searchFieldButton.bottomAnchor, constant: 16.0),
                accessoryView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            ]
        }

        cardView = DraggableCardView(frame: view.frame)
        cardView.delegate = self
        cardView.translatesAutoresizingMaskIntoConstraints = false

        cardView.enabledStates = [.minimised, .normal, .maximised]
        view.addSubview(cardView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        cardView.contentView.addSubview(collectionView)

        cardHeightConstraint = cardView.heightAnchor.constraint(equalToConstant: minCardHeight)
        formHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)

        if #available(iOS 11, *) {
            cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
        } else {
            let offset = controller.legacy_additionalSafeAreaInsets.bottom
            cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(offset))
        }

        mapCenterYConstraint = mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor)

        constraints += [
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2, constant: 0),
            mapCenterYConstraint!,

            collectionView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: cardView.contentView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor),
            formHeightConstraint!,

            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardBottomConstraint!,
            cardHeightConstraint!
        ]

        NSLayoutConstraint.activate(constraints)
    }

    open override func viewDidLayoutSubviews() -> Bool {
        // Update the form collection view height to match the content
        formHeightConstraint?.constant = controller?.collectionView?.contentSize.height ?? 0

        updateMinCardHeight()
        return true
    }

    private func updateMinCardHeight() {
        let firstHeaderIndexPath = IndexPath(row: 0, section: 0)
        guard let sectionHeader = controller?.collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: firstHeaderIndexPath) else { return }
        let sectionHeaderHeight = sectionHeader.bounds.height
        if minCardHeight != sectionHeaderHeight && sectionHeaderHeight > 0 {
            minCardHeight = sectionHeaderHeight
        }
    }

}

extension MapFormBuilderCollectionViewDraggableCardLayout: LocationSearchCollectionViewDelegate {

    public var isShowing: Bool {
        return cardView?.isHidden ?? false
    }

    @objc public func hideSidebar() {
        cardView?.isHidden = true
        cardView?.currentState = .minimised
    }

    @objc public func showSidebar() {
        cardView?.isHidden = false
        cardView?.currentState = .normal
        cardView?.delegate?.didFinishDragCardView()
    }
}

// MARK: - DraggableCardViewDelegate
extension MapFormBuilderCollectionViewDraggableCardLayout: DraggableCardViewDelegate {

    public func heightForCardViewInState(_ state: DraggableCardView.CardState) -> CGFloat {
        switch state {
        case .minimised:
            // Fixed size, enough to grab
            return minCardHeight
        case .normal:
            // 50% of view
            return view.bounds.height * 0.5
        case .maximised:
            // Almost full screen, showing some of map when enough space
            let fullScreenHeight: CGFloat
            if #available(iOS 11, *) {
                fullScreenHeight = view.bounds.height  - view.safeAreaInsets.top - view.safeAreaInsets.bottom
            } else {
                fullScreenHeight = view.bounds.height - (controller?.legacy_additionalSafeAreaInsets.top ?? 0) - (controller?.legacy_additionalSafeAreaInsets.bottom ?? 0)
            }
            return fullScreenHeight - 16
        }
    }

    public func didDragCardView(translation: CGFloat) {
        // Move card to match drag translation
        let preDragHeight = heightForCardViewInState(cardView.currentState)
        cardHeightConstraint?.constant = preDragHeight - translation
        view.layoutIfNeeded()
    }

    public func didFinishDragCardView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            // Move card to match new state with no translation
            self.didDragCardView(translation: 0)
            // Move map so that it is centered in the remaining space (without changing size)
            self.mapCenterYConstraint?.constant = -(self.cardHeightConstraint?.constant ?? 0) / 2
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
