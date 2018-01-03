//
//  ActivityLogViewController.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View controller for displaying the activity log in the CAD tab bar controller
///
/// This uses CADFormCollectionViewController for consistent styling and reduced boilerplate.
///
public class ActivityLogViewController: TimelineFormCollectionViewController<ActivityLogItemViewModel> {

    // MARK: - Override

    override open func cellType() -> CollectionViewFormCell.Type {
        return ActivityLogItemCell.self
    }

    override open func decorate(cell: CollectionViewFormCell, with viewModel: ActivityLogItemViewModel) {
        cell.highlightStyle = FadeStyle.highlight()
        cell.selectionStyle = FadeStyle.selection()
        cell.separatorStyle = .none
        cell.accessoryView = FormAccessoryView(style: .disclosure)

        if let cell = cell as? ActivityLogItemCell {
            cell.timeLabel.text = viewModel.timestamp
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.imageView.image = viewModel.dotImage()
        }
    }

    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: present details?
    }

    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let item = viewModel.item(at: indexPath) {
            return ActivityLogItemCell.minimumContentHeight(withTitle: item.title, subtitle: item.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
        }
        return 0
    }
}

