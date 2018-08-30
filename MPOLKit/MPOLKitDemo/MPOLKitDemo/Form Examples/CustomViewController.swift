//
//  CustomViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class CustomViewController: FormBuilderViewController {

    override func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: "CUSTOM CELL EXAMPLE")

        builder += CustomFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: "SubtitleCell")
            .onConfigured({ (cell) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.style = .value
                cell.titleLabel.text = "CustomFormItem"
                cell.subtitleLabel.text = "Value Styled"
            })
            .height(.dynamic({ (info) -> CGFloat in
                return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "CustomFormItem", subtitle: "Value Styled", inWidth: info.contentWidth, compatibleWith: info.traitCollection, imageSize: .zero, style: .value)
            }))

        builder += CustomFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: "SubtitleCell")
            .onConfigured({ (cell) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.style = .value
                cell.titleLabel.text = "CustomFormItem with theme"
                cell.subtitleLabel.text = "Value Styled"
            })
            .height(.dynamic({ (info) -> CGFloat in
                return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "CustomFormItem with theme", subtitle: "Value Styled", inWidth: info.contentWidth, compatibleWith: info.traitCollection, imageSize: .zero, style: .value)
            }))
            .onThemeChanged({ (cell, theme) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.titleLabel.textColor = theme.color(forKey: .primaryText)
                cell.subtitleLabel.textColor = theme.color(forKey: .secondaryText)
            })

        builder += CustomFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: "SubtitleCell")
            .onConfigured({ (cell) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.titleLabel.text = "CustomFormItem"
                cell.subtitleLabel.text = "Default styled"
            })
            .height(.dynamic({ (info) -> CGFloat in
                return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "CustomFormItem", subtitle: "Default styled", inWidth: info.contentWidth, compatibleWith: info.traitCollection)
            }))

        builder += CustomFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: "SubtitleCell")
            .onConfigured({ (cell) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.titleLabel.text = "CustomFormItem with theme"
                cell.subtitleLabel.text = "Default styled"
            })
            .height(.dynamic({ (info) -> CGFloat in
                return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "CustomFormItem with theme", subtitle: "Default styled", inWidth: info.contentWidth, compatibleWith: info.traitCollection)
            }))
            .onThemeChanged({ (cell, theme) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.titleLabel.textColor = theme.color(forKey: .primaryText)
                cell.subtitleLabel.textColor = theme.color(forKey: .secondaryText)
            })

    }

}
