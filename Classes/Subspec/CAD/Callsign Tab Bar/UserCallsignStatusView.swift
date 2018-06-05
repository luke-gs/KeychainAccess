//
//  UserCallsignStatusView.swift
//  MPOLKit
//
//  Created by Kyle May on 7/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// User callsign status view in the tab bar
open class UserCallsignStatusView: UIControl {
    
    public let viewModel: UserCallsignStatusViewModel
    
    // MARK: - Constants
    
    public struct LayoutConstants {
        public static let iconSize: CGFloat = 24
        public static let imageMargin: CGFloat = 12
        public static let iconTextMargin: CGFloat = 12
        public static let textMargin: CGFloat = 8
    }
    
    // MARK: - Views
    
    open var iconImageView: UIImageView!
    open var textStackView: UIStackView!
    open var titleStackView: UIStackView!
    open var titleLabel: UILabel!
    open var countLabel: UILabel!
    open var subtitleLabel: UILabel!
    
    open override var isEnabled: Bool {
        didSet {
            if isEnabled {
                iconImageView.tintColor = .black
                titleLabel.textColor = .primaryGray
                subtitleLabel.textColor = .secondaryGray
            } else {
                iconImageView.tintColor = .disabledGray
                titleLabel.textColor = .disabledGray
                subtitleLabel.textColor = .disabledGray
            }
        }
    }

    // MARK: - Setup

    public init(viewModel: UserCallsignStatusViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupViews()
        setupConstraints()
        updateViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    open func setupViews() {
        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.isUserInteractionEnabled = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = .primaryGray
        titleLabel.isUserInteractionEnabled = false
        
        countLabel = UILabel()
        countLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        countLabel.textColor = .primaryGray
        countLabel.isUserInteractionEnabled = false
        
        subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        subtitleLabel.textColor = .secondaryGray
        subtitleLabel.isUserInteractionEnabled = false
        
        titleStackView = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        titleStackView.distribution = .fill
        titleStackView.spacing = 2
        titleStackView.axis = .horizontal
        titleStackView.isUserInteractionEnabled = false
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleStackView)

        textStackView = UIStackView(arrangedSubviews: [titleStackView, subtitleLabel])
        textStackView.axis = .vertical
        textStackView.isUserInteractionEnabled = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textStackView)
    }
    
    /// Activates view constraints
    open func setupConstraints() {
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.iconSize),
            iconImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.iconSize),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            textStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: LayoutConstants.iconTextMargin),
            textStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: LayoutConstants.textMargin),
            textStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -LayoutConstants.textMargin),
            textStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -LayoutConstants.textMargin)
        ])
    }
    
    open func apply(theme: Theme) {
        titleLabel.textColor = theme.color(forKey: .primaryText)
        subtitleLabel.textColor = theme.color(forKey: .secondaryText)
        iconImageView.tintColor = theme.color(forKey: .primaryText)
    }
    
    open func updateViews() {
        titleLabel.text = viewModel.state.title
        countLabel.text = viewModel.state.officerCount
        subtitleLabel.text = viewModel.subtitleText
        
        iconImageView.image = viewModel.iconImage
    }
}

extension UserCallsignStatusView: UserCallsignStatusViewModelDelegate {
    public func viewModelStateChanged() {
        updateViews()
    }
}
