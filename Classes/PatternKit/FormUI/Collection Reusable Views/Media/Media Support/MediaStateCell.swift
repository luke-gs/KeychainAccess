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

    public let button = UIButton(type: .system)

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

        let container = UIView(frame: .zero)
        contentView.addSubview(container)

        container.addSubview(activityIndicator)
        container.addSubview(button)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)

        subtitleLabel.numberOfLines = 0

        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center

        container.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)

        let views: [String: Any] = ["image": button, "title": titleLabel, "subtitle": subtitleLabel]

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
            titleLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 16.0),

            button.widthAnchor.constraint(equalToConstant: 50.0),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            activityIndicator.widthAnchor.constraint(equalToConstant: 50.0),
            activityIndicator.heightAnchor.constraint(equalToConstant: 50.0),
            activityIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor),

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
            button.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.play()
        } else {
            button.isHidden = false
            activityIndicator.isHidden = true
        }
    }

}
