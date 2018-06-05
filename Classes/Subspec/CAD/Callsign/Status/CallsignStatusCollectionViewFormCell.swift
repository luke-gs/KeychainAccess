//
//  CallsignStatusCollectionViewFormCell.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// The display mode of the cell
public enum CallsignStatusDisplayMode {
    case regular
    case compact
    case auto

    public func isCompact(for traitCollection: UITraitCollection) -> Bool {
        return (self == .compact || (self == .auto && traitCollection.horizontalSizeClass == .compact))
    }
}

open class CallsignStatusCollectionViewFormCell: CollectionViewFormCell {

    public static let imageSize: CGFloat = 32
    public static let imagePadding: CGFloat = 20
    public static let minimumHeight: CGFloat = imageSize
    public static let defaultFont: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)

    public let titleLabel = UILabel()
    public let imageView = UIImageView(frame: .zero)

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

    open var displayMode: CallsignStatusDisplayMode = .auto {
        didSet {
            configureConstraints()
        }
    }

    private var currentConstraints: [NSLayoutConstraint] = []

    private var commonConstraints: [NSLayoutConstraint] {
        return [
            imageView.widthAnchor.constraint(equalToConstant: CallsignStatusCollectionViewFormCell.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: CallsignStatusCollectionViewFormCell.imageSize),

            imageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor).withPriority(.almostRequired),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor).withPriority(.almostRequired),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),

            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor).withPriority(.almostRequired),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor).withPriority(.almostRequired),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
        ]
    }

    private var regularConstraints: [NSLayoutConstraint] {
        return [
            imageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10),
            imageView.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ]
    }

    private var compactConstraints: [NSLayoutConstraint] {
        return [
            imageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -CallsignStatusCollectionViewFormCell.imagePadding),

            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ]
    }

    private func configureConstraints() {
        NSLayoutConstraint.deactivate(currentConstraints)
        if displayMode.isCompact(for: super.traitCollection) {
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
