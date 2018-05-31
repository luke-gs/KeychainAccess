//
//  RowDetailFormItem.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation


public class RowDetailFormItem: BaseFormItem {

    public var title: StringSizable?

    public var detail: StringSizable?

    public var image: UIImage?

    private var detailColorKey: Theme.ColorKey?

    public init() {
        super.init(cellType: CollectionViewFormRowDetailCell.self, reuseIdentifier: CollectionViewFormRowDetailCell.defaultReuseIdentifier)
    }

    public convenience init(title: StringSizable? = nil, detail: StringSizable? = nil, image: UIImage? = nil) {
        self.init()
        self.title = title
        self.detail = detail
        self.image = image
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormRowDetailCell
        let fonts = CollectionViewFormRowDetailCell.defaultFonts(compatibleWith: cell.traitCollection)

        cell.titleLabel.apply(sizable: title, defaultFont: fonts.titleFont, defaultNumberOfLines: 1)
        cell.detailLabel.apply(sizable: detail, defaultFont: fonts.detailFont, defaultNumberOfLines: 0)
        cell.detailLabel.textAlignment = .right
        cell.imageView.image = image
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        let fonts = CollectionViewFormRowDetailCell.defaultFonts(compatibleWith: traitCollection)
        return CollectionViewFormRowDetailCell.minimumContentHeight(withTitle: title?.sizing(defaultNumberOfLines: 1, defaultFont: fonts.titleFont), detail: detail?.sizing(defaultNumberOfLines: 0, defaultFont: fonts.detailFont), imageSize: image?.size, inWidth: contentWidth, compatibleWith: traitCollection)
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let detailTextColor = theme.color(forKey: detailColorKey ?? .primaryText)
        let titleTextColor = theme.color(forKey: .secondaryText)

        let cell = cell as! CollectionViewFormRowDetailCell

        cell.titleLabel.textColor = titleTextColor
        cell.detailLabel.textColor = detailTextColor
    }

}

// MARK: - Chaining methods

extension RowDetailFormItem {

    @discardableResult
    public func title(_ title: StringSizable?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    public func detail(_ detail: StringSizable?) -> Self {
        self.detail = detail
        return self
    }

    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    public func detailColorKey(_ key: Theme.ColorKey?) -> Self {
        self.detailColorKey = key
        return self
    }
}

