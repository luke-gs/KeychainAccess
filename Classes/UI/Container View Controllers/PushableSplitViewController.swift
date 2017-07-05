//
//  PushableSplitViewController.swift
//  Test
//
//  Created by Rod Brown on 10/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// A wrapper view controller for `UISplitViewController` which allows it to be pushed onto a
/// `UINavigationController` stack.
///
/// PushableSplitViewController hides the navigation bar of a parent navigation controller when it appears.
/// Users that require the navigation bar to reappear when it disappears should do so in `viewWillAppear(_:)`
/// when the split view controller is popped off the navigation stack.
open class PushableSplitViewController: UIViewController, UISplitViewControllerDelegate {

    
    /// The split view controller embedded within the container.
    ///
    /// By default, the `embeddedSplitViewController`'s delegate is set to it's parent
    /// `PushableSplitViewController` instance.
    public let embeddedSplitViewController: UISplitViewController
    
    
    /// The storage for the back bar button item.
    private var backBarButtonItem: UIBarButtonItem?
    
    
    /// Initializes the pushable split view controller.
    ///
    /// - Parameter viewControllers: The view controller's to assign as children of the split view controller.
    ///                              These correspond to the `UISplitViewController.viewControllers` property.
    public init(viewControllers: [UIViewController]) {
        embeddedSplitViewController = EmbeddedSplitViewController(viewControllers: viewControllers)
        super.init(nibName: nil, bundle: nil)
        
        embeddedSplitViewController.delegate = self
        
        addChildViewController(embeddedSplitViewController)
        embeddedSplitViewController.didMove(toParentViewController: self)
    }
    
    
    /// `PushableSplitViewController` does not currently support NSCoding.
    public required init?(coder aDecoder: NSCoder) {
        fatalError("PushableSplitViewController does not currently support NSCoding.")
    }
    
    
    deinit {
        embeddedSplitViewController.willMove(toParentViewController: nil)
        embeddedSplitViewController.removeFromParentViewController()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let splitView = embeddedSplitViewController.view {
            splitView.frame = view.bounds
            splitView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(splitView)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if let masterNavController = embeddedSplitViewController.viewControllers.first as? UINavigationController,
           let rootNavItem = masterNavController.viewControllers.first?.navigationItem,
           let backButtonItem = backBarButtonItem ?? backButtonItem() {
            
            // Set the property, in case we fetched it lazily from backButtonItem().
            backBarButtonItem = backButtonItem
            
            // Add the back item.
            var leftItems = rootNavItem.leftBarButtonItems ?? []
            if leftItems.contains(backButtonItem) == false {
                leftItems.insert(backButtonItem, at: 0)
                rootNavItem.leftBarButtonItems = leftItems
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // We don't reset the nav bar back to its correct position when:
        // 1. We are being dismissed.
        //    This would create a weird appearance as part of the disappearance.
        // 2. We are getting this as part of a presentation of a new view controller that hides us.
        //    We detect this by checking if the presented view controller (if it exists) is being presented.
        // 3. The new view controller in the transition is not a pushable view controller,
        //    which would make it disappear anyway.
        
        if isBeingDismissed || presentedViewController?.isBeingPresented ?? false || transitionCoordinator?.viewController(forKey: .to) is PushableSplitViewController { return }
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    /// The back button item to apply to the nav bar of the master view controller, if available.
    open func backButtonItem() -> UIBarButtonItem? {
        if let navigationController = self.navigationController {
            
            // If we're the root view controller, hide this.
            if navigationController.viewControllers.first == self {
                return nil
            }
            
            let arrowImage = UIImage(named: "NavigationBarBackIndicator", in: .mpolKit, compatibleWith: self.traitCollection)?.withRenderingMode(.alwaysTemplate)
            // show back icon with pop action.
            let backItem = UIBarButtonItem(image: arrowImage, style: .plain, target: self, action: #selector(backButtonItemDidSelect))
            backItem.accessibilityLabel = NSLocalizedString("Back", comment: "Navigation bar button item accessibility")
            return backItem
        } else if presentingViewController != nil || isBeingPresented || isBeingDismissed {
            // show close icon with dismiss action
            let closeItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonItemDidSelect))
            closeItem.accessibilityLabel = NSLocalizedString("Close", comment: "Navigation bar button item accessibility")
            return closeItem
        }
        return nil
    }
    
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return embeddedSplitViewController
    }
    
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return embeddedSplitViewController
    }
    
    // MARK: - Button actions
    @objc private func backButtonItemDidSelect(_ item: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func closeButtonItemDidSelect(_ item: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

/// Pushable Split View Controller accessors
extension UIViewController {
    
    /// The `PushableSplitViewController` instance the view controller is contained in, if any.
    public var pushableSplitViewController: PushableSplitViewController? {
        return parent(of: PushableSplitViewController.self)
    }
    
}


private class EmbeddedSplitViewController: UISplitViewController {
    
    init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        super.presentsWithGesture = false
        preferredDisplayMode = .allVisible
    }
    
    /// Blocks presenting with a gesture. This works around a bug in UISplitViewController within a navigation and tab stack.
    open override var presentsWithGesture: Bool {
        get { return false }
        set { }
    }
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return viewControllers.first
    }
    
    open override var childViewControllerForStatusBarHidden : UIViewController? {
        return viewControllers.first
    }
    
}
