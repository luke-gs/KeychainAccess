//
//  MapOverlayViewController.swift
//  MPOL-CAD
//
//  Created by Rod Brown on 7/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

/// An abstract view controller for creating MPOL map overlay presentations.
/// 
/// `MapOverlayViewController` contains an overlay sidebar, which can be presented or
/// hidden, and customized for presentation fullscreen when in a horizontally compact
/// environment.
///
/// The map overlay contains a `SourceBar` and `UITableView` in front of a blurred
/// backgroundm, which adjusts to the theme and map appearance.
open class MapOverlayViewController: UIViewController {
    
    // MARK: - Public properties
    
    /// The map view for the view controller.
    public fileprivate(set) var mapView: MKMapView?
    
    
    /// The map type. The default is `MKMapType.standard`.
    /// 
    /// It is highly recommended you avoid adjusting the map view's type directly, and instead toggle it
    /// with this property. This allows the overlay to adjust its appearance according to the map type
    /// selected.
    public var mapType: MKMapType = .standard {
        didSet {
            if mapType == oldValue { return }
            
            mapView?.mapType = mapType
            isOverlayLight = Theme.current.isDark == false && mapType == .standard
        }
    }
    
    
    /// A boolean value indicating whether the overlay should be shown. The default is `true`.
    ///
    /// This property toggles whether the overlay should be shown at all. When in a horizontally
    /// compact environment, you may wish to show the overlay over the map completely, or hide it
    /// completely, and only reveal it in regular environments. This can be configured with the
    /// `showsOverlayInCompactWidth` property.
    ///
    /// To adjust this property with an optional animation, use the `setShowsOverlay(_:animated:)` method.
    public var showsOverlay: Bool {
        get { return _showsOverlay }
        set { setShowsOverlay(newValue, animated: false) }
    }
    
    
    /// Toggles the `showsOverlay` property, with an optional animation.
    ///
    /// - Parameters:
    ///   - show:     A boolean value indicating whether the overlay should be shown.
    ///   - animated: A boolean value indicating whether the update should be animated.
    public func setShowsOverlay(_ show: Bool, animated: Bool) {
        if showsOverlay == show { return } // No change
        
        _showsOverlay = show
        
        if isViewLoaded == false { return }
        
        let isCompact = traitCollection.horizontalSizeClass == .compact
        if _showsOverlayInCompactWidth == false && isCompact { return } // this will not show or hide anything as we're compact and we don't show overlay in compact
        
        if animated == false {
            if isCompact == false {
                transitionMapCenter = mapView?.centerCoordinate
                transitionMapCenterAnimated = false
            }
            updateOverlayForTraits()
            view.layoutIfNeeded()
            return
        }
        
        if isCompact {
            let effect = overlayView?.effect
            
            if show {
                // show immediately and layout without animation, but fade in the views.
                updateOverlayForTraits()
                view.layoutIfNeeded()
                
                overlayView?.effect = nil
                sourceBar?.alpha   = 0.0
                tableView?.alpha   = 0.0
                
                UIView.animate(withDuration: 0.25, animations: {
                    // Make sure the effect hasn't yet been reset by isLightOverlay change
                    if self.overlayView?.effect == nil {
                        self.overlayView?.effect = effect
                    }
                    self.sourceBar?.alpha   = 1.0
                    self.tableView?.alpha   = 1.0
                })
            } else {
                // fade all the views, and then toggle the constraints at completion
                UIView.animate(withDuration: 0.25, animations: {
                    self.overlayView?.effect = nil
                    self.sourceBar?.alpha   = 0.0
                    self.tableView?.alpha   = 0.0
                }, completion: { (finished: Bool) in
                    // Make sure the effect hasn't yet been reset by isLightOverlay change
                    if self.overlayView?.effect == nil {
                        self.overlayView?.effect = effect
                    }
                    self.sourceBar?.alpha   = 1.0
                    self.tableView?.alpha   = 1.0
                    
                    self.updateOverlayForTraits()
                    self.view.layoutIfNeeded()
                })
            }
        } else {
            transitionMapCenter = mapView?.centerCoordinate
            transitionMapCenterAnimated = true
            
            updateOverlayForTraits()
            UIView.animate(withDuration: 0.3, animations: {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    
    /// A boolean value indicating whether the overlay should be shown over the map
    /// when in a horizontally compact environment. The default is `false`.
    ///
    /// When in a horizontally compacy environment, `MapOverlayViewController` either
    /// shows the overlay full screen, or hides it completely. This is separate from
    /// the `showsOverlay` property, though the associated animation will appear the
    /// same.
    ///
    /// This property is ignored then the `showsOverlay` property is set to `false`.
    ///
    /// To adjust this property with an optional animation, use the `setShowsOverlayInCompactWidth(_:animated:)` method.
    public var showsOverlayInCompactWidth: Bool {
        get { return _showsOverlayInCompactWidth }
        set { setShowsOverlayInCompactWidth(newValue, animated: false) }
    }
    
    
    /// Toggles the `showsOverlayInCompactWidth` property, with an optional animation.
    ///
    /// - Parameters:
    ///   - show:     A boolean value indicating whether the overlay should be shown.
    ///   - animated: A boolean value indicating whether the update should be animated.
    public func setShowsOverlayInCompactWidth(_ showsOverlay: Bool, animated: Bool) {
        if _showsOverlayInCompactWidth == showsOverlay { return } // No change
        
        _showsOverlayInCompactWidth = showsOverlay
        
        if _showsOverlay == false || isViewLoaded == false || traitCollection.horizontalSizeClass != .compact { return } // No constraint / visual change needed
        
        if animated == false {
            updateOverlayForTraits()
            view.layoutIfNeeded()
            return
        }
        
        let effect = overlayView?.effect
        
        if showsOverlay {
            // show immediately and layout without animation, but fade in the views.
            updateOverlayForTraits()
            view.layoutIfNeeded()
            
            overlayView?.effect = nil
            sourceBar?.alpha   = 0.0
            tableView?.alpha   = 0.0
            
            UIView.animate(withDuration: 0.2, animations: {
                // Make sure the effect hasn't yet been reset by isLightOverlay change
                if self.overlayView?.effect == nil {
                    self.overlayView?.effect = effect
                }
                self.sourceBar?.alpha   = 1.0
                self.tableView?.alpha   = 1.0
            })
        } else {
            // fade all the views, and then toggle the constraints at completion
            UIView.animate(withDuration: 0.2, animations: {
                self.overlayView?.effect = nil
                self.sourceBar?.alpha   = 0.0
                self.tableView?.alpha   = 0.0
            }, completion: { (finished: Bool) in
                // Make sure the effect hasn't yet been reset by isLightOverlay change
                if self.overlayView?.effect == nil {
                    self.overlayView?.effect = effect
                }
                self.sourceBar?.alpha   = 1.0
                self.tableView?.alpha   = 1.0
                
                self.updateOverlayForTraits()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    /// The source bar in the overlay.
    public fileprivate(set) var sourceBar: SourceBar?
    
    
    /// The table view in the overlay.
    public fileprivate(set) var tableView: UITableView?
    
    
    /// A boolean value indicating whether the overlay has a light appearance. The default is `true`.
    ///
    /// Subclasses can override this property to detect when the overlay change occurs.
    open fileprivate(set) var isOverlayLight: Bool = true {
        didSet {
            let isLight = isOverlayLight
            if isLight == oldValue || isViewLoaded == false { return }
            
            let isShowingOverlay = _showsOverlay == false && (_showsOverlayInCompactWidth || traitCollection.horizontalSizeClass != .compact)
            
            overlayView?.effect        = UIBlurEffect(style: isLight ? .extraLight : .dark)
            overlaySeparator?.isHidden = (isLight && isShowingOverlay) == false
            sourceBar?.style           = isOverlayLight ? .light : .dark
            sourceBackground?.gradientColors  = isOverlayLight ? [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)] : [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5),#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)]
        }
    }
    
    
    
    // MARK: - Private properties
    
    fileprivate var _showsOverlay: Bool = true
    
    fileprivate var _showsOverlayInCompactWidth: Bool = false
    
    fileprivate var overlayView: UIVisualEffectView?
    
    fileprivate var overlaySeparator: UIView?
    
    fileprivate var sourceBackground: GradientView?
    
    /// The full width constraint for the overlay.
    ///
    /// Activate in horizontally compact only.
    fileprivate var overlayCompactConstraint: NSLayoutConstraint?
    
    /// The constraint governing if the overlay is shown or hidden.
    ///
    /// Should be overlay.trailing == view.leading in hidden, and overlay.leading == view.leading in showing.
    fileprivate var overlayShowHideConstraint: NSLayoutConstraint?
    
    fileprivate var overlaySeparatorWidthConstraint: NSLayoutConstraint?
    
    fileprivate var transitionMapCenter: CLLocationCoordinate2D?
    
    fileprivate var transitionMapCenterAnimated: Bool = false
    
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(_:)), name: .ThemeDidChange, object: nil)
    }
    
}


// MARK: - View lifecycle
/// View lifecycle
extension MapOverlayViewController {
    
    open override func loadView() {
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        
        let mapView = MKMapView(frame: backgroundView.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapType = mapType
        backgroundView.addSubview(mapView)
        
        let overlayView = UIVisualEffectView(effect: UIBlurEffect(style: isOverlayLight ? .extraLight : .dark))
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(overlayView)
        
        let sourceBackground = GradientView(frame: .zero)
        sourceBackground.gradientColors = isOverlayLight ? [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)] : [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4031415053),#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)]
        
        let sourceBar = SourceBar(frame: .zero)
        sourceBar.items = [SourceItem(color: .red, title: "TEST", count: 3, isEnabled: true)]
        sourceBar.style = isOverlayLight ? .light : .dark
        sourceBar.backgroundView = sourceBackground
        sourceBar.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(sourceBar)
        
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 104.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 20.0))
        tableView.register(TableViewFormMPOLHeaderCell.self, forCellReuseIdentifier: "Header")
        backgroundView.addSubview(tableView)
        
        let overlaySeparator = UIView(frame: .zero)
        overlaySeparator.translatesAutoresizingMaskIntoConstraints = false
        overlaySeparator.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
        overlaySeparator.isHidden = isOverlayLight == false
        backgroundView.addSubview(overlaySeparator)
        
        self.mapView          = mapView
        self.overlayView      = overlayView
        self.overlaySeparator = overlaySeparator
        self.sourceBar        = sourceBar
        self.tableView        = tableView
        self.view             = backgroundView
        
        let preferredOverlayMinimumWidth = NSLayoutConstraint(item: overlayView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 336.0)
        preferredOverlayMinimumWidth.priority = 800.0
        
        let preferredOverlayWidth = NSLayoutConstraint(item: overlayView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0 / 3.05, constant: 0.0)
        preferredOverlayWidth.priority = UILayoutPriorityDefaultHigh
        
        overlaySeparatorWidthConstraint = NSLayoutConstraint(item: overlaySeparator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0 / UIScreen.main.scale)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: overlayView, attribute: .top,     relatedBy: .equal, toItem: topLayoutGuide,    attribute: .bottom),
            NSLayoutConstraint(item: overlayView, attribute: .bottom,  relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top),
            preferredOverlayMinimumWidth,
            preferredOverlayWidth,
            
            NSLayoutConstraint(item: sourceBar, attribute: .top,     relatedBy: .equal, toItem: overlayView, attribute: .top),
            NSLayoutConstraint(item: sourceBar, attribute: .leading, relatedBy: .equal, toItem: overlayView, attribute: .leading),
            NSLayoutConstraint(item: sourceBar, attribute: .bottom,  relatedBy: .equal, toItem: overlayView, attribute: .bottom),
            
            NSLayoutConstraint(item: tableView, attribute: .top,      relatedBy: .equal, toItem: overlayView, attribute: .top),
            NSLayoutConstraint(item: tableView, attribute: .bottom,   relatedBy: .equal, toItem: overlayView, attribute: .bottom),
            NSLayoutConstraint(item: tableView, attribute: .leading,  relatedBy: .equal, toItem: sourceBar,   attribute: .trailing),
            NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: overlayView, attribute: .trailing),
            
            NSLayoutConstraint(item: overlaySeparator, attribute: .leading, relatedBy: .equal, toItem: overlayView, attribute: .trailing),
            NSLayoutConstraint(item: overlaySeparator, attribute: .top,     relatedBy: .equal, toItem: overlayView, attribute: .top),
            NSLayoutConstraint(item: overlaySeparator, attribute: .bottom,  relatedBy: .equal, toItem: overlayView, attribute: .bottom),
            overlaySeparatorWidthConstraint!,
        ])
        
        overlayCompactConstraint = NSLayoutConstraint(item: overlayView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width)
        if traitCollection.horizontalSizeClass == .compact {
            overlayCompactConstraint?.isActive = true
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        updateOverlayForTraits()
        
        // WORKAROUND: 
        // If in compact and we're showing a blur over the view as the map view loads, it fails to render the map,
        // and will set its region to an invalid region. Set it here manually with the initial value. This isn't the true
        // country level zoom as is default, but it'll do.
        if _showsOverlay && _showsOverlayInCompactWidth && traitCollection.horizontalSizeClass == .compact,
            let mapView = self.mapView {
            let mapRect = mapView.visibleMapRect
            mapView.visibleMapRect = mapRect
        }
    }
    
    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if newCollection.horizontalSizeClass != traitCollection.horizontalSizeClass && showsOverlay {
            transitionMapCenter = mapView?.centerCoordinate
            transitionMapCenterAnimated = coordinator.isAnimated
        }
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let view = self.view, let overlayView = self.overlayView, let mapView = self.mapView else { return }
        
        let isRightToLeft: Bool
        if #available(iOS 10, *) {
            isRightToLeft = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            isRightToLeft = UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .rightToLeft
        }
        
        let isRegular = traitCollection.horizontalSizeClass != .compact
        let overlayInset = _showsOverlay && (_showsOverlayInCompactWidth || isRegular) ? overlayView.frame.width : 0.0
        
        var mapViewInsets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        if isRightToLeft {
            mapViewInsets.right = overlayInset
        } else {
            mapViewInsets.left = overlayInset
        }
        mapView.layoutMargins = mapViewInsets
        
        if let mapCenter = transitionMapCenter {
            if CLLocationCoordinate2DIsValid(mapCenter) {
                mapView.setCenter(mapCenter, animated: transitionMapCenterAnimated)
            }
            transitionMapCenter = nil
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let wasCompact = previousTraitCollection?.horizontalSizeClass == .compact
        let isCompact  = traitCollection.horizontalSizeClass == .compact
        if wasCompact != isCompact {
            updateOverlayForTraits()
        }
        
        var displayScale = traitCollection.displayScale
        if previousTraitCollection?.displayScale != displayScale {
            if displayScale == 0.0 {
                displayScale = UIScreen.main.scale
            }
            overlaySeparatorWidthConstraint?.constant = 1.0 / displayScale
        }
    }
    
}


// MARK: - Table view data source and delegate

extension MapOverlayViewController: UITableViewDataSource {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Subclasses must implement tableView(_:cellForItemAt:) and return a valid cell.")
    }
    
}

extension MapOverlayViewController: UITableViewDelegate {
    
}


// MARK: - Private methods
/// Private methods
fileprivate extension MapOverlayViewController {
    
    // updates the overlay view for traits (changes).
    fileprivate func updateOverlayForTraits() {
        guard let overlayView = self.overlayView, let view = self.view else { return }
        
        let isCompact = traitCollection.horizontalSizeClass == .compact
        
        overlayCompactConstraint?.isActive = isCompact
        
        let shouldShowOverlay = _showsOverlay && (isCompact == false || _showsOverlayInCompactWidth)
        
        // determine whether the overlay is currently showing. This would mean a constraint was on the leading of the overlay view, rather than the trailing.
        let isShowingOverlay = (overlayShowHideConstraint?.firstItem as? NSObject == overlayView && overlayShowHideConstraint?.firstAttribute == .leading) || (overlayShowHideConstraint?.secondItem as? NSObject == overlayView && overlayShowHideConstraint?.secondAttribute == .leading)
        
        if overlayShowHideConstraint != nil && isShowingOverlay == shouldShowOverlay { return }
        
        overlayShowHideConstraint?.isActive = false
        
        overlayShowHideConstraint = NSLayoutConstraint(item: overlayView, attribute: shouldShowOverlay ? .leading : .trailing, relatedBy: .equal, toItem: view, attribute: .leading)
        overlayShowHideConstraint?.isActive = true
    }
    
    @objc fileprivate func themeDidChange(_ notification: Notification) {
        isOverlayLight = Theme.current.isDark == false && mapType == .standard
    }
    
}
