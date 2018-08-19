//
//  MapCollectionViewSidebarLayout.swift
//  MPOLKit
//
//  Created by Rod Brown on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit


/// A concrete subclass of `MapCollectionViewLayout` for arranging a map
/// with a sidebar collection view.
///
/// `MapCollectionViewSidebarLayout` has additional state for whether the
/// collection is shown in sidebar, or full-screen, when in a horizontally
/// regular environment.
open class MapCollectionViewSidebarLayout: MapCollectionViewLayout {
    
    
    /// A boolean value indicating whether the sidebar should display fullscreen
    /// when in regular width environments, hiding the map. The default is `false`.
    open var hidesMapInRegularEnvironment: Bool = false {
        didSet {
            guard hidesMapInRegularEnvironment != oldValue && (controller?.traitCollection.horizontalSizeClass ?? .compact) != .compact,
                let view = controller?.viewIfLoaded,
                let sidebarBackgroundView = self.sidebarBackgroundView,
                let sidebarLayoutGuide = self.sidebarLayoutGuide else { return }
            
            sidebarTrailingConstraint?.isActive = false
            sidebarTrailingConstraint = sidebarBackgroundView.trailingAnchor.constraint(equalTo: hidesMapInRegularEnvironment ? view.trailingAnchor : sidebarLayoutGuide.trailingAnchor)
            sidebarTrailingConstraint?.isActive = true
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
    
    
    // MARK: - Private properties
    
    private var sidebarLayoutGuide: UILayoutGuide?
    
    private var sidebarBackgroundView: UIView?
    
    private var sidebarMinumumWidthConstraint: NSLayoutConstraint?
    
    private var sidebarPreferredWidthConstraint: NSLayoutConstraint?
    
    private var collectionLeadingConstraint: NSLayoutConstraint?
    
    private var sidebarTrailingConstraint: NSLayoutConstraint?
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        let controller = self.controller!
        let view = controller.view!
        
        var constraints: [NSLayoutConstraint] = []
        
        let collectionView = controller.collectionView!
        let mapView = controller.mapView!
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        let backingView = UIView(frame: view.bounds)
        backingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backingView)
        
        let sidebarBackground = UIView(frame: .zero)
        sidebarBackground.translatesAutoresizingMaskIntoConstraints = false
        sidebarBackground.backgroundColor = #colorLiteral(red: 0.1058823529, green: 0.1176470588, blue: 0.1411764706, alpha: 1)
        
        view.addSubview(mapView)
        view.addSubview(sidebarBackground)
        sidebarBackground.addSubview(collectionView)
        
        self.sidebarBackgroundView = sidebarBackground
        
        if let accessoryView = controller.accessoryView {
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            sidebarBackground.addSubview(accessoryView)
            
            collectionLeadingConstraint = accessoryView.trailingAnchor.constraint(equalTo: collectionView.leadingAnchor)
            
            constraints += [
                accessoryView.leadingAnchor.constraint(equalTo: sidebarBackground.leadingAnchor),
                accessoryView.topAnchor.constraint(equalTo: controller.topLayoutGuide.bottomAnchor),
                accessoryView.bottomAnchor.constraint(lessThanOrEqualTo: controller.bottomLayoutGuide.topAnchor),
                collectionLeadingConstraint!
            ]
        } else {
            collectionLeadingConstraint = collectionView.leadingAnchor.constraint(equalTo: sidebarBackground.leadingAnchor)
            constraints.append(collectionLeadingConstraint!)
        }
        
        let sidebarLayoutGuide = UILayoutGuide()
        self.sidebarLayoutGuide = sidebarLayoutGuide
        view.addLayoutGuide(sidebarLayoutGuide)
        
        sidebarMinumumWidthConstraint = sidebarLayoutGuide.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumSidebarWidth)
        sidebarPreferredWidthConstraint = sidebarLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: preferredSidebarWidthFraction).withPriority(UILayoutPriority.defaultHigh)
        
        if controller.traitCollection.horizontalSizeClass == .compact || hidesMapInRegularEnvironment {
            sidebarTrailingConstraint = sidebarBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        } else {
            sidebarTrailingConstraint = sidebarBackground.trailingAnchor.constraint(equalTo: sidebarLayoutGuide.trailingAnchor)
        }
        
        constraints += [
            sidebarLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            sidebarLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sidebarMinumumWidthConstraint!,
            sidebarPreferredWidthConstraint!,
            sidebarTrailingConstraint!,
            
            sidebarBackground.topAnchor.constraint(equalTo: sidebarLayoutGuide.topAnchor),
            sidebarBackground.bottomAnchor.constraint(equalTo: sidebarLayoutGuide.bottomAnchor),
            sidebarBackground.leadingAnchor.constraint(equalTo: sidebarLayoutGuide.leadingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: sidebarBackground.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: sidebarBackground.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: sidebarBackground.trailingAnchor),
            
            mapView.leadingAnchor.constraint(equalTo: sidebarLayoutGuide.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        controller.userInterfaceStyle = .dark
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let controller = self.controller,
            let view = controller.viewIfLoaded,
            let sidebarBackground = self.sidebarBackgroundView,
            let sidebarLayoutGuide = self.sidebarLayoutGuide else { return }
        
        let currentSizeClass = controller.traitCollection.horizontalSizeClass
        if previousTraitCollection?.horizontalSizeClass != currentSizeClass && hidesMapInRegularEnvironment == false {
            sidebarTrailingConstraint?.isActive = false
            sidebarTrailingConstraint = sidebarBackground.trailingAnchor.constraint(equalTo: currentSizeClass == .compact ? view.trailingAnchor : sidebarLayoutGuide.trailingAnchor)
            sidebarTrailingConstraint!.isActive = true
        }
    }
    
    open override func accessoryViewDidChange(_ previousAccessoryView: UIView?) {
        super.accessoryViewDidChange(previousAccessoryView)
        
        let controller = self.controller!
        
        guard let sidebarBackgroundView = self.sidebarBackgroundView,
              let collectionView = controller.collectionView else { return }
        
        previousAccessoryView?.removeFromSuperview()
        
        collectionLeadingConstraint?.isActive = false
        
        if let newAccessory = controller.accessoryView {
            newAccessory.translatesAutoresizingMaskIntoConstraints = false
            sidebarBackgroundView.addSubview(newAccessory)
            
            collectionLeadingConstraint = collectionView.leadingAnchor.constraint(equalTo: newAccessory.trailingAnchor)
            
            NSLayoutConstraint.activate([
                newAccessory.topAnchor.constraint(equalTo: controller.topLayoutGuide.bottomAnchor),
                newAccessory.bottomAnchor.constraint(lessThanOrEqualTo: controller.bottomLayoutGuide.topAnchor),
                newAccessory.leadingAnchor.constraint(equalTo: sidebarBackgroundView.leadingAnchor),
                collectionLeadingConstraint!
            ])
        } else {
            collectionLeadingConstraint = collectionView.leadingAnchor.constraint(equalTo: sidebarBackgroundView.leadingAnchor)
            collectionLeadingConstraint!.isActive = true
        }
    }
    
    
}
