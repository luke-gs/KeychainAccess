//
// Created by KGWH78 on 19/1/18.
// Copyright (c) 2018 Gridstone. All rights reserved.
//

import Foundation
import MapKit

/// A `MapFormBuilderViewController` subclass which allows to an MKMapView to be used
/// with collection views in MPOL Apps.
///
/// `MapFormBuilderViewController` uses an optional layout class,
/// `MapFormBuilderViewLayout`, to decide how it will layout the map in relation to its
/// collection view. This gives great flexibility for subclasses to either use a stock
/// layout, or provide their own.
///
/// By default, `MapFormBuilderViewController` doesn't insert the map into the view
/// hierarchy. This allows layouts to place the map where required, or subclasses
/// can specify no layout, and become responsible for inserting the map into the
/// view hierarchy.
open class MapFormBuilderViewController: FormBuilderViewController {


    // MARK: - Public properties

    /// The layout object, or `nil`.
    public internal(set) var layout: MapFormBuilderViewLayout?


    /// The map view.
    ///
    /// This view's class is determined by the `mapViewClass()` method, and is loaded
    /// as the main view is created. As the position of this view could vary greatly
    /// between layouts, the layout object or your subclass is responsible for
    /// placing the map into the view hierarchy.
    open private(set) var mapView: MKMapView?


    /// An optional accessory view for display with the collection and map.
    ///
    /// The position of this view is expected to be handled by the layout, or by a
    /// subclass directly. Therefore, like the map, this view is not placed within
    /// the view hierarchy. Instead, the layout receives a callback to inform it
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

    public init(layout: MapFormBuilderViewLayout?) {
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
    
    open override func viewDidAppear(_ animated: Bool) {
        layout?.viewDidAppear(animated)
        super.viewDidAppear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        layout?.viewDidDisappear(animated)
        super.viewDidDisappear(animated)
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
        let currentInterfaceStyle = ThemeManager.shared.currentInterfaceStyle
        let isDark = currentInterfaceStyle.isDark
        mapView?.mpl_setNightModeEnabled(isDark)

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

/// An abstract base class for laying out the views of a `MapFormBuilderViewController`
/// instance.
///
/// `MapFormBuilderViewLayout` gets callbacks during the view lifecycle and scrolling
/// interaction of its parent controller, and provides the opportunity for customizing
/// the behaviour with these callbacks.
open class MapFormBuilderViewLayout: NSObject {

    /// The current view controller the layout is managing.
    open weak internal(set) var controller: MapFormBuilderViewController?


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

    /// A callback that the view disappeared
    open func viewDidDisappear(_ animated: Bool) {
    }
    
    /// A callback that the view appeared
    open func viewDidAppear(_ animated: Bool) {
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
    open func apply(_ theme: Theme) {
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

