//
//  MapFormBuilderCollectionViewSideBarLayout.swift
//  Pods
//
//  Created by RUI WANG on 4/9/17.
//
//

import Foundation
import MapKit

public protocol LocationSearchCollectionViewDelegate {
    var isShowing: Bool { get }
    func hideSidebar()
    func showSidebar()
}

open class MapFormBuilderCollectionViewSideBarLayout: MapFormBuilderViewLayout {
    
    /// A floating point value indicating how much of the view should be used to
    /// display the sidebar when in a regular size class. This will be limited to
    /// the `minimumSidebarWidth` value. The default is proportional to a 320 point
    /// width on a 9.7" iPad.
    open var preferredSidebarWidthFraction: CGFloat = 320.0 / 1024.0
    
    
    /// A floating point value indicating the minimum width of the sidebar in a
    /// regular size class. The default is 288 points.
    open var minimumSidebarWidth: CGFloat = 288.0
    
    private var sideBarWidth: CGFloat {
        return view.frame.width * preferredSidebarWidthFraction
    }

    // MARK: - Private properties
    
    private var sidebarLayoutGuide: UILayoutGuide?
    
    private var sidebarshadowView: UIView?
    
    private var sidebarMinimumWidthConstraint: NSLayoutConstraint?
    
    private var sidebarPreferredWidthConstraint: NSLayoutConstraint?

    public var sidebarLayoutGuideLeadingConstraint: NSLayoutConstraint? {
        didSet {
            if oldValue != sidebarLayoutGuideLeadingConstraint {
                self.controller?.viewIfLoaded?.layoutIfNeeded()
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
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        let shadowBackground = UIView(frame: .zero)
        shadowBackground.translatesAutoresizingMaskIntoConstraints = false
        shadowBackground.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        view.addSubview(shadowBackground)

        let layer = shadowBackground.layer
        layer.cornerRadius = 8.0
        layer.shadowRadius = 4.0
        layer.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false

        if let accessoryView = controller.accessoryView {
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(accessoryView)

            constraints += [
                accessoryView.topAnchor.constraint(equalTo: searchFieldButton.bottomAnchor, constant: 16.0),
                accessoryView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            ]
        }

        collectionView.frame = shadowBackground.frame
        collectionView.layer.cornerRadius = 8.0
        collectionView.layer.shadowRadius = 4.0
        shadowBackground.addSubview(collectionView)

        self.sidebarshadowView = shadowBackground

        let sidebarLayoutGuide = UILayoutGuide()
        self.sidebarLayoutGuide = sidebarLayoutGuide
        view.addLayoutGuide(sidebarLayoutGuide)

        let closeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideSidebar))
        closeGesture.direction = .left
        view.addGestureRecognizer(closeGesture)

        sidebarMinimumWidthConstraint = sidebarLayoutGuide.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumSidebarWidth)
        sidebarPreferredWidthConstraint = sidebarLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: preferredSidebarWidthFraction).withPriority(UILayoutPriority.defaultHigh)
        
        sidebarLayoutGuideLeadingConstraint = sidebarLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -sideBarWidth)

        constraints += [
            sidebarLayoutGuideLeadingConstraint!,
            sidebarLayoutGuide.topAnchor.constraint(equalTo: searchFieldButton.bottomAnchor, constant: 16.0),
            sidebarLayoutGuide.bottomAnchor.constraint(equalTo: controller.bottomLayoutGuide.topAnchor, constant: -16.0),
            sidebarMinimumWidthConstraint!,
            sidebarPreferredWidthConstraint!,

            shadowBackground.topAnchor.constraint(equalTo: sidebarLayoutGuide.topAnchor),
            shadowBackground.bottomAnchor.constraint(equalTo: sidebarLayoutGuide.bottomAnchor),
            shadowBackground.leadingAnchor.constraint(equalTo: sidebarLayoutGuide.leadingAnchor),
            shadowBackground.trailingAnchor.constraint(equalTo: sidebarLayoutGuide.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

    open override func viewDidLayoutSubviews() -> Bool {
        if let collectionView = controller?.collectionView, let mapView = controller?.mapView {
            let rect = collectionView.convert(collectionView.bounds, to: mapView)
            mapView.layoutMargins = UIEdgeInsetsMake(0.0, rect.maxX, 0.0, 0.0)
        }
        return false
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
}

extension MapFormBuilderCollectionViewSideBarLayout: LocationSearchCollectionViewDelegate {

    public var isShowing: Bool {
        return sidebarLayoutGuideLeadingConstraint?.constant == 16.0
    }

    @objc public func hideSidebar() {
        sidebarLayoutGuideLeadingConstraint?.constant = -sideBarWidth
        sidebarshadowView?.isHidden = true
    }

    @objc public func showSidebar() {
        sidebarLayoutGuideLeadingConstraint?.constant = 16.0
        sidebarshadowView?.isHidden = false
    }
}
