//
//  StatusTabBarController.swift
//  MPOLKit
//
//  Created by Rod Brown on 5/7/17.
//

import UIKit

private var tabBarStyleContext = 1

private let tabBarStyleKeys: [String] = [
    #keyPath(UITabBar.barStyle),
    #keyPath(UITabBar.backgroundImage),
    #keyPath(UITabBar.shadowImage),
    #keyPath(UITabBar.barTintColor),
    #keyPath(UITabBar.isTranslucent)
]


/// A view controller for presenting a tabbed interface, with a hosted status view.
///
/// `StatusTabBarController` replaces a standard tab bar controller, and pushes the tab bar to
/// the leading edge, allowing the status view to appear at the trailing edge. When in a
/// horizontally compacy environment, the status view shifts to above the tab bar.
///
/// To adjust the appearance of the full tab bar, simply adjust the appearance of the `tabBar`
/// property. These changes will auto-translate to the full bar.
///
/// Prior to iOS 11, custom container view controllers are not supported updating the
/// `topLayoutGuide` and `bottomLayoutGuide` properties. On these platforms, it is recommended
/// that your child view controllers observe the `UIViewController.statusTabBarInset` property.
/// On iOS 11, `StatusTabBarController` should correctly update the `safeAreaInsets` applied
/// to child view controllers.
///
/// Unlike `UITabBarController`, the status tab bar controller does not automatically shift
/// shift additional view controllers into a more tab. Users should do this with custom behaviour
/// if required.
open class StatusTabBarController: UIViewController, UITabBarDelegate {
    
    
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
    /// This view is sized with AutoLayout, and placed within the tab bar in a horizontally
    /// regular environment. In a horizontally compact environment, it is placed above the
    /// tab bar.
    open var statusView: UIView? {
        didSet {
            if statusView != oldValue || isViewLoaded == false { return }
            
            oldValue?.removeFromSuperview()
            if let newStatusView = self.statusView {
                if newStatusView.translatesAutoresizingMaskIntoConstraints {
                    let size = newStatusView.frame.size
                    newStatusView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        newStatusView.widthAnchor.constraint(equalToConstant: abs(size.width)).withPriority(UILayoutPriorityDefaultLow),
                        newStatusView.heightAnchor.constraint(equalToConstant: abs(size.height)).withPriority(UILayoutPriorityDefaultLow)
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
    
    private var statusViewBackground: UIView?
    
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
        
        let statusViewBackground = UIView(frame: .zero)
        statusViewBackground.translatesAutoresizingMaskIntoConstraints = false
        statusViewBackground.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        tabBarContainerView.addSubview(statusViewBackground)
        
        tabBarBackground.translatesAutoresizingMaskIntoConstraints = false
        tabBarContainerView.addSubview(tabBarBackground)
        
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBarContainerView.addSubview(tabBar)
        
        if let statusView = self.statusView {
            if statusView.translatesAutoresizingMaskIntoConstraints {
                let size = statusView.frame.size
                statusView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    statusView.widthAnchor.constraint(equalToConstant: size.width).withPriority(UILayoutPriorityDefaultLow),
                    statusView.heightAnchor.constraint(equalToConstant: size.height).withPriority(UILayoutPriorityDefaultLow)
                ])
            }
            tabBarContainerView.addSubview(statusView)
        }
        
        self.statusViewBackground = statusViewBackground
        self.view = view
        
        NSLayoutConstraint.activate([
            tabBarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarContainerView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            
            tabBar.leadingAnchor.constraint(equalTo: tabBarBackground.leadingAnchor),
            tabBar.centerYAnchor.constraint(equalTo: tabBarBackground.centerYAnchor),
            tabBar.topAnchor.constraint(equalTo: tabBarBackground.topAnchor),
            
            tabBarBackground.leadingAnchor.constraint(equalTo: tabBarContainerView.leadingAnchor),
            tabBarBackground.trailingAnchor.constraint(equalTo: tabBarContainerView.trailingAnchor),
            tabBarBackground.topAnchor.constraint(equalTo: statusViewBackground.bottomAnchor),
            tabBarBackground.bottomAnchor.constraint(equalTo: tabBarContainerView.bottomAnchor),
            
            statusViewBackground.topAnchor.constraint(equalTo: tabBarContainerView.topAnchor),
            statusViewBackground.leadingAnchor.constraint(equalTo: tabBarContainerView.leadingAnchor),
            statusViewBackground.trailingAnchor.constraint(equalTo: tabBarContainerView.trailingAnchor),
        ])
        
        updateBarConstraints()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            updateBarConstraints()
        }
    }
    
    
    // MARK: - Tab bar delegate
    
    open func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let newSelectedVC = viewControllers.first(where: { $0.tabBarItem == item }) {
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
        let statusViewBackground = self.statusViewBackground!
        
        var newConstraints: [NSLayoutConstraint]
        
        if traitCollection.horizontalSizeClass == .compact {
            newConstraints = [
                tabBar.trailingAnchor.constraint(equalTo: tabBarBackground.trailingAnchor),
            ]
            
            if let statusView = self.statusView {
                newConstraints += [
                    statusView.widthAnchor.constraint(lessThanOrEqualTo: statusView.widthAnchor),
                    statusView.centerXAnchor.constraint(equalTo: statusViewBackground.centerXAnchor),
                    statusView.centerYAnchor.constraint(equalTo: statusViewBackground.centerYAnchor),
                    statusView.topAnchor.constraint(equalTo: statusViewBackground.layoutMarginsGuide.topAnchor)
                ]
            } else {
                newConstraints.append(statusViewBackground.heightAnchor.constraint(equalToConstant: 0.0))
            }
        } else {
            newConstraints = [
                tabBar.widthAnchor.constraint(equalToConstant: CGFloat(tabBar.items?.count ?? 0) * 108.0).withPriority(800),
                statusViewBackground.heightAnchor.constraint(equalToConstant: 0.0)
            ]
            
            if let statusView = self.statusView {
                newConstraints += [
                    statusView.leadingAnchor.constraint(greaterThanOrEqualTo: tabBar.trailingAnchor),
                    statusView.widthAnchor.constraint(equalToConstant: 0.0).withPriority(1),
                    statusView.trailingAnchor.constraint(equalTo: tabBarBackground.layoutMarginsGuide.trailingAnchor),
                    statusView.topAnchor.constraint(greaterThanOrEqualTo: tabBarBackground.layoutMarginsGuide.topAnchor),
                    statusView.centerYAnchor.constraint(equalTo: tabBarBackground.centerYAnchor),
                ]
            }
        }
        
        barConstraints = newConstraints
        NSLayoutConstraint.activate(newConstraints)
        
        forAllChildViewControllers { $0.viewIfLoaded?.setNeedsLayout() }
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


