//
//  EventCardCollectionViewCell.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PatternKit

public class EventCardCollectionViewCell: CollectionViewFormCell {

    public var testLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 360, height: 200))
        separatorColor = .clear
        testLabel.text = "Test"
        testLabel.textColor = UIColor.white
        testLabel.backgroundColor = UIColor.black
        contentView.backgroundColor = UIColor.gray
        contentView.addSubview(testLabel)
        testLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            testLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            testLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
