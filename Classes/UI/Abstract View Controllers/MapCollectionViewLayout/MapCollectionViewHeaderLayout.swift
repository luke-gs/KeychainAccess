//
//  MapCollectionViewHeaderLayout.swift
//  MPOLKit
//
//  Created by Rod Brown on 2/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit


/// A concrete subclass of MapCollectionViewLayout for placing a map in a header
/// above the collection.
///
/// `MapCollectionViewHeaderLayout` has additional state for whether the map is
/// expanded, and this can be interactively toggled by users.
class MapCollectionViewHeaderLayout: MapCollectionViewLayout {

    // MARK: - Public properties
    
    /// A boolean value indicating whether the map is currently in an expanded state.
    ///
    /// The default is `false`.
    open var isMapExpanded: Bool = false {
        didSet {
            if isMapExpanded == oldValue { return }
            controller?.viewIfLoaded?.setNeedsLayout()
        }
    }
    
    
    /// A floating point value indicating the fraction of the view that should be
    /// taken up by the map at the top of the view, when not expanded.
    ///
    /// The default is `0.5`.
    open var mapRegionFraction: CGFloat = 0.5 {
        didSet {
            if mapRegionFraction ==~ oldValue { return }
            controller?.viewIfLoaded?.setNeedsLayout()
        }
    }
    
    
    // MARK: - Private properties
    
    private var minMapHeight: CGFloat = 0.0
    
    private var maxMapHeight: CGFloat = 0.0
    
    private var interactiveMapHeight: CGFloat = 0.0
    
    private var isFirstMapLayout: Bool = true
    
    private var isAdjustingInsets: Bool = false
    
    
    // MARK: - Type overrides
    
    override func collectionViewClass() -> UICollectionView.Type {
        /// We use a custom class to ensure that touches can flow through to the map.
        return MapHeaderCollectionView.self
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        isFirstMapLayout = true
        
        let controller = self.controller!
        let mapView = controller.mapView!
        
        // We're going to put the mapView underneath the collection view. The
        // problem here is that it doesn't count as the content view for the
        // loading manager. So we'll create a new base view to hold the old
        // base view, and then the old base view will become the content view.
        
        let oldBackgroundView = controller.view!
        oldBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.frame = oldBackgroundView.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        oldBackgroundView.insertSubview(mapView, at: 0)
        
        let newBackgroundView = UIView(frame: oldBackgroundView.bounds)
        newBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newBackgroundView.addSubview(oldBackgroundView)
        
        controller.view = newBackgroundView
        
        // We switch to a new set of views for content views etc.
        controller.loadingManager.baseView = newBackgroundView
        controller.loadingManager.contentView = oldBackgroundView
    }
    
    override func viewDidLayoutSubviews() -> Bool {
        let controller = self.controller!
        
        isAdjustingInsets = true
        
        let topInset = controller.topLayoutGuide.length
        let bottomInset = max(controller.bottomLayoutGuide.length, controller.statusTabBarInset)
        let additionalContentInsets = controller.additionalContentInsets
        
        controller.loadingManager.contentInsets = UIEdgeInsets(top: topInset, left: 0.0, bottom: bottomInset, right: 0.0)
        
        let viewSize = controller.view.frame.size
        let mapFrame = CGRect(x: 0.0, y: topInset, width: viewSize.width, height: viewSize.height - topInset - bottomInset)
        
        minMapHeight = (mapFrame.height * mapRegionFraction).ceiled(toScale: controller.traitCollection.currentDisplayScale)
        maxMapHeight = mapFrame.height - 44.0
        
        let currentMapHeight: CGFloat
        if interactiveMapHeight !=~ 0.0 {
            currentMapHeight = interactiveMapHeight
        } else {
            currentMapHeight = isMapExpanded ? maxMapHeight : minMapHeight
        }
        
        if let insetManager = controller.collectionViewInsetManager {
            let collectionContentInsets = UIEdgeInsets(top: topInset + currentMapHeight, left: 0.0, bottom: bottomInset + additionalContentInsets.bottom, right: 0.0)
            insetManager.standardContentInset   = collectionContentInsets
            insetManager.standardIndicatorInset = collectionContentInsets
        }
        
        if let mapView = controller.mapView {
            let centerCoordinate = mapView.centerCoordinate
            let mapLayoutMargins = UIEdgeInsets(top: additionalContentInsets.top, left: 0.0, bottom: mapFrame.height - currentMapHeight, right: 0.0)
            
            if mapView.frame != mapFrame || mapView.layoutMargins != mapLayoutMargins {
                mapView.frame = mapFrame
                mapView.layoutMargins = mapLayoutMargins
                
                if isFirstMapLayout == false && CLLocationCoordinate2DIsValid(centerCoordinate) {
                    mapView.centerCoordinate = centerCoordinate
                }
            }
            
            // On first view appearance, the map won't have a valid center coordinate. This
            // fixes that by bypassing the setting of the coordinate.
            if isFirstMapLayout {
                isFirstMapLayout = false
            }
        }
        
        isAdjustingInsets = false
        
        return false
    }
    
    
    // MARK: - Scroll interaction
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let controller = self.controller!
        
        guard isAdjustingInsets == false, let mapView = controller.mapView else { return }
        
        let mapFrame = mapView.frame
        let originPoint = mapView.convert(CGPoint.zero, from: scrollView)
        
        let maxInset = (mapFrame.height * (1.0 - mapRegionFraction)).floored(toScale: controller.traitCollection.currentDisplayScale)
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
    
    open override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let topLayoutGuideLength = controller!.topLayoutGuide.length
        
        interactiveMapHeight = 0.0
        
        let contentOffset = scrollView.contentOffset
        
        let minHeightInset = 0.0 - topLayoutGuideLength - minMapHeight
        let maxHeightInset = 0.0 - topLayoutGuideLength - maxMapHeight
        
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
        controller?.viewIfLoaded?.layoutIfNeeded() // resets the insets. This will adjust the offset which we don't want. Reset afterwards
        scrollView.contentOffset = contentOffset
        
        targetContentOffset.pointee.y = expandMap ? maxHeightInset : max(minHeightInset, targetContentOffset.pointee.y)
        scrollView.decelerationRate = decelerationRate
    }
    
    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
}


/// A UICollectionView subclass designed to ignore touches above its header view, and
/// add a background view that allows the top content to show through.
private class MapHeaderCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        let backgroundView = UIView(frame: .zero)
        backgroundView.layer.shadowOpacity = 0.4
        backgroundView.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
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
