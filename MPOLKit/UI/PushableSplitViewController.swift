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
open class PushableSplitViewController: UIViewController {

    
    /// The split view controller embedded within the container.
    ///
    /// By default, the `embeddedSplitViewController`'s delegate is set to it's parent
    /// `PushableSplitViewController` instance.
    public let embeddedSplitViewController: UISplitViewController = EmbeddedSplitViewController()
    
    
    /// The storage for the back bar button item.
    fileprivate var backBarButtonItem: UIBarButtonItem?
    
    
    /// Initializes the pushable split view controller.
    ///
    /// - Parameter viewControllers: The view controller's to assign as children of the split view controller.
    ///                              These correspond to the `UISplitViewController.viewControllers` property.
    public init(viewControllers: [UIViewController]) {
        embeddedSplitViewController.viewControllers = viewControllers
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
    
    
    /// The back button item to apply to the nav bar of the master view controller, if available.
    open func backButtonItem() -> UIBarButtonItem? {
        if let navigationController = self.navigationController {
            
            // If we're the root view controller, hide this.
            if navigationController.viewControllers.first == self {
                return nil
            }
            
            let image = UIImage(named: "NavigationBarBackIndicator", in: Bundle(for: PushableSplitViewController.self), compatibleWith: self.traitCollection)?.withRenderingMode(.alwaysTemplate)
            
            // show back icon with pop action.
            return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backButtonItemDidSelect))
        } else if presentingViewController != nil || isBeingPresented || isBeingDismissed {
            // show close icon with dismiss action
            return UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonItemDidSelect))
        }
        return nil
    }
    
}


/// Split View Controller Delegate conformance
extension PushableSplitViewController: UISplitViewControllerDelegate {
    
}


/// Status bar appearance delegation
extension PushableSplitViewController {
    
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return embeddedSplitViewController
    }
    
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return embeddedSplitViewController
    }
    
}


/// Button actions
fileprivate extension PushableSplitViewController {
    
    @objc func backButtonItemDidSelect(_ item: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func closeButtonItemDidSelect(_ item: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}


/// Pushable Split View Controller accessors
extension UIViewController {
    
    /// The `PushableSplitViewController` instance the view controller is contained in, if any.
    open var pushableSplitViewController: PushableSplitViewController? {
        var parent = self.parent
        
        while let parentViewController = parent {
            if let pushableSplit = parentViewController as? PushableSplitViewController {
                return pushableSplit
            }
            parent = parentViewController.parent
        }
        
        return nil
    }
    
}


fileprivate class EmbeddedSplitViewController: UISplitViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        super.presentsWithGesture = false
        self.preferredDisplayMode = .allVisible
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.presentsWithGesture = false
        self.preferredDisplayMode = .allVisible
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
