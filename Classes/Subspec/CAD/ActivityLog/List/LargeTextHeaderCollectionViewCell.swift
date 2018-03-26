//
//  LargeTextHeaderCollectionViewCell.swift
//  MPOLKit
//
//  Created by Kyle May on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Collection view cell for a header with large text
open class LargeTextHeaderCollectionViewCell: CollectionViewFormCell {
    public let titleLabel = UILabel()
    
    public static let minimumHeight: CGFloat = 72

    public override init(frame: CGRect) {
        super.init(frame: frame)
        overridesLayoutMargins = false
        
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .primaryGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        separatorView.backgroundColor = iOSStandardSeparatorColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorView)

        // Default margins that can be overridden
        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 24, bottom: 24, right: 24)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).withPriority(.almostRequired),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 1.0),
            separatorView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
