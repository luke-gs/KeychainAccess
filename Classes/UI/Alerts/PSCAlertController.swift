//
//  PSCAlertController.swift
//  MPOLKit
//
//  Created by Kyle May on 6/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Large `UIAlertViewController` replica for PSCore style.
open class PSCAlertController: UIViewController {
    
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
    
    // MARK: - Setup
    
    public init(title: String?, message: String?, image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.titleText = title
        self.messageText = message
        self.image = image
        modalPresentationStyle = .formSheet
        modalTransitionStyle = .crossDissolve
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
        
        let alertView = PSCAlertView(actions: actions)
        alertView.titleLabel.text = titleText
        alertView.messageLabel.text = messageText
        alertView.imageView.image = image
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
