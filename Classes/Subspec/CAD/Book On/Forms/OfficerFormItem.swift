//
//  OfficerFormItem.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class OfficerFormItem: SubtitleFormItem {

    public var status: String?

    public init(cellType: CollectionViewFormOfficerCell.Type, reuseIdentifier: String) {
        super.init(cellType: cellType, reuseIdentifier: reuseIdentifier)
    }

    public convenience init(title: StringSizable? = nil, subtitle: StringSizable? = nil, status: String? = nil, style: CollectionViewFormSubtitleStyle = .default) {
        self.init(cellType: CollectionViewFormOfficerCell.self, reuseIdentifier: CollectionViewFormOfficerCell.defaultReuseIdentifier)

        self.title = title
        self.subtitle = subtitle
        self.status = status
        self.style = style
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        super.configure(cell)

        let cell = cell as! CollectionViewFormOfficerCell
        cell.statusLabel.text = status
    }

}
