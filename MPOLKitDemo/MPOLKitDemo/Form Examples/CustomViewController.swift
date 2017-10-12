//
//  CustomViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class CustomViewController: FormViewController {

    override func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: "CUSTOM CELL EXAMPLE")

        builder += CustomFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: "SubtitleCell")
            .onConfigured({ (cell) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.style = .value
                cell.titleLabel.text = "Hello"
                cell.subtitleLabel.text = "Good bye"
            })
            .height(.dynamic({ (info) -> CGFloat in
                return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Hello", subtitle: "Good bye", inWidth: info.contentWidth, compatibleWith: info.traitCollection, imageSize: .zero, style: .value)
            }))

        builder += CustomFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: "SubtitleCell")
            .onConfigured({ (cell) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.style = .value
                cell.titleLabel.text = "Hello"
                cell.subtitleLabel.text = "Good bye"
            })
            .height(.dynamic({ (info) -> CGFloat in
                return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Hello", subtitle: "Good bye", inWidth: info.contentWidth, compatibleWith: info.traitCollection, imageSize: .zero, style: .value)
            }))
            .onThemeChanged({ (cell, theme) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.titleLabel.textColor = theme.color(forKey: .primaryText)
                cell.subtitleLabel.textColor = theme.color(forKey: .secondaryText)
            })

        builder += CustomFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: "SubtitleCell")
            .onConfigured({ (cell) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.titleLabel.text = "Hello"
                cell.subtitleLabel.text = "Good bye"
            })
            .height(.dynamic({ (info) -> CGFloat in
                return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Hello", subtitle: "Good bye", inWidth: info.contentWidth, compatibleWith: info.traitCollection)
            }))

        builder += CustomFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: "SubtitleCell")
            .onConfigured({ (cell) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.titleLabel.text = "Hello"
                cell.subtitleLabel.text = "Good bye"
            })
            .height(.dynamic({ (info) -> CGFloat in
                return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Hello", subtitle: "Good bye", inWidth: info.contentWidth, compatibleWith: info.traitCollection)
            }))
            .onThemeChanged({ (cell, theme) in
                guard let cell = cell as? CollectionViewFormSubtitleCell else { return }
                cell.titleLabel.textColor = theme.color(forKey: .primaryText)
                cell.subtitleLabel.textColor = theme.color(forKey: .secondaryText)
            })

    }

}
