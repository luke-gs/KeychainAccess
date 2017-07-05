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


open class StatusTabBarController: UIViewController, UITabBarDelegate {
    
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
    
    open var selectedViewController: UIViewController? {
        didSet {
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
    
    open var statusView: UIView? {
        didSet {
            if statusView != oldValue || isViewLoaded == false { return }
            
            oldValue?.removeFromSuperview()
            if let newStatusView = self.statusView {
                newStatusView.translatesAutoresizingMaskIntoConstraints = false
                tabBarContainerController.view.addSubview(newStatusView)
            }
            updateBarConstraints()
        }
    }
    
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
            statusView.translatesAutoresizingMaskIntoConstraints = false
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
                tabBar.widthAnchor.constraint(equalToConstant: CGFloat(tabBar.items?.count ?? 0) * 108.0).withPriority(UILayoutPriorityDefaultHigh),
                statusViewBackground.heightAnchor.constraint(equalToConstant: 0.0)
            ]
            
            if let statusView = self.statusView {
                newConstraints += [
                    statusView.leadingAnchor.constraint(greaterThanOrEqualTo: tabBar.leadingAnchor),
                    statusView.trailingAnchor.constraint(equalTo: tabBarBackground.layoutMarginsGuide.trailingAnchor),
                    statusView.heightAnchor.constraint(lessThanOrEqualTo: tabBarBackground.heightAnchor),
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
    
    public var statusTabBarController: StatusTabBarController? {
        return parent(of: StatusTabBarController.self)
    }
    
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


