//
//  GlassBarView.swift
//  MPOLKit
//
//  Created by Kyle May on 10/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class GlassBarView: UIControl {
    private let blurEffect: UIBlurEffect
    private let backgroundView: UIVisualEffectView
    private var labelStackView: UIStackView!
    
    public let titleLabel: UILabel
    public let subtitleLabel: UILabel
    public let imageView: UIImageView
    public let actionImageView: UIImageView
    
    public init(blurEffectStyle: UIBlurEffectStyle, frame: CGRect = .zero) {
        self.blurEffect = UIBlurEffect(style: blurEffectStyle)
        self.backgroundView = UIVisualEffectView(effect: blurEffect)
        self.backgroundView.isUserInteractionEnabled = false
        self.titleLabel = UILabel()
        self.subtitleLabel = UILabel()
        self.imageView = UIImageView()
        self.actionImageView = UIImageView()
        
        super.init(frame: frame)

        addSubview(backgroundView)
        
        imageView.tintColor = .primaryGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.contentView.addSubview(imageView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor.primaryGray
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor.secondaryGray

        labelStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStackView.axis = .vertical
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.contentView.addSubview(labelStackView)
        
        actionImageView.tintColor = .secondaryGray
        actionImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.contentView.addSubview(actionImageView)
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: backgroundView.contentView.leadingAnchor, constant: 24),
            imageView.centerYAnchor.constraint(equalTo: backgroundView.contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            
            labelStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 18),
            labelStackView.centerYAnchor.constraint(equalTo: backgroundView.contentView.centerYAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: actionImageView.leadingAnchor),
            
            actionImageView.trailingAnchor.constraint(equalTo: backgroundView.contentView.trailingAnchor, constant: -24),
            actionImageView.centerYAnchor.constraint(equalTo: backgroundView.contentView.centerYAnchor),
            actionImageView.widthAnchor.constraint(equalToConstant: 20),
            actionImageView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
}
