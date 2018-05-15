//
//  CallsignStatusCollectionViewFormCell.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

open class CallsignStatusCollectionViewFormCell: CollectionViewFormCell {

    public static let imageSize: CGFloat = 32
    public static let minimumHeight: CGFloat = imageSize
    public static let defaultFont: UIFont = .preferredFont(forTextStyle: .body)

    open let titleLabel = UILabel()
    open let imageView = UIImageView(frame: .zero)

    public override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = CollectionViewFormLabelCell.defaultFont
        contentView.addSubview(titleLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open var showsCompactHorizontal: Bool = true {
        didSet {
            configureConstraints()
        }
    }

    private var currentConstraints: [NSLayoutConstraint] = []

    private var commonConstraints: [NSLayoutConstraint] {
        return [
            imageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: CallsignStatusCollectionViewFormCell.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: CallsignStatusCollectionViewFormCell.imageSize),

            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
        ]
    }

    private var regularConstraints: [NSLayoutConstraint] {
        return [
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10),
            imageView.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),

            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
        ]
    }

    private var compactConstraints: [NSLayoutConstraint] {
        return [
            imageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            imageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -20),

            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
        ]
    }

    private func configureConstraints() {
        NSLayoutConstraint.deactivate(currentConstraints)
        if super.traitCollection.horizontalSizeClass == .compact && showsCompactHorizontal {
            currentConstraints = commonConstraints + compactConstraints
        } else {
            currentConstraints = commonConstraints + regularConstraints
        }
        NSLayoutConstraint.activate(currentConstraints)
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection != traitCollection {
            configureConstraints()
        }
    }

}
