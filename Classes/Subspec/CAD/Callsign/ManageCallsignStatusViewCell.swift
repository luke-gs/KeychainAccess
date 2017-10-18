//
//  ManageCallsignStatusViewCell.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Collection view cell for showing a status image and title
class ManageCallsignStatusViewCell: UICollectionViewCell, DefaultReusable {

    public let titleLabel = UILabel(frame: .zero)
    public let imageView = UIImageView(frame: .zero)

    private var currentConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)

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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
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

    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }
}
