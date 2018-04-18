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
    
    /// Optional transparent background to use when light color style
    public var lightTransparentBackground: UIColor?

    open var userInterfaceStyle: UserInterfaceStyle = .current {
        didSet {
            if userInterfaceStyle == oldValue { return }
            
            if userInterfaceStyle == .current {
                NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .interfaceStyleDidChange, object: nil)
            } else if oldValue == .current {
                NotificationCenter.default.removeObserver(self, name: .interfaceStyleDidChange, object: nil)
            }
            
            applyTheme()
        }
    }
    
    
    /// A boolean value indicating whether the navigation controller (and its children)
    /// should be displayed with a transparent background.
    open var wantsTransparentBackground: Bool = true {
        didSet { applyTheme() }
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
    
    
    private var formSheetPresentationController: PopoverSheetPresentationController?
    
    private lazy var doneButtonItem: UIBarButtonItem = { [unowned self] in
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonItemDidSelect(_:)))
    }()
    
    private var doneButtonInstalledNavItem: UINavigationItem?
    
    
    // MARK: - Initializers
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        super.delegate = self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        super.delegate = self
        if userInterfaceStyle == .current {
            NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .interfaceStyleDidChange, object: nil)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.delegate = self
        if userInterfaceStyle == .current {
            NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .interfaceStyleDidChange, object: nil)
        }
    }
    
    
    // MARK: - Overrides
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // Disable content under nav bar when shown in this popover controller
        viewController.edgesForExtendedLayout.remove(.top)

        (viewController as? PopoverViewController)?.wantsTransparentBackground = wantsTransparentBackground
        super.pushViewController(viewController, animated: animated)
    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        if let poppedViewController = super.popViewController(animated: animated) {
            
            if poppedViewController.navigationItem == doneButtonInstalledNavItem {
                removeDoneButton()
            }
            
            return poppedViewController
        }
        return nil
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
        switch style {
        case .fullScreen, .overFullScreen:
            if isModalInPopover == false, let rootViewControllerItem = viewControllers.first?.navigationItem {
                installDoneButton(on: rootViewControllerItem)
            }
            break
        default:
            removeDoneButton()
            break
        }
        
        wantsTransparentBackground = (style == .none && (modalPresentationStyle == .popover || modalPresentationStyle == .custom))
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate methods
    
    open func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        formSheetPresentationController = PopoverSheetPresentationController(presentedViewController: presented, presenting: presenting)
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
    
    @objc private func applyTheme() {
        let theme = ThemeManager.shared.theme(for: userInterfaceStyle)
        
        popoverPresentationController?.backgroundColor = theme.color(forKey: .popoverBackground)
        
        if isViewLoaded == false { return }
        
        let navigationBar = self.navigationBar
        let transparent = self.wantsTransparentBackground
        
        if transparent {
            navigationBar.tintColor   = nil
            navigationBar.barStyle    = userInterfaceStyle.isDark ? .black : .default
            navigationBar.setBackgroundImage(nil, for: .default)
            
            if let lightTransparentBackground = lightTransparentBackground, ThemeManager.shared.currentInterfaceStyle == .light {
                view.backgroundColor = lightTransparentBackground
            } else {
                view.backgroundColor = .clear
            }
        } else {
            navigationBar.barStyle      = theme.navigationBarStyle
            navigationBar.tintColor     = theme.color(forKey: .navigationBarTint)
            navigationBar.setBackgroundImage(theme.image(forKey: .navigationBarBackground), for: .default)
            view.backgroundColor = .clear
        }
        
        viewControllers.forEach {
            ($0 as? PopoverViewController)?.wantsTransparentBackground = transparent
        }
    }
    
    @objc private func doneButtonItemDidSelect(_ item: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    
    private func installDoneButton(on item: UINavigationItem) {
        let leftDoneButton = item.leftBarButtonItems?.first { $0.style == .done }
        let rightDoneButton = item.rightBarButtonItems?.first { $0.style == .done }
        // Don't add a new done button if we already have one
        guard rightDoneButton == nil, leftDoneButton == nil else {
            return
        }
        if item.rightBarButtonItems?.isEmpty ?? true {
            item.rightBarButtonItems = [doneButtonItem]
            doneButtonInstalledNavItem = item
        } else if item.leftBarButtonItems?.isEmpty ?? true {
            item.leftBarButtonItems = [doneButtonItem]
            doneButtonInstalledNavItem = item
        }
    }
    
    private func removeDoneButton() {
        guard let item = doneButtonInstalledNavItem else { return }
        
        if var rightItems = item.rightBarButtonItems, let indexOfDone = rightItems.index(of: doneButtonItem) {
            rightItems.remove(at: indexOfDone)
            item.rightBarButtonItems = rightItems
        } else if var leftItems = item.leftBarButtonItems, let indexOfDone = leftItems.index(of: doneButtonItem) {
            leftItems.remove(at: indexOfDone)
            item.leftBarButtonItems = leftItems
        }
        
        doneButtonInstalledNavItem = nil
    }
    
}

