//
//  ActivityLogViewController.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ActivityLogViewController: FormBuilderViewController {
    public let viewModel: CADFormCollectionViewModel<ActivityLogItemViewModel>
    
    public init(viewModel: CADFormCollectionViewModel<ActivityLogItemViewModel>) {
        self.viewModel = viewModel
        super.init()
        title = viewModel.navTitle()

        // TODO: Loading manager. If this is in the PR then please request changes and tell me I'm an idiot
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func construct(builder: FormBuilder) {
        for section in viewModel.sections {
            if section is ActivityLogDateCollectionSectionViewModel {
                builder += LargeTextHeaderFormItem(text: section.title)
            } else {
                builder += HeaderFormItem(text: section.title, style: .collapsible)
            }
            
            for item in section.items {
                builder += CustomFormItem(cellType: ActivityLogItemCell.self, reuseIdentifier: "hi")
                    .onConfigured({ (cell) in
                        self.decorate(cell: cell, with: item)
                    })
                    .onThemeChanged({ (cell, theme) in
                        self.apply(theme: theme, to: cell)
                    })
                .accessory(ItemAccessory.disclosure)
            }
        }
        
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let item = viewModel.item(at: indexPath) {
            return ActivityLogItemCell.minimumContentHeight(withTitle: item.title, subtitle: item.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
        }
        return 0
    }
    
    open func decorate(cell: CollectionViewFormCell, with viewModel: ActivityLogItemViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .none
        
        if let cell = cell as? ActivityLogItemCell {
            cell.timeLabel.text = viewModel.timestamp
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.imageView.image = viewModel.dotImage()
        }
    }
        
    open override func collectionViewLayoutClass() -> CollectionViewFormLayout.Type {
        return TimelineCollectionViewFormLayout.self
    }

    func apply(theme: Theme, to cell: UICollectionViewCell) {
        if let cell = cell as? CollectionViewFormSubtitleCell {
            cell.titleLabel.textColor    = theme.color(forKey: .primaryText)
            cell.subtitleLabel.textColor = theme.color(forKey: .secondaryText)
        }
    }
    
}

extension ActivityLogViewController: CADFormCollectionViewModelDelegate {
    public func sectionsUpdated() {
        reloadForm()
    }
}

