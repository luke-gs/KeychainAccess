//
//  CollectionViewImageDetailView.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Collection view cell for an image
/// with a title and description below
open class CollectionViewImageDetailView: UICollectionReusableView, DefaultReusable {

    public class func defaultFonts(compatibleWith traitCollection: UITraitCollection) -> (titleFont: UIFont, descriptionFont: UIFont) {
        return (.preferredFont(forTextStyle: .headline,    compatibleWith: traitCollection),
                .preferredFont(forTextStyle: .footnote,    compatibleWith: traitCollection))
    }
    
    public static let defaultFont = UIFont.systemFont(ofSize: 22, weight: .bold)
    public let imageView = UIImageView()
    public let titleLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let separatorView = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        titleLabel.font = CollectionViewImageDetailView.defaultFont
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        descriptionLabel.font = CollectionViewImageDetailView.defaultFont
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)

        separatorView.backgroundColor = iOSStandardSeparatorColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)

        NSLayoutConstraint.activate([

            imageView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).withPriority(.almostRequired),

            descriptionLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).withPriority(.almostRequired),
            descriptionLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor),

            separatorView.heightAnchor.constraint(equalToConstant: 1.0),
            separatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

}

