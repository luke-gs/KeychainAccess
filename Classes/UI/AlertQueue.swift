//
//  AlertQueue.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/4/17.
//
//

import UIKit


/// `AlertQueue` is a singleton alert manager that handles presenting alerts sequentially
/// and outside the view controller hierachy where possible. Each alert is presented in
/// a queue to avoid a "doubling up" presentations.
///
/// This class should only be accessed from the main thread.
public final class AlertQueue: NSObject {
    
    /// Singleton instance of the AlertQueue
    public static let shared = AlertQueue()
    
    
    
    // MARK: - Public properties
    
    /// The current extension view controller, if any. The default is `nil`.
    ///
    /// - Important: You should only set this value in an app extension. `AlertQueue`
    ///   prefers to present within its own managed window, however this is not possible
    ///   in an app extension, and you should specify the presentation scope. You must not
    ///   change this after the first presentation has occured.
    public var extensionViewController: UIViewController?  {
        didSet {
            assert(alertContainerViewController == nil, "Cannot change extensionViewController after a presentation has occurred.")
        }
    }
    
    
    /// All alerts that are pending to display
    public private(set) var queue: [UIAlertController] = []
    
    
    /// The alert that is currently being displayed on screen.
    public private(set) var presentingAlert: UIAlertController?
    
    
    /// The tint color for the alert.
    ///
    /// - Note: This property only affects appearance when presented without an
    ///   `extensionViewController` context set. When presented with an extension
    ///   view controller, the alert will inherit the default view hierarchy `tintColor`.
    public var tintColor: UIColor? {
        didSet { window?.tintColor = tintColor }
    }
    
    
    /// Preferred status bar style when presenting alerts.
    public var preferredStatusBarStyle: UIStatusBarStyle = .default {
        didSet {
            alertContainerViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    
    
    // MARK: - Private properties
    
    private var alertContainerViewController: AlertContainerViewController?
    
    
    private var window: UIWindow? {
        didSet { window?.tintColor = tintColor }
    }
    
    
    // MARK: - Initializer
    
    /// The initializer is private. This manintains guaranteed signleton state.
    override private init() {
    }
    
    
    // MARK: - Public methods
    
    /// Adds a new alert controller to the queue.
    ///
    /// - Parameter alertController: The alert controller to be added.
    public func add(_ alertController: UIAlertController) {
        assert(Thread.isMainThread, "AlertQueue should only be accessed from the main thread.")
        
        queue.append(alertController)
        
        presentAlerts()
    }

    /// Add a new error alert with OK button and standard Error title
    public func addErrorAlert(message: String?) {
        let title = NSLocalizedString("Error", comment: "Alert error title")
        addSimpleAlert(title: title, message: message)
    }

    /// Add a simple alert with OK button
    public func addSimpleAlert(title: String?, message: String?) {
        let buttonTitle = NSLocalizedString("OK", comment: "Alert OK button")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: nil))
        AlertQueue.shared.add(alertController)
    }
    
    
    // MARK: - Private methods
    
    /// Presents alert task from the queue
    private func presentAlerts() {
        
        guard presentingAlert == nil,
              queue.isEmpty == false else { return }
        
        let nextAlert = queue.removeFirst()
        presentingAlert = nextAlert
        present(nextAlert, animated: true)
    }
    
    
    /// Presents the view controller in the alert container, creating it if necessary.
    ///
    /// - Parameters:
    ///   - viewControllerToPresent: The view controller for presentation.
    ///   - animated: A boolean value indicating if the transition should be animated.
    private func present(_ viewControllerToPresent: UIViewController, animated: Bool) {
        
        let alertContainer: AlertContainerViewController
        
        if let existingContainer = alertContainerViewController {
            alertContainer = existingContainer
        } else {
            alertContainer = AlertContainerViewController()
            alertContainer.modalPresentationStyle = .overFullScreen
            alertContainerViewController = alertContainer
            
            if let baseViewController = extensionViewController {
                baseViewController.deepestPresentedViewController.present(alertContainer, animated: false)
            } else {
                self.window?.isHidden = true
                
                let window = UIWindow()
                window.windowLevel        = UIWindowLevelAlert
                window.rootViewController = alertContainer
                window.tintColor          = self.tintColor
                window.backgroundColor    = .clear
                window.makeKeyAndVisible()
                self.window = window
            }
        }
        
        alertContainer.present(viewControllerToPresent, animated: animated)
    }
    
    fileprivate func alertDidFinish() {
        presentingAlert = nil
        
        if queue.isEmpty {
            if extensionViewController != nil {
                alertContainerViewController?.dismiss(animated: false)
                alertContainerViewController = nil
            } else {
                alertContainerViewController = nil
                window?.isHidden = true
                window = nil
            }
        } else {
            presentAlerts()
        }
    }
    
}


/// A private class that handles detecting the dismiss operation, and updating the
/// status bar style.
fileprivate class AlertContainerViewController: UIViewController {
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if presentedViewController == nil {
            super.dismiss(animated: flag, completion: completion)
            return
        }
        
        super.dismiss(animated: flag) { () -> Void in
            completion?()
            AlertQueue.shared.alertDidFinish()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return AlertQueue.shared.preferredStatusBarStyle
    }
}


fileprivate extension UIViewController {
    
    /// The deepest presented view controller for this view controller, or self.
    ///
    /// Really this is a bit of a hack. There's a lot of state transition that doesn't work
    /// really well and we're doing a "best effort" to try and find the deepest presented.
    var deepestPresentedViewController: UIViewController {
        var viewController = self
        while let presented = viewController.presentedViewController,
            presented.isBeingPresented == false,
            presented.isBeingDismissed == false {
                viewController = presented
        }
        return viewController
    }
}
