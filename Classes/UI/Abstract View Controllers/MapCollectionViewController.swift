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
    /// as the main view is created. The layout object or a subclass is responsible for
    /// putting the map into the view heirarchy
    open var mapView: MKMapView?
    
    
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
