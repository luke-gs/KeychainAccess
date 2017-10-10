//
//  CallsignStatusView.swift
//  ClientKit
//
//  Created by Kyle May on 7/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignStatusView: UIView {
    
    public let viewModel: CallsignStatusViewModel
    
    // MARK: - Constants
    
    private let margin: CGFloat = 10
    
    // MARK: - Views
    
    private var iconView: CircleIconView!
    private var iconImageView: UIImageView!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    
    // MARK: - Setup

    public init(viewModel: CallsignStatusViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupViews()
        setupConstraints()
        updateViews()
    }
    
    public override init(frame: CGRect) {
        viewModel = CallsignStatusViewModel()
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        updateViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        iconView = CircleIconView()
        iconView.color = #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        
        iconImageView = UIImageView(image: AssetManager.shared.image(forKey: .entityCar))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor.black
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconView.addSubview(iconImageView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        titleLabel.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        subtitleLabel.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .secondaryText)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 24),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: margin),
            iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -margin),
            
            iconImageView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 6),
            iconImageView.leadingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: 6),
            iconImageView.trailingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: -6),
            iconImageView.bottomAnchor.constraint(equalTo: iconView.bottomAnchor, constant: -6),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margin),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    public func updateViews() {
        titleLabel.text = viewModel.titleText
        subtitleLabel.text = viewModel.subtitleText
        iconImageView.image = viewModel.iconImage
    }
    
}
