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
    
    open let viewModel: UserCallsignStatusViewModel
    
    // MARK: - Constants
    
    public struct LayoutConstants {
        public static let iconSize: CGFloat = 24
        public static let imageMargin: CGFloat = 6
        public static let iconTextMargin: CGFloat = 16
        public static let textMargin: CGFloat = 8
    }
    
    // MARK: - Views
    
    open var iconView: CircleIconView!
    open var iconImageView: UIImageView!
    open var textStackView: UIStackView!
    open var titleLabel: UILabel!
    open var subtitleLabel: UILabel!
    
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
        iconView = CircleIconView()
        iconView.color = #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)
        iconView.isUserInteractionEnabled = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        
        iconImageView = UIImageView()
        iconImageView.tintColor = UIColor.black
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.isUserInteractionEnabled = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconView.addSubview(iconImageView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        titleLabel.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
        titleLabel.isUserInteractionEnabled = false

        subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        subtitleLabel.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .secondaryText)
        subtitleLabel.isUserInteractionEnabled = false

        textStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStackView.axis = .vertical
        textStackView.isUserInteractionEnabled = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textStackView)
    }
    
    /// Activates view constraints
    open func setupConstraints() {
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: LayoutConstants.iconSize),
            iconView.widthAnchor.constraint(equalToConstant: LayoutConstants.iconSize),
            iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: LayoutConstants.imageMargin),
            iconImageView.leadingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: LayoutConstants.imageMargin),
            iconImageView.trailingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: -LayoutConstants.imageMargin),
            iconImageView.bottomAnchor.constraint(equalTo: iconView.bottomAnchor, constant: -LayoutConstants.imageMargin),
            
            textStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: LayoutConstants.iconTextMargin),
            textStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: LayoutConstants.textMargin),
            textStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -LayoutConstants.textMargin),
            textStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -LayoutConstants.textMargin)
        ])
    }
    
    open func updateViews() {
        titleLabel.text = viewModel.titleText
        subtitleLabel.text = viewModel.subtitleText
        iconImageView.image = viewModel.iconImage
    }
}

extension UserCallsignStatusView: UserCallsignStatusViewModelDelegate {
    public func viewModelStateChanged() {
        updateViews()
    }
}
