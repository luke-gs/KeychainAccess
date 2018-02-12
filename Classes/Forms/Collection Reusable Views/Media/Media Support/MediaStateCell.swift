//
//  MediaStateCell.swift
//  MPOLKit
//
//  Created by KGWH78 on 9/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit


class MediaStateCell: UICollectionViewCell {

    public let imageView = UIImageView()

    public let titleLabel = UILabel()

    public let subtitleLabel = UILabel()

    private let activityIndicator = MPOLSpinnerView(style: .regular)

    public var isLoading: Bool = false {
        didSet {
            guard isLoading != oldValue else { return }
            updateState()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        var container = UIView(frame: .zero)
        contentView.addSubview(container)

        container.addSubview(activityIndicator)
        container.addSubview(imageView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)

        subtitleLabel.numberOfLines = 0

        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center

        container.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)

        let views: [String: Any] = ["image": imageView, "title": titleLabel, "subtitle": subtitleLabel]

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[image(50)]",
                                                         options: [],
                                                         metrics: nil,
                                                         views: views)

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[title][subtitle]|",
                                                      options: [.alignAllLeading, .alignAllTrailing],
                                                      metrics: nil,
                                                      views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[title]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views)

        constraints += [
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16.0),

            imageView.widthAnchor.constraint(equalToConstant: 50.0),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            activityIndicator.widthAnchor.constraint(equalToConstant: 50.0),
            activityIndicator.heightAnchor.constraint(equalToConstant: 50.0),
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            container.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            container.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.readableContentGuide.leadingAnchor),
            container.trailingAnchor.constraint(lessThanOrEqualTo: contentView.readableContentGuide.trailingAnchor),

            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        updateState()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    public func apply(theme: Theme) {
        titleLabel.textColor = theme.color(forKey: .primaryText)
        subtitleLabel.textColor = theme.color(forKey: .secondaryText)
        activityIndicator.color = theme.color(forKey: .tint)
    }

    private func updateState() {
        if isLoading {
            imageView.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.play()
        } else {
            imageView.isHidden = false
            activityIndicator.isHidden = true
        }
    }

}
