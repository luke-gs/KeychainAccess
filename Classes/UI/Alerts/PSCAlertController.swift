//
//  PSCAlertController.swift
//  MPOLKit
//
//  Created by Kyle May on 6/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Large `UIAlertViewController` replica for PSCore style.
open class PSCAlertController: ThemedPopoverViewController {
    
    /// The alert view to display in the controller
    private var alertView: PSCAlertView?
    
    // MARK: - Content
    
    /// Text for the title or `nil`
    private var titleText: String?
    
    /// Text for the message or `nil`
    private var messageText: String?
    
    /// Image for the alert or `nil`
    private var image: UIImage?
    
    /// Actions
    open private(set) var actions: [PSCAlertAction] = []
    
    // MARK: - UI Customization
    
    /// The title label for the alert view
    open var titleLabel: UILabel? {
        return alertView?.titleLabel
    }
    
    /// The message label for the alert view
    open var messageLabel: UILabel? {
        return alertView?.messageLabel
    }
    
    /// The image view for the alert view
    open var imageView: UIImageView? {
        return alertView?.imageView
    }
    
    open var popoverParent: UIViewController? {
        didSet {
            popoverPresentationController?.sourceView = popoverParent?.view
            popoverPresentationController?.sourceRect = popoverParent?.view.bounds ?? .zero
        }
    }
    
    // MARK: - Setup
    
    public init(title: String?, message: String?, image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.titleText = title
        self.messageText = message
        self.image = image
//        modalPresentationStyle = .formSheet
//        modalTransitionStyle = .crossDissolve
        // Present the source selection as a centered popover, rather than form sheet, so we can control size
        modalPresentationStyle = .popover
        popoverPresentationController?.permittedArrowDirections = []
        popoverPresentationController?.delegate = self
        presentationController?.delegate = self
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Update the source rect so the popover stays centered on rotation
        if let parent = presentingViewController {
            coordinator.animate(alongsideTransition: { (context) in
                self.popoverPresentationController?.sourceRect = parent.view.bounds
            }, completion: nil)
        }
    }

    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        preferredContentSize = CGSize(width: 512, height: view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        view.backgroundColor = .clear
        
        let alertView = PSCAlertView(title: titleText, message: messageText, image: image, actions: actions)
        
        alertView.delegate = self
        alertView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertView)
        
        self.alertView = alertView
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        guard let alertView = alertView else { return }
        NSLayoutConstraint.activate([
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    /// Adds an action to the alert view
    public func addAction(_ action: PSCAlertAction) {
        assert(alertView == nil, "You cannot add an action to a PSCAlertController after the view has loaded")
        
        actions.append(action)
    }
}

extension PSCAlertController: PSCAlertViewDelegate {
    public func shouldDismiss() {
        dismissAnimated()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension PSCAlertController: UIAdaptivePresentationControllerDelegate {
    
    /// Present view controllers using requested style, regardless of device
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    /// Present view controllers using requested style, regardless of device
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension PSCAlertController: UIPopoverPresentationControllerDelegate {
    
    /// Prevent closing of popover
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
}

