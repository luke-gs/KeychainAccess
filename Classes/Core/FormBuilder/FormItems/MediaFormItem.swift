//
//  MediaFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 25/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class MediaFormItem: BaseFormItem {

    public var dataSource: MediaDataSource<MediaAsset>?

    public var delegate = MediaPreviewHandler()

    public weak var previewingController: UIViewController?

    public init() {
        super.init(cellType: CollectionViewFormMediaCell<MediaPreviewHandler>.self, reuseIdentifier: CollectionViewFormMediaCell<MediaPreviewHandler>.defaultReuseIdentifier)
        separatorStyle = .none
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormMediaCell<MediaPreviewHandler>
        cell.dataSource = dataSource
        cell.delegate = delegate
        cell.previewingController = previewingController
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormMediaCellMinimumItemHeight
    }

}

extension MediaFormItem {

    @discardableResult
    public func previewingController(_ previewingController: UIViewController?) -> Self {
        self.previewingController = previewingController
        return self
    }

    @discardableResult
    public func dataSource(_ dataSource: MediaDataSource<MediaAsset>?) -> Self {
        self.dataSource = dataSource
        return self
    }

}
