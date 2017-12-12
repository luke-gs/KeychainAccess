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

    public var imageSeparation: CGFloat = CellImageLabelSeparation

    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation


    // Enforce subtitle cell, but allow subclasses
    public init(cellType: CollectionViewFormSubtitleCell.Type, reuseIdentifier: String) {
        super.init(cellType: cellType, reuseIdentifier: reuseIdentifier)
    }

    public convenience init(title: StringSizable? = nil, subtitle: StringSizable? = nil, image: UIImage? = nil, style: CollectionViewFormSubtitleStyle = .default) {
        self.init(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: CollectionViewFormSubtitleCell.defaultReuseIdentifier)

        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.style = style
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormSubtitleCell

        cell.titleLabel.apply(sizable: title, defaultFont: .preferredFont(forTextStyle: .headline, compatibleWith: cell.traitCollection))
        cell.subtitleLabel.apply(sizable: subtitle, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: cell.traitCollection), defaultNumberOfLines: 0)
        cell.imageView.image = image
        cell.style = style
        cell.imageSeparation = imageSeparation
        cell.labelSeparation = labelSeparation
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: defaultTitle(for: traitCollection),
                                                                   subtitle: defaultSubtitle(for: traitCollection),
                                                                   inWidth: contentWidth,
                                                                   compatibleWith: traitCollection,
                                                                   imageSize: image?.size ?? .zero,
                                                                   style: .default,
                                                                   imageSeparation: imageSeparation,
                                                                   labelSeparation: labelSeparation,
                                                                   accessoryViewSize: accessory?.size ?? .zero)
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormSubtitleCell.minimumContentWidth(withTitle: defaultTitle(for: traitCollection),
                                                                  subtitle: defaultSubtitle(for: traitCollection),
                                                                  compatibleWith: traitCollection,
                                                                  imageSize: image?.size ?? .zero,
                                                                  style: .default,
                                                                  imageSeparation: imageSeparation,
                                                                  labelSeparation: labelSeparation,
                                                                  accessoryViewSize: accessory?.size ?? .zero)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)

        let cell = cell as! CollectionViewFormSubtitleCell

        cell.titleLabel.textColor = primaryTextColor
        cell.subtitleLabel.textColor = secondaryTextColor
    }
    
    private func defaultTitle(for traitCollection: UITraitCollection) -> StringSizable? {
        return title?.sizing(defaultFont: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection))
    }
    
    private func defaultSubtitle(for traitCollection: UITraitCollection) -> StringSizable? {
        return subtitle?.sizing(defaultNumberOfLines: 0, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection))
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

    @discardableResult
    public func imageSeparation(_ imageSeparation: CGFloat) -> Self {
        self.imageSeparation = imageSeparation
        return self
    }

    @discardableResult
    public func labelSeparation(_ labelSeparation: CGFloat) -> Self {
        self.labelSeparation = labelSeparation
        return self
    }

}
