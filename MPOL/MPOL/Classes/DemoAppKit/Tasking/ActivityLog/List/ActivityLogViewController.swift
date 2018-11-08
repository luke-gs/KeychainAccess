//
//  ActivityLogViewController.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
open class ActivityLogViewController: FormBuilderViewController {

    public let viewModel: CADFormCollectionViewModel<ActivityLogItemViewModel>

    open var activityLogViewModel: DatedActivityLogViewModel? {
        return viewModel as? DatedActivityLogViewModel
    }

    public init(viewModel: CADFormCollectionViewModel<ActivityLogItemViewModel>) {
        self.viewModel = viewModel
        super.init()
        title = viewModel.navTitle()

        if (activityLogViewModel?.allowCreate()).isTrue {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
        }
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        loadingManager.noContentView.titleLabel.text = viewModel.noContentTitle()
        loadingManager.noContentView.subtitleLabel.text = viewModel.noContentSubtitle()

        sectionsUpdated()
    }

    open override func construct(builder: FormBuilder) {
        for section in viewModel.sections {
            if section is ActivityLogDateCollectionSectionViewModel {
                builder += LargeTextHeaderFormItem(text: section.title, separatorColor: .clear)
            } else {
                builder += HeaderFormItem(text: section.title, style: .collapsible)
            }

            for item in section.items {
                builder += CustomFormItem(cellType: ActivityLogItemCell.self, reuseIdentifier: "hi")
                    .onConfigured({ (cell) in
                        self.decorate(cell: cell, with: item)
                    })
                    .onStyled({ (cell) in
                        let theme = ThemeManager.shared.theme(for: self.userInterfaceStyle)
                        self.apply(theme: theme, to: cell)
                    })
                    .onSelection({ (_) in
                        // TODO: implement disclosure presentation
                    })
                .accessory(ItemAccessory.disclosure)
            }
        }

    }

    @objc open func plusButtonTapped(_ item: UIBarButtonItem) {
        if let viewController = activityLogViewModel?.createNewActivityLogViewController() {
            presentFormSheet(viewController, animated: true)
        }
    }

    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)

        // Remove cell highlight
        collectionView.deselectItem(at: indexPath, animated: false)
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
            cell.timeLabel.text = viewModel.timestampString
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
        // Update loading state
        loadingManager.state = viewModel.numberOfSections() == 0 ? .noContent : .loaded

        // Reload content
        reloadForm()
    }
}
