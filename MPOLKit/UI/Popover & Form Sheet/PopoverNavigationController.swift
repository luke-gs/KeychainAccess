//
//  PopoverNavigationController.swift
//  MPOL
//
//  Created by Rod Brown on 8/08/2016.
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
public class PopoverNavigationController: UINavigationController {
    
    public var wantsTransparentBackground: Bool = true {
        didSet { applyCurrentTheme() }
    }
    
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
    
}


extension PopoverNavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return wantsTransparentBackground ? ViewControllerTransition(transition: .transitionCrossDissolve, duration: 0.2) : nil
    }
}


extension PopoverNavigationController: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.horizontalSizeClass == .compact {
            return .fullScreen
        }
        return .none
    }
    
    public func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        wantsTransparentBackground = (style == .none && (modalPresentationStyle == .popover || modalPresentationStyle == .custom))
    }
    
}


extension PopoverNavigationController {
    
    public override var delegate: UINavigationControllerDelegate? {
        get { return self }
        set { }
    }
    
    public override var modalPresentationStyle: UIModalPresentationStyle {
        didSet {
            switch modalPresentationStyle {
            case .formSheet, .custom:
                presentationController?.delegate = self
            case .popover:
                popoverPresentationController?.delegate = self
            default:
                presentationController?.delegate = nil
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        applyCurrentTheme()
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        (viewController as? PopoverViewController)?.wantsTransparentBackground = wantsTransparentBackground
        super.pushViewController(viewController, animated: animated)
    }
    
}


fileprivate extension PopoverNavigationController {
    
    @objc fileprivate func applyCurrentTheme() {
        if isViewLoaded == false { return }
        
        let theme = Theme.current
        
        let navigationBar = self.navigationBar
        let transparent = self.wantsTransparentBackground
        
        if transparent {
            navigationBar.isTranslucent = true
            navigationBar.tintColor   = nil
            navigationBar.barStyle    = theme.isDark ? .black : .default
            navigationBar.setBackgroundImage(nil, for: .default)
            if UIDevice.current.userInterfaceIdiom == .phone {
                view.backgroundColor = theme.isDark ? #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) : .clear
            } else {
                view.backgroundColor = .clear
            }
        } else {
            navigationBar.barStyle      = theme.navigationBarStyle
            navigationBar.isTranslucent = false
            navigationBar.tintColor     = theme.colors[.NavigationBarTint]
            navigationBar.setBackgroundImage(theme.navigationBarBackgroundImage, for: .default)
            view.backgroundColor = .clear
        }
        
        viewControllers.forEach {
            ($0 as? PopoverViewController)?.wantsTransparentBackground = transparent
        }
        
    }
    
}

