//
//  MapCollectionViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 1/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class MapCollectionViewController: FormCollectionViewController {
    
    /// Allows subclasses to return a custom subclass of MKMapView to use
    /// as the map view.
    ///
    /// - Returns: The `MKMapView` class to use for the main map view.
    ///            The default is `MKMapView` itself
    open class func mapViewClass() -> MKMapView.Type {
        return MKMapView.self
    }
    
    open override class func collectionViewClass() -> UICollectionView.Type {
        return MapCollectionView.self
    }
    
    
    // MARK: - Public properties
    
    open var mapView: MKMapView?
    
    open var isMapExpanded: Bool = false {
        didSet {
            if isMapExpanded == oldValue { return }
            
            viewIfLoaded?.setNeedsLayout()
        }
    }
    
    open var mapRegionFraction: CGFloat = 0.5 {
        didSet {
            if mapRegionFraction ==~ oldValue { return }
            
            viewIfLoaded?.setNeedsLayout()
        }
    }
    
    
    // MARK: - Private properties
    
    private var minMapHeight: CGFloat = 0.0
    
    private var maxMapHeight: CGFloat = 0.0
    
    private var interactiveMapHeight: CGFloat = 0.0
    
    private var isFirstViewLayout: Bool = true
    
    private var isAdjustingInsets: Bool = false
    
    
    // MARK: - View lifecylce
    
    open override func loadView() {
        super.loadView()
        
        // We're going to put the mapView underneath the collection view. The
        // problem here is that it doesn't count as the content view for the
        // loading manager. So we'll create a new base view to hold the old
        // base view, and then the old base view will become the content view.
        
        let oldBackgroundView = self.view!
        oldBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let mapView = type(of: self).mapViewClass().init(frame: oldBackgroundView.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        oldBackgroundView.insertSubview(mapView, at: 0)
        
        let newBackgroundView = UIView(frame: oldBackgroundView.bounds)
        newBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newBackgroundView.addSubview(oldBackgroundView)
        
        let testView = UIView(frame: .zero)
        testView.translatesAutoresizingMaskIntoConstraints = false
        testView.backgroundColor = .black
        testView.isHidden = true
        mapView.addSubview(testView)
        
        self.mapView = mapView
        self.view = newBackgroundView
        
        NSLayoutConstraint.activate([
            testView.topAnchor.constraint(equalTo: mapView.layoutMarginsGuide.topAnchor),
            testView.bottomAnchor.constraint(equalTo: mapView.layoutMarginsGuide.bottomAnchor),
            testView.leadingAnchor.constraint(equalTo: mapView.layoutMarginsGuide.leadingAnchor),
            testView.trailingAnchor.constraint(equalTo: mapView.layoutMarginsGuide.trailingAnchor),
        ])
        
        
        // We switch to a new set of views for content views etc.
        loadingManager.baseView = newBackgroundView
        loadingManager.contentView = oldBackgroundView
    }
    
    open override func viewDidLayoutSubviews() {
        
        isAdjustingInsets = true
        
        let topInset = topLayoutGuide.length
        let bottomInset = max(bottomLayoutGuide.length, statusTabBarInset)
        
        let insets = UIEdgeInsets(top: topInset, left: 0.0, bottom: bottomInset, right: 0.0)
        loadingManager.contentInsets = insets
        
        let viewSize = view.frame.size
        let mapFrame = CGRect(x: 0.0, y: topInset, width: viewSize.width, height: viewSize.height - topInset - bottomInset)
        
        minMapHeight = (mapFrame.height * mapRegionFraction).ceiled(toScale: traitCollection.currentDisplayScale)
        maxMapHeight = mapFrame.height - 44.0
        
        let currentMapHeight: CGFloat
        if interactiveMapHeight !=~ 0.0 {
            currentMapHeight = interactiveMapHeight
        } else {
            currentMapHeight = isMapExpanded ? maxMapHeight : minMapHeight
        }
        
        collectionViewInsetManager?.standardContentInset   = UIEdgeInsets(top: topInset + currentMapHeight, left: 0.0, bottom: bottomInset, right: 0.0)
        collectionViewInsetManager?.standardIndicatorInset = insets
        
        let centerCoordinate = mapView?.centerCoordinate
        
        mapView?.frame = mapFrame
        mapView?.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: mapFrame.height - currentMapHeight, right: 0.0)
        
        if isFirstViewLayout {
            isFirstViewLayout = false
        } else if let coordinate = centerCoordinate, CLLocationCoordinate2DIsValid(coordinate) {
            mapView!.centerCoordinate = coordinate
        }
        
        isAdjustingInsets = false
    }
    
    open override func applyCurrentTheme() {
        super.applyCurrentTheme()
        collectionView?.backgroundView?.backgroundColor = Theme.current.colors[.Background]
    }
    
    
    // MARK: - Scroll view delegate methods
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isAdjustingInsets == false, let mapView = self.mapView else { return }
        
        let mapFrame = mapView.frame
        let originPoint = mapView.convert(CGPoint.zero, from: scrollView)
        
        let maxInset = (mapFrame.height * (1.0 - mapRegionFraction)).floored(toScale: traitCollection.currentDisplayScale)
        let bottomInset = max(min(mapFrame.size.height - originPoint.y, maxInset), 44.0)
        
        if scrollView.isDragging {
            interactiveMapHeight = mapFrame.height - bottomInset
        }
        
        let center = mapView.centerCoordinate
        
        if mapView.layoutMargins.bottom !=~ bottomInset {
            mapView.layoutMargins.bottom = bottomInset
            mapView.centerCoordinate = center
        }
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        interactiveMapHeight = 0.0
        
        let contentOffset = scrollView.contentOffset
        
        let minHeightInset = 0.0 - topLayoutGuide.length - minMapHeight
        let maxHeightInset = 0.0 - topLayoutGuide.length - maxMapHeight
        
        let expandMap: Bool
        var decelerationRate: CGFloat = UIScrollViewDecelerationRateFast
        
        if contentOffset.y > minHeightInset {
            // we're beyond the min map regions smallest spot
            expandMap = false
            decelerationRate = UIScrollViewDecelerationRateNormal
        } else if velocity.y > 0.5 {
            // scrolling up relatively fast
            expandMap = false
        } else if velocity.y < -0.5 {
            // scrolling down relatively fast.
            expandMap = true
        } else {
            let distanceFromExtendedHeight = contentOffset.y - maxHeightInset
            let distanceFromMinHeight      = minHeightInset - contentOffset.y
            
            // Toggle if it's moved more than a 1/4 out of it's correct state.
            if isMapExpanded {
                expandMap = distanceFromExtendedHeight < distanceFromMinHeight / 4.0
            } else {
                expandMap = distanceFromExtendedHeight / 4.0 < distanceFromMinHeight
            }
        }
        
        isMapExpanded = expandMap
        viewIfLoaded?.layoutIfNeeded() // resets the insets. This will adjust the offset which we don't want. Reset afterwards
        scrollView.contentOffset = contentOffset
        
        targetContentOffset.pointee.y = expandMap ? maxHeightInset : max(minHeightInset, targetContentOffset.pointee.y)
        scrollView.decelerationRate = decelerationRate
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    
}



/// A UICollectionView subclass designed to ignore touches above its header view, and
/// add a background view that allows the top content to show through.
private class MapCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        let backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = .white
        self.backgroundView = backgroundView
    }
    
    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let backgroundView = self.backgroundView {
            if backgroundView.frame.origin.y < 0.0 {
                backgroundView.frame.origin.y = 0.0
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if point.y < 0.0 {
            return false
        }
        
        return super.point(inside: point, with: event)
    }
    
}
