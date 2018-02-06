//
//  PSCAlertView.swift
//  MPOLKit
//
//  Created by Kyle May on 6/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public protocol PSCAlertViewDelegate: class {
    func shouldDismiss()
}

/// The alert view that is used by the `PSCAlertController`
open class PSCAlertView: UIView {
    
    public struct DefaultAppearance {
        // MARK: - Fonts
        static let titleFont = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let messageFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        // MARK: - Colors
        static let titleColor: UIColor = .primaryGray
        static let messageColor: UIColor = .secondaryGray
    }
    
    open weak var delegate: PSCAlertViewDelegate?
    open private(set) var actions: [PSCAlertAction]

    /// Text for the title or `nil`
    private var titleText: String?
    
    /// Text for the message or `nil`
    private var messageText: String?
    
    /// Image for the alert or `nil`
    private var image: UIImage?
    
    // MARK: - Views
    
    /// Label for the title text
    open let titleLabel = UILabel()
    
    /// Label for the message text
    open let messageLabel = UILabel()
    
    /// Stack view for the text and image
    private let contentStackView = UIStackView()
    
    /// View for the image
    open let imageView = UIImageView()
    
    /// Stack view for the action buttons
    private let actionsStackView = UIStackView()
    
    /// The view for the background
    private var backgroundView: UIVisualEffectView!
    
    /// Content view of the background view
    private var contentView: UIView {
        return backgroundView.contentView
    }
    
    private var blurStyle: UIBlurEffectStyle
    
    public init(frame: CGRect = .zero, title: String?, message: String?, image: UIImage?, actions: [PSCAlertAction], blurStyle: UIBlurEffectStyle = .extraLight) {
        self.actions = actions
        self.blurStyle = blurStyle
        self.titleText = title
        self.messageText = message
        self.image = image
        
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)

        contentStackView.axis = .vertical
        contentStackView.distribution = .fillProportionally
        contentStackView.spacing = 8
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.contentView.addSubview(contentStackView)
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(imageView)
        
        titleLabel.text = titleText
        titleLabel.font = DefaultAppearance.titleFont
        titleLabel.textColor = DefaultAppearance.titleColor
        titleLabel.textAlignment = .center
        contentStackView.addArrangedSubview(titleLabel)
        
        messageLabel.text = messageText
        messageLabel.font = DefaultAppearance.messageFont
        messageLabel.textColor = DefaultAppearance.messageColor
        messageLabel.textAlignment = .center
        contentStackView.addArrangedSubview(messageLabel)
        
        actionsStackView.distribution = .fillEqually
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.axis = actions.count > 2 ? .vertical : .horizontal
        
        for (index, action) in actions.enumerated() {
            let actionView = PSCAlertActionView(action: action)
            actionView.delegate = self
            // If 2 items and this is the first, give it a side divider
            if index == 0 && actions.count == 2 {
                actionView.showsSideDivider = true
            }
            actionsStackView.addArrangedSubview(actionView)
        }
        
        backgroundView.contentView.addSubview(actionsStackView)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 48),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -48),
            
            actionsStackView.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 36),
            actionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            actionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            actionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}


extension PSCAlertView: PSCAlertActionViewDelegate {
    public func shouldDismiss() {
        delegate?.shouldDismiss()
    }
}
