//
//  MediaFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 25/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public struct EmptyStateContents {
    public var title: String?
    public var subtitle: String?
}

public class MediaFormItem: BaseFormItem {

    public var dataSource: MediaGalleryViewModelable?

    public var delegate: MediaGalleryDelegate? = MediaPreviewHandler(pickerSources: MediaPreviewHandler.availableSources)

    public weak var previewingController: UIViewController?

    // Allow for customisation of the empty state
    public var emptyStateContents: EmptyStateContents?

    public init() {
        super.init(cellType: CollectionViewFormMediaCell.self, reuseIdentifier: CollectionViewFormMediaCell.defaultReuseIdentifier)
        separatorStyle = .none
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormMediaCell
        cell.dataSource = dataSource
        cell.delegate = delegate
        cell.previewingController = previewingController
        cell.loadingManager.noContentView.titleLabel.text = emptyStateContents?.title
        cell.loadingManager.noContentView.subtitleLabel.text = emptyStateContents?.subtitle
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormMediaCellMinimumItemHeight
    }

    open override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        guard let cell = cell as? CollectionViewFormMediaCell else { return }
        cell.loadingManager.noContentView.titleLabel.textColor = theme.color(forKey: .headerTitleText)
        cell.loadingManager.noContentView.subtitleLabel.textColor = theme.color(forKey: .headerSubtitleText)
    }
}

extension MediaFormItem {

    @discardableResult
    public func previewingController(_ previewingController: UIViewController?) -> Self {
        self.previewingController = previewingController
        return self
    }

    @discardableResult
    public func dataSource(_ dataSource: MediaGalleryViewModelable?) -> Self {
        self.dataSource = dataSource
        return self
    }

    @discardableResult
    public func delegate(_ delegate: MediaGalleryDelegate?) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    public func emptyStateContents(_ emptyStateContents: EmptyStateContents?) -> Self {
        self.emptyStateContents = emptyStateContents
        return self
    }
}
