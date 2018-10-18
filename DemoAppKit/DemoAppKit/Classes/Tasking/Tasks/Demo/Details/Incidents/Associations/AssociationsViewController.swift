//
//  IncidentAssociationsViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class AssociationsViewController: CADFormCollectionViewController<AssociationItemViewModel>, TaskDetailsLoadable {

    private let styleItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .navBarThumbnailSelected), style: .plain, target: nil, action: nil)

    override public init(viewModel: CADFormCollectionViewModel<AssociationItemViewModel>) {
        super.init(viewModel: viewModel)

        // TODO: Add red dot
        sidebarItem.image = AssetManager.shared.image(forKey: .association)
        sidebarItem.count = UInt(viewModel.totalNumberOfItems())

        navigationItem.rightBarButtonItem = styleItem

        styleItem.target = self
        styleItem.action = #selector(toggleStyle)
        styleItem.imageInsets = .zero
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(EntityCollectionViewCell.self)
        collectionView?.register(EntityListCollectionViewCell.self)
    }

    override open func reloadContent() {
        super.reloadContent()

        // Update sidebar count when data changes
        sidebarItem.count = UInt(viewModel.totalNumberOfItems())
    }

    // MARK: - Thumbnail support

    private var style: EntityDisplayStyle = .grid {
        didSet {
            guard style != oldValue else { return }

            if !isCompact() {
                styleItem.image = AssetManager.shared.image(forKey: style == .grid ? .navBarThumbnailSelected : .navBarThumbnail)
                collectionView?.reloadData()
            }
        }
    }

    @objc private func toggleStyle() {
        style = style == .grid ? . list : .grid
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let isCompact = traitCollection.horizontalSizeClass == .compact

        if isCompact != (previousTraitCollection?.horizontalSizeClass == .compact) {
            if style == .grid && !isCompact {
                collectionView?.reloadData()
            }
            navigationItem.rightBarButtonItems = isCompact ? nil : [styleItem]
        }
    }

    // MARK: - Override

    open override func cellType() -> CollectionViewFormCell.Type {
        if !isCompact() && style == .grid {
            return EntityCollectionViewCell.self
        }
        return EntityListCollectionViewCell.self
    }

    private func cellType(for entityType: AssociationItemViewModel.EntityType) -> CollectionViewFormCell.Type {

        switch entityType {
            case .person:
                return cellType()
            default:
                return EntityListCollectionViewCell.self
        }
    }

    override open func decorate(cell: CollectionViewFormCell, with viewModel: AssociationItemViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.accessoryView = nil

        if let cell = cell as? EntityListCollectionViewCell {
            cell.separatorStyle = .indented
            cell.decorate(with: viewModel)
        } else if let cell = cell as? EntityCollectionViewCell {
            cell.separatorStyle = .none
            cell.decorate(with: viewModel)
        }
    }

    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let item = viewModel.item(at: indexPath) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }

        let cell = collectionView.dequeueReusableCell(of: cellType(for: item.entityType), for: indexPath)
        decorate(cell: cell, with: item)
        return cell
    }

    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)

        if let cell = cell as? EntityListCollectionViewCell {
            cell.thumbnailView.apply(theme: ThemeManager.shared.theme(for: .current))
        } else if let cell = cell as? EntityCollectionViewCell {
            cell.thumbnailView.apply(theme: ThemeManager.shared.theme(for: .current))
        }
    }

    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        if let item = viewModel.item(at: indexPath) {
            // Present association details
            Director.shared.present(TaskItemScreen.associationDetails(association: item.association), fromViewController: self)
        }
    }

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        if let item = viewModel.item(at: indexPath) {
            if cellType(for: item.entityType) == EntityCollectionViewCell.self {
                return EntityCollectionViewCell.minimumContentWidth(forStyle: .hero)
            }
        }
        return collectionView.bounds.width
    }

    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let item = viewModel.item(at: indexPath) {
            if cellType(for: item.entityType) == EntityCollectionViewCell.self {
                return EntityCollectionViewCell.minimumContentHeight(forStyle: .hero, title: item.title, subtitle: item.detail1, detail: item.detail2, subdetail: nil, inWidth: itemWidth, compatibleWith: traitCollection)
            } else {
                return EntityListCollectionViewCell.minimumContentHeight(withTitle: nil, subtitle: nil, detail: nil, source: nil, inWidth: itemWidth, compatibleWith: traitCollection)
            }
        }
        return 0
    }

}
