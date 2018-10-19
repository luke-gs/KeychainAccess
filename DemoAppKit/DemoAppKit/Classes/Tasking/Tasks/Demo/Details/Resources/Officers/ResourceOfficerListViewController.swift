//
//  ResourceOfficerListViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOfficerListViewController: CADFormCollectionViewController<ResourceOfficerViewModel>, TaskDetailsLoadable {

    override public init(viewModel: CADFormCollectionViewModel<ResourceOfficerViewModel>) {
        super.init(viewModel: viewModel)

        sidebarItem.image = AssetManager.shared.image(forKey: .resourceGeneral)
        sidebarItem.count = UInt(viewModel.totalNumberOfItems())
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    override open func reloadContent() {
        super.reloadContent()

        // Update sidebar count when data changes
        sidebarItem.count = UInt(viewModel.totalNumberOfItems())
    }

    // MARK: - Override

    override open func cellType() -> CollectionViewFormCell.Type {
        return CollectionViewFormSubtitleBadgeCell.self
    }

    override open func decorate(cell: CollectionViewFormCell, with viewModel: ResourceOfficerViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .indented

        let commsView = CommsButtonStackView(frame: CGRect(x: 0, y: 0, width: 72, height: 32),
                                             commsEnabled: viewModel.commsEnabled,
                                             contactNumber: viewModel.contactNumber)
            .onTappedCall { _ in
                CommsButtonHandler.didSelectCall(for: viewModel.contactNumber)
            }.onTappedMessage { _ in
                CommsButtonHandler.didSelectMessage(for: viewModel.contactNumber)
            }

        if traitCollection.horizontalSizeClass == .compact {
            cell.accessoryView = FormAccessoryView(style: .overflow)
                .onTapped { _ in
                    CommsButtonHandler.didSelectCompactCommsButton(for: viewModel.contactNumber, enabled: viewModel.commsEnabled)
                }
        } else {
            cell.accessoryView = commsView
        }

        if let cell = cell as? CollectionViewFormSubtitleBadgeCell {
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.badgeLabel.text = viewModel.badgeText
            if let thumbnail = viewModel.thumbnail() {
                cell.imageView.setImage(with: thumbnail)
            }
        }
    }

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.collectionView?.reloadData()
        }, completion: nil)
    }

    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: present details?
    }

    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let item = viewModel.item(at: indexPath) {
            return CollectionViewFormSubtitleBadgeCell.minimumContentHeight(withTitle: item.title, subtitle: item.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
        }
        return 0
    }
}
