//
//  StatusTabBarController.swift
//  MPOLKit
//
//  Created by Rod Brown on 5/7/17.
//

import UIKit

fileprivate var tabBarStyleContext = 1

fileprivate let tabBarStyleKeys: [String] = [
    #keyPath(UITabBar.barStyle),
    #keyPath(UITabBar.backgroundImage),
    #keyPath(UITabBar.shadowImage),
    #keyPath(UITabBar.barTintColor),
    #keyPath(UITabBar.isTranslucent)
]

public protocol StatusTabBarDelegate {
    func controller(_ controller: StatusTabBarController, shouldSelect viewController: UIViewController) -> Bool
}


/// A view controller for presenting a tabbed interface, with a hosted status view.
///
/// `StatusTabBarController` replaces a standard tab bar controller, and pushes the tab bar to
/// the leading edge, allowing the status view to appear at the trailing edge. When in a
/// horizontally compacy environment, the status view is hidden.
///
/// To adjust the appearance of the full tab bar, simply adjust the appearance of the `tabBar`
/// property. These changes will auto-translate to the full bar.
///
/// Prior to iOS 11, custom container view controllers are not supported updating the
/// `topLayoutGuide` and `bottomLayoutGuide` properties. On these platforms, it is recommended
/// that your child view controllers use the `UIViewController.statusTabBarInset` property.
/// On iOS 11, `StatusTabBarController` correctly updates the `safeAreaInsets` applied to
/// child view controllers.
///
/// Unlike `UITabBarController`, the status tab bar controller does not automatically shift
/// shift additional view controllers into a more tab. Users should do this with custom behaviour
/// if required.
open class StatusTabBarController: UIViewController, UITabBarDelegate {

    open var statusTabBarDelegate: StatusTabBarDelegate?
    
    /// An array of the root view controllers displayed by the tab bar interface.
    ///
    /// The default value of this property is an empty array. Setting this property
    /// changes the `selectedViewController` iff the currently selected view
    /// controller is not in the current array, to the first item in the array.
    open var viewControllers: [UIViewController] = [] {
        didSet {
            let viewControllers = self.viewControllers
            
            for vc in viewControllers where oldValue.contains(vc) == false {
                addChildViewController(vc)
                vc.didMove(toParentViewController: self)
            }
            
            tabBar.items = viewControllers.map { $0.tabBarItem }
            
            if let selectedViewController = self.selectedViewController {
                if viewControllers.contains(selectedViewController) == false {
                    selectedViewController.viewIfLoaded?.removeFromSuperview()
                    self.selectedViewController = viewControllers.first
                }
            } else {
                selectedViewController = viewControllers.first
            }
            
            for vc in oldValue where viewControllers.contains(vc) == false {
                vc.willMove(toParentViewController: nil)
                vc.removeFromParentViewController()
            }
        }
    }
    
    /// An array of view controllers to only be displayed in horizontal compact mode
    open var compactViewControllers: [UIViewController]? {
        didSet {
            addCompactTabsIfCompact()
        }
    }
    
    /// The currently selected view controller. The default is `nil`.
    open var selectedViewController: UIViewController? {
        didSet {
            if let selectedVC = selectedViewController {
                assert(viewControllers.contains(selectedVC), "selectedViewController must be contained within the viewControllers property.")
            }
            
            tabBar.selectedItem = selectedViewController?.tabBarItem
            
            guard selectedViewController != oldValue,
                let view = viewIfLoaded else { return }
            
            if let oldView = oldValue?.viewIfLoaded {
                oldView.removeFromSuperview()
            }
            
            if let selectedView = selectedViewController?.view {
                selectedView.frame = oldValue?.viewIfLoaded?.frame ?? view.bounds
                view.insertSubview(selectedView, at: 0)
                view.setNeedsLayout()
            }
            
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    
    /// The Status View.
    ///
    /// This view is sized with AutoLayout, and placed within the tab bar in a
    /// horizontally regular environment. The status view is hidden in a
    /// horizontally compact environment.
    open var statusView: UIView? {
        didSet {
            if statusView == oldValue || isViewLoaded == false { return }
            
            oldValue?.removeFromSuperview()
            if let newStatusView = self.statusView {
                if newStatusView.translatesAutoresizingMaskIntoConstraints {
                    let size = newStatusView.frame.size
                    newStatusView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        newStatusView.widthAnchor.constraint(equalToConstant: abs(size.width)).withPriority(UILayoutPriority.defaultLow),
                        newStatusView.heightAnchor.constraint(equalToConstant: abs(size.height)).withPriority(UILayoutPriority.defaultLow)
                    ])
                } 
                tabBarContainerController.view.addSubview(newStatusView)
            }
            updateBarConstraints()
        }
    }
    
    
    /// The tab bar for the view.
    ///
    /// You should not size your views to avoid the tab bar itself. On iOS 11+,
    /// you should correctly adhere to the safeAreaInsets. On iOS 10 and earlier,
    /// use the `UIViewController.statusTabBarInset` property.
    open private(set) lazy var tabBar: UITabBar = { [unowned self] in
        let tabBar = UITabBar(frame: .zero)
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.delegate = self
        
        self.isTabBarLoaded = true
        tabBarStyleKeys.forEach { tabBar.addObserver(self, forKeyPath: $0, context: &tabBarStyleContext) }
        
        return tabBar
    }()
    
    
    // MARK: - Private properties
    
    fileprivate let tabBarContainerController: UIViewController
    
    private lazy var tabBarBackground = UITabBar(frame: .zero)
    
    private var barConstraints: [NSLayoutConstraint]?
    
    private var isTabBarLoaded: Bool = false
    
    private var isResettingTabBarAppearance: Bool = false
    
    
    // MARK: - Initializers
    
    public init() {
        tabBarContainerController = UIViewController(nibName: nil, bundle: nil)
        super.init(nibName: nil, bundle: nil)
        
        addChildViewController(tabBarContainerController)
        tabBarContainerController.didMove(toParentViewController: self)
        
        let overrideTraitCollection = UITraitCollection(traitsFrom: [UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(userInterfaceIdiom: .pad)])
        setOverrideTraitCollection(overrideTraitCollection, forChildViewController: tabBarContainerController)
    }
    
    // `StatusTabBarController` does not support `NSCoding`.
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    deinit {
        if isTabBarLoaded {
            tabBarStyleKeys.forEach { tabBar.removeObserver(self, forKeyPath: $0, context: &tabBarStyleContext)}
        }
    }
    
    
    // MARK: - View lifecycle
    
    open override func loadView() {
        let view = UIView(frame: UIScreen.main.bounds)
        
        if let selectedView = selectedViewController?.view {
            selectedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            selectedView.frame = view.bounds
            view.addSubview(selectedView)
        }
        
        let tabBarContainerView = tabBarContainerController.view!
        tabBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarContainerView)
        
        tabBarBackground.translatesAutoresizingMaskIntoConstraints = false
        tabBarContainerView.addSubview(tabBarBackground)
        
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBarContainerView.addSubview(tabBar)
        
        var constraints: [NSLayoutConstraint] = []
        
        if let statusView = self.statusView {
            if statusView.translatesAutoresizingMaskIntoConstraints {
                let size = statusView.frame.size
                statusView.translatesAutoresizingMaskIntoConstraints = false
                constraints.append(statusView.widthAnchor.constraint(equalToConstant: size.width).withPriority(UILayoutPriority.defaultLow))
                constraints.append(statusView.heightAnchor.constraint(equalToConstant: size.height).withPriority(UILayoutPriority.defaultLow))
            }
            tabBarContainerView.addSubview(statusView)
        } 
        self.view = view
        
        constraints += [
            tabBarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            constraintBelowSafeAreaOrAboveBottomLayout(tabBarContainerView),

            tabBar.leadingAnchor.constraint(equalTo: tabBarBackground.leadingAnchor),
            tabBar.centerYAnchor.constraint(equalTo: tabBarBackground.centerYAnchor),
            tabBar.topAnchor.constraint(equalTo: tabBarBackground.topAnchor),

            tabBarBackground.leadingAnchor.constraint(equalTo: tabBarContainerView.leadingAnchor),
            tabBarBackground.trailingAnchor.constraint(equalTo: tabBarContainerView.trailingAnchor),
            tabBarBackground.bottomAnchor.constraint(equalTo: tabBarContainerView.bottomAnchor),
            tabBarBackground.topAnchor.constraint(equalTo: tabBarContainerView.topAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        updateBarConstraints()
    }
    
    open override func viewDidLayoutSubviews() {
        if #available(iOS 11, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: tabBar.frame.height, right: 0.0)
        }
        super.viewDidLayoutSubviews()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            updateBarConstraints()
        }
        
        addCompactTabsIfCompact()
    }
    
    // MARK: - Tab bar delegate
    
    open func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let newSelectedVC = viewControllers.first(where: { $0.tabBarItem == item }) {
            if statusTabBarDelegate?.controller(self, shouldSelect: newSelectedVC) == false {
                tabBar.selectedItem = selectedViewController?.tabBarItem
                return
            }
            selectedViewController = newSelectedVC
        }
    }
    
    
    // MARK: - View controller containment
    
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
    
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return selectedViewController
    }
    
    
    // MARK: - KVO
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &tabBarStyleContext,
            (object as? NSObject) == tabBar,
            let path = keyPath,
            tabBarStyleKeys.contains(path)
            else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
        }
        
        guard isResettingTabBarAppearance == false else { return }
        
        tabBarBackground.setValue(tabBar.value(forKeyPath: path), forKeyPath: path)
        
        // Reset required keys.
        isResettingTabBarAppearance = true
        switch path {
        case #keyPath(UITabBar.backgroundImage),
             #keyPath(UITabBar.shadowImage):
            tabBar.setValue(UIImage(), forKeyPath: path)
        case #keyPath(UITabBar.isTranslucent):
            tabBar.isTranslucent = true
        default:
            break
        }
        isResettingTabBarAppearance = false
    }
    
    
    // MARK: - Private methods
    
    private func updateBarConstraints() {
        if isViewLoaded == false { return }
        
        if let constraints = barConstraints, constraints.isEmpty == false {
            NSLayoutConstraint.deactivate(constraints)
        }
        
        let tabBarBackground = self.tabBarBackground
        
        var newConstraints: [NSLayoutConstraint]
        
        if traitCollection.horizontalSizeClass == .compact {
            newConstraints = [
                tabBar.trailingAnchor.constraint(equalTo: tabBarBackground.trailingAnchor),
            ]
            
            if let statusView = self.statusView {
                newConstraints += [
                    statusView.leadingAnchor.constraint(equalTo: tabBarBackground.trailingAnchor),
                    statusView.centerYAnchor.constraint(equalTo: tabBarBackground.centerYAnchor)
                ]
            }
        } else {
            newConstraints = [
                tabBar.widthAnchor.constraint(equalToConstant: CGFloat(tabBar.items?.count ?? 0) * 108.0).withPriority(UILayoutPriority(rawValue: 800)),
            ]
            
            if let statusView = self.statusView {
                newConstraints += [
                    statusView.leadingAnchor.constraint(greaterThanOrEqualTo: tabBar.trailingAnchor),
                    statusView.widthAnchor.constraint(equalToConstant: 0.0).withPriority(UILayoutPriority(rawValue: 1)),
                    statusView.trailingAnchor.constraint(equalTo: tabBarBackground.layoutMarginsGuide.trailingAnchor),
                    statusView.topAnchor.constraint(greaterThanOrEqualTo: tabBarBackground.topAnchor),
                    statusView.centerYAnchor.constraint(equalTo: tabBarBackground.centerYAnchor),
                ]
            }
        }
        
        barConstraints = newConstraints
        NSLayoutConstraint.activate(newConstraints)
        
        forAllChildViewControllers { $0.viewIfLoaded?.setNeedsLayout() }
    }
    
    /// Adds the `compactViewControllers` array to the `viewControllers` array if we are in horizontal compact size
    private func addCompactTabsIfCompact() {
        if traitCollection.horizontalSizeClass == .compact {
            // Add compact view controllers to the tab bar
            if let compactViewControllers = compactViewControllers {
                viewControllers += compactViewControllers
            }
        } else {
            if let compactViewControllers = compactViewControllers {
                // Remove the compact controllers from the tab bar
                viewControllers = viewControllers.filter {
                    !compactViewControllers.contains($0)
                }
            }
        }
    }
}


extension UIViewController {
    
    /// The `StatusTabBarController` instance the view controller is contained in, if any.
    public var statusTabBarController: StatusTabBarController? {
        return parent(of: StatusTabBarController.self)
    }
    
    /// The inset of any status tab bar over the current content. If there is no status tab bar,
    /// returns `0.0`.
    ///
    /// This property is deprecated as of iOS 11. Use the `UIView.safeAreaInsets` instead.
    @available(iOS, introduced: 10.0, deprecated: 11.0, message: "Use `UIView.safeAreaInsets` instead.")
    public var statusTabBarInset: CGFloat {
        guard let myView = self.view,
              let statusTabBarVCView = self.statusTabBarController?.viewIfLoaded,
              myView.isDescendant(of: statusTabBarVCView),
              let statusTabBarContainerView = self.statusTabBarController?.tabBarContainerController.viewIfLoaded
            else { return 0.0 }
        
        let statusTabBarContainerInViewCoordinates = myView.convert(statusTabBarContainerView.bounds, from: statusTabBarContainerView)
        
        let myViewBounds = myView.bounds
        if myViewBounds.intersects(statusTabBarContainerInViewCoordinates) {
            return myViewBounds.height - statusTabBarContainerInViewCoordinates.minY
        }
        return 0.0
    }
    
}


