//
//  PSCAlertController.swift
//  MPOLKit
//
//  Created by Kyle May on 6/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Large style `UIAlertViewController` replica for PSCore style.
open class PSCAlertController: ThemedPopoverViewController {
    
    public struct LayoutConstants {
        public static let preferredWidth: CGFloat = 512
        public static let sideMargins: CGFloat = 24
    }
    
    // MARK: - Content (only used during setup, can't set up in init – trust me.)
    
    /// Text for the title or `nil`
    private var titleText: String?
    
    /// Text for the message or `nil`
    private var messageText: String?
    
    /// Image for the alert or `nil`
    private var image: UIImage?
    
    /// Actions
    open private(set) var actions: [DialogAction] = []
    
    
    // MARK: - Views
    
    /// The alert view to display in the controller
    private var alertView: PSCAlertView?
    
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
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return AlertQueue.shared.preferredStatusBarStyle
    }
    
    // MARK: - Setup
    
    public init(title: String?, message: String?, image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.titleText = title
        self.messageText = message
        self.image = image
        modalTransitionStyle = .crossDissolve
    }
    
    // MARK: - Setup
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
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
            alertView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: LayoutConstants.sideMargins),
            alertView.widthAnchor.constraint(equalToConstant: LayoutConstants.preferredWidth).withPriority(.defaultHigh),
            alertView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: LayoutConstants.sideMargins),
            alertView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -LayoutConstants.sideMargins),
            alertView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -LayoutConstants.sideMargins),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    /// Adds an action to the alert view. This should only be called before presenting the view controller.
    public func addAction(_ action: DialogAction) {
        assert(alertView == nil, "You cannot add an action to a PSCAlertController after the view has loaded")
        actions.append(action)
    }
    
    /// Adds actions to the alert view. This should only be called before presenting the view controller.
    public func addActions(_ actions: [DialogAction]) {
        assert(alertView == nil, "You cannot add an action to a PSCAlertController after the view has loaded")
        self.actions += actions
    }
}

extension PSCAlertController: PSCAlertViewDelegate {
    public func shouldDismiss() {
        if presentingViewController is AlertContainerViewController {
            presentingViewController?.dismiss(animated: true)
        }
        dismiss(animated: true)
    }
}
