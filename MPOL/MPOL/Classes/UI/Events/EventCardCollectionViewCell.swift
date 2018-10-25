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
    public var locationLabel = UILabel()
    private let imageView = UIImageView(image: #imageLiteral(resourceName: "EventCardBackgroundImage"))

    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 360, height: 200))
        separatorColor = .clear

        // Time label styling
        timeLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        timeLabel.textColor = UIColor.lightGray

        // Title lable styling
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2

        // Location label styling
        locationLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        locationLabel.textColor = UIColor.white
        locationLabel.numberOfLines = 2

        // Add items & layout constraints
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(locationLabel)
        locationLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Image view
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),

            // Time label
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Title label
            titleLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Location label
            locationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            locationLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    public override func layoutSubviews() {
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 4.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
