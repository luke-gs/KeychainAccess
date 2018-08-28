//
//  CollectionViewFormLabelCell.swift
//  MPOLKit
//
//  Created by Megan Efron on 26/4/18.
//

import UIKit

open class CollectionViewFormLabelCell: CollectionViewFormCell {

    public let titleLabel = UILabel()

    public static let minimumHeight: CGFloat = CollectionViewFormLabelCell.defaultFont.lineHeight
    public static let defaultFont: UIFont = .preferredFont(forTextStyle: .body)

    public override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = CollectionViewFormLabelCell.defaultFont
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            ])
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
