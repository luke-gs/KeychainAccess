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

    var minCardHeight: CGFloat = 42 {
        didSet {
            cardHeightConstraint?.constant = minCardHeight
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
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
        cardView.currentState = .minimised
        view.addSubview(cardView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        cardView.contentView.addSubview(collectionView)

        cardHeightConstraint = cardView.heightAnchor.constraint(equalToConstant: minCardHeight)

        if #available(iOS 11, *) {
            cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
        } else {
            let offset = controller.legacy_additionalSafeAreaInsets.bottom
            cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(offset))
        }

        constraints += [
            collectionView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: cardView.contentView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor),

            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardBottomConstraint!,
            cardHeightConstraint!
        ]

        NSLayoutConstraint.activate(constraints)
    }

    open override func viewDidLayoutSubviews() -> Bool {
        updateMinCardHeight()
        return false
    }

    private func updateMinCardHeight() {
        let collectionViewHeaderHeight = controller?.minimumCardHeight ?? 0

        if minCardHeight != collectionViewHeaderHeight && collectionViewHeaderHeight > 0 {
            minCardHeight = collectionViewHeaderHeight
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

            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
