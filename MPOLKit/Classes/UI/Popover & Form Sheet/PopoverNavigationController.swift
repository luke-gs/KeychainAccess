//
//  PopoverNavigationController.swift
//  MPOL
//
//  Created by Rod Brown on 1/3/2017.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit


/// A navigation controller for managing the background style of presentations with a
/// popover style.
///
/// When the navigation controller moves into the full screen presentation style
/// due to size class constraints, it updates the navigation bar and background
/// colors to appear as a standard form view controller.
///
/// When the navigation controller moves into the Popover style, the navigation bar
/// updates to be translucent, and observes theme changes to maintain correct appearance.
open class PopoverNavigationController: UINavigationController, PopoverViewController, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    /// A boolean value indicating whether the navigation controller (and its children)
    /// should be displayed with a transparent background.
    open var wantsTransparentBackground: Bool = true {
        didSet { applyCurrentTheme() }
    }
    
    
    /// An optional dismiss handler.
    ///
    /// The popover navigation controller fires this when it is about to dismiss after
    /// being presented, and passes a boolean parameter, indicating whether the dismiss
    /// will be animated.
    ///
    /// You should use this method to avoid assigning yourself as the popover presentation controller's
    /// delegate, as this will interfere with the adaptive appearance APIs.
    open var dismissHandler: ((Bool) -> Void)?
    
    
    /// `PopoverNavigationController` overrides `modalPresentationStyle` to apply standard defaults
    /// to the navigation controller presentation.
    ///
    /// - When set to `.formSheet`, the style is overriden and set to `.custom`.
    /// - When set to `.custom` (or the `.formSheet` style above), the navigation controller becomes
    ///   the transitioning delegate by default, allowing a `PopoverFormSheetPresentationController`
    ///   to be used. You can alternately set another transition delegate and take over management of
    ///   the custom presentation.
    /// - When set to `.popover`, the navigation controller becomes the popover presentation
    ///   controller's delegate by default. If you need to handle close notifications from the popover
    ///   presentation controller, you should instead use the `dismissHandler` to avoid interfering
    ///   with the adaptive appearance APIs.
    open override var modalPresentationStyle: UIModalPresentationStyle {
        didSet {
            switch modalPresentationStyle {
            case .formSheet:
                modalPresentationStyle = .custom
                fallthrough
            case .custom:
                transitioningDelegate = self
            case .popover:
                popoverPresentationController?.delegate = self
                fallthrough
            default:
                transitioningDelegate = nil
                formSheetPresentationController = nil
            }
        }
    }
    
    
    /// `PopoverNavigationController overrides the `delegate` property and sets it to itself.
    /// Setting this property has no effect.
    ///
    /// If you wish to receive the delegate methods, it is recommended you subclass this class.
    open override weak var delegate: UINavigationControllerDelegate? {
        get { return self }
        set { }
    }
    
    
    private var formSheetPresentationController: PopoverFormSheetPresentationController?
    
    
    // MARK: - Initializers
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        super.delegate = self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
        super.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
        super.delegate = self
    }
    
    
    // MARK: - Overrides
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        applyCurrentTheme()
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        (viewController as? PopoverViewController)?.wantsTransparentBackground = wantsTransparentBackground
        super.pushViewController(viewController, animated: animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed {
            dismissHandler?(animated)
        }
    }
    
    
    // MARK: - UINavigationControllerDelegate methods
    
    open func navigationController(_ navigationController: UINavigationController,
                                   animationControllerFor operation: UINavigationControllerOperation,
                                   from fromVC: UIViewController,
                                   to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return wantsTransparentBackground ? ViewControllerAnimationOptionTransition(transition: .transitionCrossDissolve, duration: 0.2) : nil
    }
    
    
    // MARK: - UIPopoverPresentationControllerDelegate methods
    
    open func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.horizontalSizeClass == .compact { return .fullScreen }
        return .none
    }
    
    open func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        wantsTransparentBackground = (style == .none && (modalPresentationStyle == .popover || modalPresentationStyle == .custom))
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate methods
    
    open func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        formSheetPresentationController = PopoverFormSheetPresentationController(presentedViewController: presented, presenting: presenting)
        formSheetPresentationController?.delegate = self
        return formSheetPresentationController
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return formSheetPresentationController?.traitCollection.horizontalSizeClass == .compact ? nil : formSheetPresentationController
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return formSheetPresentationController?.traitCollection.horizontalSizeClass == .compact ? nil : formSheetPresentationController
    }
    
    
    // MARK: - Private methods
    
    @objc private func applyCurrentTheme() {
        if isViewLoaded == false { return }
        
        let theme = Theme.current
        
        let navigationBar = self.navigationBar
        let transparent = self.wantsTransparentBackground
        
        if transparent {
            navigationBar.tintColor   = nil
            navigationBar.barStyle    = theme.isDark ? .black : .default
            navigationBar.setBackgroundImage(nil, for: .default)
            
            // Workaround
            if UIDevice.current.userInterfaceIdiom == .phone {
                view.backgroundColor = theme.isDark ? #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) : .clear
            } else {
                view.backgroundColor = .clear
            }
        } else {
            navigationBar.barStyle      = theme.navigationBarStyle
            navigationBar.tintColor     = theme.colors[.NavigationBarTint]
            navigationBar.setBackgroundImage(theme.navigationBarBackgroundImage, for: .default)
            view.backgroundColor = .clear
        }
        
        viewControllers.forEach {
            ($0 as? PopoverViewController)?.wantsTransparentBackground = transparent
        }
    }
    
}

