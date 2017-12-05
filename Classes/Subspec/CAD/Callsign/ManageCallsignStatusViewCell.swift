//
//  ManageCallsignStatusViewCell.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Collection view cell for showing a status image and title
open class ManageCallsignStatusViewCell: UICollectionViewCell, DefaultReusable {

    open let titleLabel = UILabel(frame: .zero)
    open let imageView = UIImageView(frame: .zero)
    open let spinner = MPOLSpinnerView(style: .regular)
    
    open var isLoading: Bool = false {
        didSet {
            if isLoading == oldValue { return }
            
            spinner.isHidden = !isLoading
            titleLabel.isHidden = isLoading
            imageView.isHidden = isLoading
            
            isLoading ? spinner.play() : spinner.pause()
        }
    }

    private var currentConstraints: [NSLayoutConstraint] = []

    override public init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isHidden = true
        contentView.addSubview(spinner)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    private var commonConstraints: [NSLayoutConstraint] {
        return [
            imageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
    }

    private var regularConstraints: [NSLayoutConstraint] {
        return [
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10),
            imageView.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),

            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ]
    }

    private var compactConstraints: [NSLayoutConstraint] {
        return [
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            imageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -20),

            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ]
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection != traitCollection {
            NSLayoutConstraint.deactivate(currentConstraints)
            if super.traitCollection.horizontalSizeClass == .compact {
                currentConstraints = commonConstraints + compactConstraints
            } else {
                currentConstraints = commonConstraints + regularConstraints
            }
            NSLayoutConstraint.activate(currentConstraints)
        }
    }
}
