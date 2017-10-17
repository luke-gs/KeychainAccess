//
//  SubtitleFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 14/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class SubtitleFormItem: BaseFormItem {

    public var title: StringSizable?

    public var subtitle: StringSizable?

    public var image: UIImage?

    public var style: CollectionViewFormSubtitleStyle = .default

    public init() {
        super.init(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: CollectionViewFormSubtitleCell.defaultReuseIdentifier)
    }

    public convenience init(title: StringSizable? = nil, subtitle: StringSizable? = nil, image: UIImage? = nil, style: CollectionViewFormSubtitleStyle = .default) {
        self.init()

        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.style = style
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormSubtitleCell

        cell.titleLabel.apply(sizable: title, defaultFont: .preferredFont(forTextStyle: .headline, compatibleWith: cell.traitCollection))
        cell.subtitleLabel.apply(sizable: subtitle, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: cell.traitCollection))
        cell.imageView.image = image
        cell.style = style
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: contentWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, style: .default, imageSeparation: CellImageLabelSeparation, labelSeparation: CellImageLabelSeparation, accessoryViewSize: accessory?.size ?? .zero)
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormSubtitleCell.minimumContentWidth(withTitle: title, subtitle: subtitle, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, style: .default, imageSeparation: CellImageLabelSeparation, labelSeparation: CellTitleSubtitleSeparation, accessoryViewSize: accessory?.size ?? .zero)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)

        let cell = cell as! CollectionViewFormSubtitleCell

        cell.titleLabel.textColor = primaryTextColor
        cell.subtitleLabel.textColor = secondaryTextColor
    }

}

// MARK: - Chaining methods

extension SubtitleFormItem {

    @discardableResult
    public func title(_ title: StringSizable?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    public func subtitle(_ subtitle: StringSizable?) -> Self {
        self.subtitle = subtitle
        return self
    }

    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    public func style(_ style: CollectionViewFormSubtitleStyle) -> Self {
        self.style = style
        return self
    }

}
