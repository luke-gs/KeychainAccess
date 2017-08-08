//
//  MapCollectionViewLayout.swift
//  MPOLKit
//
//  Created by Rod Brown on 2/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit


/// An abstract base class for laying out the views of a `MapCollectionViewController`
/// instance.
///
/// `MapCollectionViewLayout` gets callbacks during the view lifecycle and scrolling
/// interaction of its parent controller, and provides the opportunity for customizing
/// the behaviour with these callbacks.
open class MapCollectionViewLayout: NSObject {
    
    /// The current view controller the layout is managing.
    open weak internal(set) var controller: MapCollectionViewController?
    
    
    // MARK: - Base classes
    
    /// The class to use for the collection view. The default is `UICollectionView`.
    open func collectionViewClass() -> UICollectionView.Type {
        return UICollectionView.self
    }
    
    /// The class to use for the map view. The default is `MKMapView`.
    open func mapViewClass() -> MKMapView.Type {
        return MKMapView.self
    }
    
    
    // MARK: - Layout
    
    /// A callback that the view did load.
    ///
    /// This method is called just prior to the collection view's `viewDidLoad` method,
    /// allowing the layout to manipulate the view just prior to the layout occurring,
    /// including adding any constraints, etc.
    open func viewDidLoad() {
    }
    
    
    /// A callback that the view will layout subviews.
    ///
    /// This method will be called at the start of the collection performing the
    /// `viewWillLayoutSubviews()` method. Returning `false` tells the controller not to
    /// perform the default behaviour at `viewWillLayoutSubviews()`.
    ///
    ///
    /// - Returns: A boolean value indicating whether the controller should perform its
    ///           default behaviour. The default is `true`.
    open func viewWillLayoutSubviews() -> Bool {
        return true
    }
    
    
    /// A callback that the view did layout subviews.
    ///
    /// This method will be called at the start of the collection performing the
    /// `viewDidLayoutSubviews()` method. Returning `false` tells the controller not to
    /// perform the default behaviour at `viewDidLayoutSubviews()`.
    ///
    ///
    /// - Returns: A boolean value indicating whether the controller should perform its
    ///           default behaviour. The default is `true`.
    open func viewDidLayoutSubviews() -> Bool {
        return true
    }
    
    
    /// A callback that the trait collection did change.
    ///
    /// - Parameter previousTraitCollection: The previous trait collection prior to the change.
    open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    }
    
    
    /// A callback that the accessory view did change.
    ///
    /// - Parameter previousAccessoryView: The previous accessory view.
    open func accessoryViewDidChange(_ previousAccessoryView: UIView?) {
    }
    
    
    /// A callback when the view controller is required to apply its theme.
    ///
    /// - Parameter theme: The theme to apply.
    open func apply(_ theme: Theme?) {
    }
    
    
    // MARK: - Scrolling
    
    /// A callback which mirrors the delegate method on `UIScrollViewDelegate`.
    /// The default does nothing.
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    /// A callback which mirrors the delegate method on `UIScrollViewDelegate`.
    /// The default does nothing.
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    /// A callback which mirrors the delegate method on `UIScrollViewDelegate`.
    /// The default does nothing.
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
}
