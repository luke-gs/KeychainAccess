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
        public static let imageMargin: CGFloat = 12
        public static let iconTextMargin: CGFloat = 12
        public static let textMargin: CGFloat = 8
    }
    
    // MARK: - Views
    
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
        iconImageView = UIImageView()
        iconImageView.tintColor = UIColor.black
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.isUserInteractionEnabled = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        
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
    
    open func updateViews() {
        titleLabel.text = viewModel.titleText
        subtitleLabel.text = viewModel.subtitleText
        
        // Set circle background only if callsign is assigned
        if case UserCallsignStatusViewModel.CallsignState.unassigned(_, _) = viewModel.state {
            iconImageView.image = viewModel.iconImage
            iconImageView.tintColor = .darkGray
        } else {
            let padding = CGSize(width: LayoutConstants.imageMargin, height: LayoutConstants.imageMargin)
            iconImageView.image = viewModel.iconImage?.withCircleBackground(tintColor: .black,
                                                                            circleColor: .disabledGray,
                                                                            padding: padding,
                                                                            shrinkImage: true)
        }
    }
}

extension UserCallsignStatusView: UserCallsignStatusViewModelDelegate {
    public func viewModelStateChanged() {
        updateViews()
    }
}
