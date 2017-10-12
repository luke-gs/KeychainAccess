//
//  DetailFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 14/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class DetailFormItem: BaseFormItem {

    public var title: String?

    public var subtitle: String?

    public var detail: StringSizable?

    public var image: UIImage?

    public init() {
        super.init(cellType: CollectionViewFormDetailCell.self, reuseIdentifier: CollectionViewFormDetailCell.defaultReuseIdentifier)
    }

    public convenience init(title: String? = nil, subtitle: String? = nil, detail: StringSizable? = nil, image: UIImage? = nil) {
        self.init()

        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.image = image
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormDetailCell

        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        cell.detailLabel.apply(sizable: detail, defaultFont: .preferredFont(forTextStyle: .subheadline, compatibleWith: cell.traitCollection), defaultNumberOfLines: 2)
        cell.imageView.image = image
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormDetailCell.minimumContentHeight(withDetail: detail, inWidth: contentWidth, compatibleWith: traitCollection)
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)

        let cell = cell as! CollectionViewFormDetailCell

        cell.titleLabel.textColor = primaryTextColor
        cell.subtitleLabel.textColor = secondaryTextColor
        cell.detailLabel.textColor = primaryTextColor
    }

}

/// MARK: - Chaining methods

extension DetailFormItem {

    @discardableResult
    public func title(_ title: String?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    public func subtitle(_ subtitle: String?) -> Self {
        self.subtitle = subtitle
        return self
    }

    @discardableResult
    public func detail(_ detail: String?) -> Self {
        self.detail = detail
        return self
    }

    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

}
