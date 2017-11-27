//
//  ValueFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 14/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class ValueFormItem: BaseFormItem {

    public var title: StringSizable?

    public var value: StringSizable?

    public var image: UIImage?

    public var imageSeparation: CGFloat = CellImageLabelSeparation

    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation

    public init() {
        super.init(cellType: CollectionViewFormValueFieldCell.self, reuseIdentifier: CollectionViewFormValueFieldCell.defaultReuseIdentifier)
    }

    public convenience init(title: StringSizable? = nil, value: StringSizable? = nil, image: UIImage? =
        nil) {
        self.init()

        self.title = title
        self.value = value
        self.image = image
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormValueFieldCell

        cell.titleLabel.apply(sizable: title, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: cell.traitCollection))
        cell.valueLabel.apply(sizable: value, defaultFont: .preferredFont(forTextStyle: .headline, compatibleWith: cell.traitCollection), defaultNumberOfLines: 0)
        cell.imageView.image = image
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {

        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: value, placeholder: nil, inWidth: contentWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, imageSeparation: imageSeparation, labelSeparation: labelSeparation, accessoryViewSize: accessory?.size ?? .zero)
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormValueFieldCell.minimumContentWidth(withTitle: title, value: value, placeholder: nil, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, imageSeparation: CellImageLabelSeparation, accessoryViewSize: accessory?.size ?? .zero)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let secondaryTextColor = theme.color(forKey: .secondaryText)

        let cell = cell as! CollectionViewFormValueFieldCell

        cell.titleLabel.textColor = secondaryTextColor
        cell.valueLabel.textColor = secondaryTextColor
    }

}

// MARK: - Chaining methods

extension ValueFormItem {

    @discardableResult
    public func title(_ title: StringSizable?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    public func value(_ value: StringSizable?) -> Self {
        self.value = value
        return self
    }

    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    public func imageSeparation(_ separation: CGFloat) -> Self {
        self.imageSeparation = separation
        return self
    }

    @discardableResult
    public func labelSeparation(_ separation: CGFloat) -> Self {
        self.labelSeparation = separation
        return self
    }

}
