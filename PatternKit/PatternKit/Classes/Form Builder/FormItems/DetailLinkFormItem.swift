//
//  DetailLinkFormItem.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class DetailLinkFormItem: DetailFormItem {

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {

        let primaryText = theme.color(forKey: .primaryText)
        let secondaryText = theme.color(forKey: .secondaryText)
        let tint = theme.color(forKey: .tint)

        let cell = cell as! CollectionViewFormDetailCell

        cell.titleLabel.textColor = secondaryText
        cell.subtitleLabel.textColor =  onSelection != nil ? tint : primaryText
        cell.detailLabel.textColor = secondaryText
    }
}
