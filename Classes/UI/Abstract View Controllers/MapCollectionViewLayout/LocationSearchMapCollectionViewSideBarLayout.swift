//
//  LocationSearchMapCollectionViewSideBarLayout.swift
//  Pods
//
//  Created by RUI WANG on 4/9/17.
//
//

import Foundation
import MapKit

public protocol LocationSearchSidebarDelegate {
    var isShowing: Bool { get }
    func hideSidebar(adjustMapInsets: Bool)
    func showSidebar(adjustMapInsets: Bool)
}

open class LocationSearchMapCollectionViewSideBarLayout: MapFormBuilderViewLayout {
    
    /// A boolean value indicating whether the sidebar should display fullscreen
    /// when in regular width environments, hiding the map. The default is `false`.
    open var hidesMapInRegularEnvironment: Bool = false {
        didSet {
            guard hidesMapInRegularEnvironment != oldValue && (controller?.traitCollection.horizontalSizeClass ?? .compact) != .compact else { return }
            updateSidebarTrailingConstraint(shouldHide: hidesMapInRegularEnvironment)
        }
    }
    
    
    /// Updates the `hidesMapInRegularEnvironment` property with an optional
    /// animation.
    ///
    /// - Parameters:
    ///   - hidesMap: A boolean value indicating whether the map should be hidden.
    ///   - animated: A boolean value indicating whether the update should be animated.
    open func setHidesMapInRegularEnvironment(_ hidesMap: Bool, animated: Bool) {
        if animated == false || controller?.traitCollection.horizontalSizeClass ?? .compact == .compact {
            hidesMapInRegularEnvironment = hidesMap
            return
        }
        
        self.hidesMapInRegularEnvironment = hidesMap
        UIView.animate(withDuration: 0.4) { self.controller?.viewIfLoaded?.layoutIfNeeded() }
    }
    
    
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
    
    private var sidebarBackgroundView: UIVisualEffectView?
    
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
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false

        let sidebarBackground = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        sidebarBackground.translatesAutoresizingMaskIntoConstraints = false
        sidebarBackground.layer.cornerRadius = 8.0
        sidebarBackground.layer.masksToBounds = true
        view.addSubview(sidebarBackground)

        collectionView.frame = sidebarBackground.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sidebarBackground.contentView.addSubview(collectionView)

        self.sidebarBackgroundView = sidebarBackground

        if let accessoryView = controller.accessoryView {
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(accessoryView)

            constraints += [
                accessoryView.topAnchor.constraint(equalTo: searchFieldButton.bottomAnchor, constant: 16.0),
                accessoryView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            ]
        }

        let sidebarLayoutGuide = UILayoutGuide()
        self.sidebarLayoutGuide = sidebarLayoutGuide
        view.addLayoutGuide(sidebarLayoutGuide)

        let closeGesture = UISwipeGestureRecognizer(target: self, action: #selector(resetSideBar))
        closeGesture.direction = .left
        view.addGestureRecognizer(closeGesture)

        sidebarMinimumWidthConstraint = sidebarLayoutGuide.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumSidebarWidth)
        sidebarPreferredWidthConstraint = sidebarLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: preferredSidebarWidthFraction).withPriority(UILayoutPriority.defaultHigh)
        
        if controller.traitCollection.horizontalSizeClass == .compact || hidesMapInRegularEnvironment {
            sidebarLayoutGuideLeadingConstraint = sidebarLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor)
        } else {
            sidebarLayoutGuideLeadingConstraint = sidebarLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -sideBarWidth)
        }

        constraints += [
            sidebarLayoutGuideLeadingConstraint!,
            sidebarLayoutGuide.topAnchor.constraint(equalTo: searchFieldButton.bottomAnchor, constant: 16.0),
            sidebarLayoutGuide.bottomAnchor.constraint(equalTo: controller.bottomLayoutGuide.topAnchor, constant: -16.0),
            sidebarMinimumWidthConstraint!,
            sidebarPreferredWidthConstraint!,

            sidebarBackground.topAnchor.constraint(equalTo: sidebarLayoutGuide.topAnchor),
            sidebarBackground.bottomAnchor.constraint(equalTo: sidebarLayoutGuide.bottomAnchor),
            sidebarBackground.leadingAnchor.constraint(equalTo: sidebarLayoutGuide.leadingAnchor),
            sidebarBackground.trailingAnchor.constraint(equalTo: sidebarLayoutGuide.trailingAnchor),

            shadowBackground.topAnchor.constraint(equalTo: sidebarLayoutGuide.topAnchor),
            shadowBackground.bottomAnchor.constraint(equalTo: sidebarLayoutGuide.bottomAnchor),
            shadowBackground.leadingAnchor.constraint(equalTo: sidebarLayoutGuide.leadingAnchor),
            shadowBackground.trailingAnchor.constraint(equalTo: sidebarLayoutGuide.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

    open override func apply(_ theme: Theme) {
        super.apply(theme)

//        sidebarBackgroundView?.contentView.backgroundColor = theme.color(forKey: .background)
    }

    open func showSideBar(shouldInsetMapView: Bool = true) {
        sidebarLayoutGuideLeadingConstraint?.constant = 16.0
//        if let mapView = controller?.mapView, shouldInsetMapView {

//            if sidebarLayoutGuideLeadingConstraint?.constant == 16.0 {
//                mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 0.0, left: minimumSidebarWidth, bottom: 0.0, right: 0.0), animated: true)
//            } else {
//                mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
//            }
//        }
//        UIView.animate(withDuration: 0.3) { [unowned self] in
//            self.view.layoutIfNeeded()
//        }
    }
    
    @objc open func resetSideBar() {
//        guard let view = view else {
//            return
//        }
        sidebarLayoutGuideLeadingConstraint?.constant = -sideBarWidth
//        if let mapView = controller?.mapView {
//            mapView.layoutMargins = UIEdgeInsets.zero
//            mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
//        }
//        UIView.animate(withDuration: 0.3) {
//            view.layoutIfNeeded()
//        }
    }

    open override func viewDidLayoutSubviews() -> Bool {
//        controller?.legacy_additionalSafeAreaInsets.top = searchField
        return false
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let controller = controller else { return }
        
        let currentSizeClass = controller.traitCollection.horizontalSizeClass
        if previousTraitCollection?.horizontalSizeClass != currentSizeClass && hidesMapInRegularEnvironment == false {
            updateSidebarTrailingConstraint(shouldHide: currentSizeClass == .compact)
        }
    }

    private func updateSidebarTrailingConstraint(shouldHide: Bool) {
//        guard let sidebarBackground = sidebarBackgroundView,
//            let sidebarLayoutGuide = sidebarLayoutGuide,
//            let view = controller?.viewIfLoaded else { return }

//        sidebarTrailingConstraint?.isActive = false
//        sidebarTrailingConstraint = sidebarBackground.trailingAnchor.constraint(equalTo: shouldHide ? view.trailingAnchor : sidebarLayoutGuide.trailingAnchor)
//        sidebarTrailingConstraint!.isActive = true
    }
    
    open override func accessoryViewDidChange(_ previousAccessoryView: UIView?) {
        super.accessoryViewDidChange(previousAccessoryView)
//
//        let controller = self.controller!
//
//        guard let sidebarBackgroundView = sidebarBackgroundView,
//            let collectionView = controller.collectionView else { return }
//
//        previousAccessoryView?.removeFromSuperview()
//
//        collectionLeadingConstraint?.isActive = false
//
//        if let newAccessory = controller.accessoryView {
//            newAccessory.translatesAutoresizingMaskIntoConstraints = false
//            sidebarBackgroundView.addSubview(newAccessory)
//
//            collectionLeadingConstraint = collectionView.leadingAnchor.constraint(equalTo: newAccessory.trailingAnchor)
//
//            NSLayoutConstraint.activate([
//                newAccessory.topAnchor.constraint(equalTo: controller.topLayoutGuide.bottomAnchor),
//                newAccessory.bottomAnchor.constraint(lessThanOrEqualTo: controller.bottomLayoutGuide.topAnchor),
//                newAccessory.leadingAnchor.constraint(equalTo: sidebarBackgroundView.leadingAnchor),
//                collectionLeadingConstraint!
//                ])
//        } else {
//            collectionLeadingConstraint = collectionView.leadingAnchor.constraint(equalTo: sidebarBackgroundView.leadingAnchor)
//            collectionLeadingConstraint!.isActive = true
//        }
    }
}

extension LocationSearchMapCollectionViewSideBarLayout: LocationSearchSidebarDelegate {

    public var isShowing: Bool {
        return sidebarLayoutGuideLeadingConstraint?.constant == 16.0
    }

    public func hideSidebar(adjustMapInsets: Bool) {
        resetSideBar()
    }

    public func showSidebar(adjustMapInsets: Bool) {
        showSideBar(shouldInsetMapView: adjustMapInsets)
    }
}
