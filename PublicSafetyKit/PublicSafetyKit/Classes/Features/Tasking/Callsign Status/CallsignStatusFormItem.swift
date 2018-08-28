//
//  CallsignStatusFormItem.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class CallsignStatusFormItem: BaseFormItem {

    public var text: StringSizable?
    public var image: UIImage?
    public var selected: Bool?
    public var layoutMargins: UIEdgeInsets?
    public var displayMode: CallsignStatusDisplayMode = .auto

    public init() {
        super.init(cellType: CallsignStatusCollectionViewFormCell.self, reuseIdentifier: CallsignStatusCollectionViewFormCell.defaultReuseIdentifier)
    }

    public convenience init(text: StringSizable?, image: UIImage?) {
        self.init()
        self.text = text
        self.image = image
    }

    open override func configure(_ cell: CollectionViewFormCell) {
        guard let cell = cell as? CallsignStatusCollectionViewFormCell else { return }

        cell.overridesLayoutMargins = layoutMargins == nil

        if let layoutMargins = layoutMargins {
            cell.contentView.layoutMargins = layoutMargins
        }

        if let sizing = text?.sizing(), let attributedText = sizing.attributedString {
            cell.titleLabel.attributedText = attributedText
            cell.titleLabel.numberOfLines = sizing.numberOfLines ?? 0
        } else {
            cell.titleLabel.apply(sizable: text, defaultFont: CallsignStatusCollectionViewFormCell.defaultFont, defaultNumberOfLines: 0)
        }
        cell.imageView.image = image
        cell.separatorStyle = .none
        cell.displayMode = displayMode
    }

    open override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        guard let cell = cell as? CallsignStatusCollectionViewFormCell else { return }

        cell.imageView.tintColor = selected.isTrue ? theme.color(forKey: .primaryText) : theme.color(forKey: .secondaryText)
        cell.titleLabel.textColor = cell.imageView.tintColor
    }

    open override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        var size: CGFloat = CallsignStatusCollectionViewFormCell.minimumHeight
        guard let text = text else { return size }

        if displayMode.isCompact(for: traitCollection) {
            // Image and text are shown horizontally
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
        if displayMode.isCompact(for: traitCollection) {
            return max(100, (availableWidth / 2) - layout.itemLayoutMargins.left - layout.itemLayoutMargins.right)
        } else {
            return max(100, (availableWidth / 4) - layout.itemLayoutMargins.left - layout.itemLayoutMargins.right)
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
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    public func selected(_ selected: Bool?) -> Self {
        self.selected = selected
        return self
    }

    @discardableResult
    public func layoutMargins(_ layoutMargins: UIEdgeInsets?) -> Self {
        self.layoutMargins = layoutMargins
        return self
    }

    @discardableResult
    public func displayMode(_ displayMode: CallsignStatusDisplayMode) -> Self {
        self.displayMode = displayMode
        return self
    }
}


