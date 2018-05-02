//
//  CollectionViewFormLabelCell.swift
//  MPOLKit
//
//  Created by Kyle May on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Collection view cell for a label
open class CollectionViewFormLargeTextLabelCell: UICollectionReusableView, DefaultReusable {
    public static let defaultFont = UIFont.systemFont(ofSize: 28, weight: .bold)
    public let titleLabel = UILabel()
    public let separatorView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.font = CollectionViewFormLargeTextLabelCell.defaultFont
        titleLabel.textColor = .primaryGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        separatorView.backgroundColor = iOSStandardSeparatorColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).withPriority(.almostRequired),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 1.0),
            separatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let layoutAttributes = layoutAttributes as? CollectionViewFormLayoutAttributes {
            layoutMargins = layoutAttributes.layoutMargins
        } else {
            // This breaks anyone using custom layoutMargins, so disabled
            // layoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        }
    }
}
