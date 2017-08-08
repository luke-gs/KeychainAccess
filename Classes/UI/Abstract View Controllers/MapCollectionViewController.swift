//
//  MapCollectionViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 1/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit


/// A `FormCollectionViewController` subclass which allows to an MKMapView to be used
/// with collection views in MPOL Apps.
///
/// `MapCollectionViewController` uses an optional layout class,
/// `MapCollectionViewLayout`, to decide how it will layout the map in relation to its
/// collection view. This gives great flexibility for subclasses to either use a stock
/// layout, or provide their own.
///
/// By default, `MapCollectionViewController` doesn't insert the map into the view
/// heirarchy. This allows layouts to place the map where required, or subclasses
/// can specify no layout, and become responsible for inserting the map into the
/// view heirarchy.
open class MapCollectionViewController: FormCollectionViewController {
    
    
    // MARK: - Public properties
    
    /// The layout object, or `nil`.
    public let layout: MapCollectionViewLayout?
    
    
    /// The map view.
    ///
    /// This view's class is determined by the `mapViewClass()` method, and is loaded
    /// as the main view is created. As the position of this view could vary greatly
    /// betweenn layouts, the layout object or your subclass is responsible for
    /// placing the map into the view heirarchy.
    open private(set) var mapView: MKMapView?
    
    
    /// An optional accessory view for display with the collection and map.
    ///
    /// The position of this view is expected to be handled by the layout, or by a
    /// subclass directly. Therefore, like the map, this view is not placed within
    /// the view heirarchy. Instead, the layout receives a callback to inform it
    /// that the accessory view did change.
    open var accessoryView: UIView? {
        didSet {
            if accessoryView == oldValue { return }
            layout?.accessoryViewDidChange(oldValue)
        }
    }
    
    
    // MARK: - Subclass override points
    
    /// Returns the `MKMapView` class to use for the map view.
    ///
    /// - Returns: The `MKMapView` class to use for the map view. The default is
    ///            the `mapViewClass()` returned by the layout, or `MKMapView`.
    open func mapViewClass() -> MKMapView.Type {
        return layout?.mapViewClass() ?? MKMapView.self
    }
    
    /// Returns the `MKMapView` class to use for the map view.
    ///
    /// - Returns: The `UICollectionView` class to use for the map view. The default is
    ///            the `collectionViewClass()` returned by the layout, or the default
    ///            from FormCollectionViewController
    open override func collectionViewClass() -> UICollectionView.Type {
        return layout?.collectionViewClass() ?? super.collectionViewClass()
    }
    
    
    // MARK: - Initializers
    
    public init(layout: MapCollectionViewLayout?) {
        self.layout = layout
        super.init()
        layout?.controller = self
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    
    // MARK: - View lifecycle
    
    open override func loadView() {
        super.loadView()
        
        mapView = mapViewClass().init(frame: view.bounds)
    }
    
    open override func viewDidLoad() {
        layout?.viewDidLoad()
        super.viewDidLoad()
    }
    
    open override func viewWillLayoutSubviews() {
        if layout?.viewWillLayoutSubviews() ?? true {
            super.viewWillLayoutSubviews()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        if layout?.viewDidLayoutSubviews() ?? true {
            super.viewDidLayoutSubviews()
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layout?.traitCollectionDidChange(previousTraitCollection)
    }
    
    open override func apply(_ theme: Theme) {
        super.apply(theme)
        layout?.apply(theme)
    }
    
    
    // MARK: - Scroll view delegate methods
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        layout?.scrollViewDidScroll(scrollView)
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        layout?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        layout?.scrollViewDidEndDecelerating(scrollView)
    }
    
}
