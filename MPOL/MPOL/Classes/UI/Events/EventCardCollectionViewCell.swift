//
//  EventCardCollectionViewCell.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PatternKit

public class EventCardCollectionViewCell: CollectionViewFormCell {

    public var titleLabel = UILabel()
    public var timeLabel = UILabel()
    public var addressLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 360, height: 200))
        separatorColor = .clear
        let imageView = UIImageView(image: #imageLiteral(resourceName: "EventCardBackgroundImage"))

        // Fake text
        titleLabel.text = "Domestic and Family Violence: Application"
        addressLabel.text = "28 Collingwood Street, Collingwood"

        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2

        timeLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        timeLabel.textColor = UIColor.lightGray

        addressLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        addressLabel.textColor = UIColor.white
        addressLabel.numberOfLines = 2

        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(addressLabel)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),

            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            titleLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            addressLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)

        ])

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
