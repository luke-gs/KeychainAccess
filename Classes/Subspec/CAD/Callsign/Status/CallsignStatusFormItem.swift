//
//  CallsignStatusFormItem.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class CallsignStatusFormItem: BaseFormItem {

    public var text: StringSizable?
    public var textColor: UIColor?
    public var image: UIImage?

    public init() {
        super.init(cellType: CallsignStatusCollectionViewFormCell.self, reuseIdentifier: CallsignStatusCollectionViewFormCell.defaultReuseIdentifier)
    }

    public convenience init(text: StringSizable?, image: UIImage?, textColor: UIColor? = nil) {
        self.init()
        self.text = text
        self.textColor = textColor
        self.image = image
    }

    open override func configure(_ cell: CollectionViewFormCell) {
        guard let cell = cell as? CallsignStatusCollectionViewFormCell else { return }

        if let sizing = text?.sizing(), let attributedText = sizing.attributedString {
            cell.titleLabel.attributedText = attributedText
            cell.titleLabel.numberOfLines = sizing.numberOfLines ?? 0
        } else {
            cell.titleLabel.apply(sizable: text, defaultFont: CallsignStatusCollectionViewFormCell.defaultFont, defaultNumberOfLines: 0)
        }
        cell.imageView.image = image
        cell.separatorStyle = .none
    }

    open override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        guard let cell = cell as? CallsignStatusCollectionViewFormCell else { return }

        if text?.sizing(defaultNumberOfLines: 0, defaultFont: CallsignStatusCollectionViewFormCell.defaultFont).attributedString == nil {
            cell.titleLabel.textColor = textColor ?? theme.color(forKey: .primaryText)
        }
    }

    open override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        var size: CGFloat = CallsignStatusCollectionViewFormCell.minimumHeight
        guard let text = text else { return size }

        if traitCollection.horizontalSizeClass == .compact {
            // Image and text are shown horizontally
            // size += layout.itemLayoutMargins.top + layout.itemLayoutMargins.bottom
        } else {
            // Image and text are shown vertically
            size += text.sizing(defaultNumberOfLines: 0, defaultFont: CallsignStatusCollectionViewFormCell.defaultFont).minimumHeight(
                inWidth: contentWidth, compatibleWith: traitCollection)
            size += CallsignStatusCollectionViewFormCell.imagePadding
        }
        return size
    }

    open override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        let availableWidth = collectionView.bounds.width - sectionEdgeInsets.left - sectionEdgeInsets.right
        if traitCollection.horizontalSizeClass == .compact {
            return (availableWidth / 2) - layout.itemLayoutMargins.left - layout.itemLayoutMargins.right
        } else {
            return (availableWidth / 4) - layout.itemLayoutMargins.left - layout.itemLayoutMargins.right
        }
    }

}

// MARK: - Chaining methods

extension CallsignStatusFormItem {

    @discardableResult
    public func text(_ text: StringSizable?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    public func textColor(_ textColor: UIColor?) -> Self {
        self.textColor = textColor
        return self
    }

    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
}


