//
//  SummaryThumbnailFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 21/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class SummaryThumbnailFormItem: BaseFormItem {

    public var style: EntityCollectionViewCell.Style

    public var category: String?

    public var title: String?

    public var subtitle: String?

    public var detail: String?

    public var badge: UInt = 0

    public var badgeColor: UIColor?

    public var borderColor: UIColor?
    
    public var imageTintColor: UIColor?

    public var image: ImageLoadable?


    public init(style: EntityCollectionViewCell.Style = .hero) {
        self.style = style

        super.init(cellType: EntityCollectionViewCell.self, reuseIdentifier: EntityCollectionViewCell.defaultReuseIdentifier)

        separatorStyle = .none
        highlightStyle = .fade
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! EntityCollectionViewCell

        cell.style = style
        cell.sourceLabel.text = category
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        cell.detailLabel.text = detail
        cell.borderColor = badgeColor
        cell.badgeCount = badge
        cell.thumbnailView.borderColor = borderColor
        cell.thumbnailView.tintColor = imageTintColor

        if let sizing = image?.sizing() {
            cell.thumbnailView.imageView.image = sizing.image
            cell.thumbnailView.imageView.contentMode = sizing.contentMode ?? .center
        }

        image?.loadImage(completion: { (imageSizable) in
            let sizing = imageSizable.sizing()
            cell.thumbnailView.imageView.image = sizing.image
            cell.thumbnailView.imageView.contentMode = sizing.contentMode ?? .center
        })
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return EntityCollectionViewCell.minimumContentWidth(forStyle: style)
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return EntityCollectionViewCell.minimumContentHeight(forStyle: style, compatibleWith: traitCollection)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)

        let cell = cell as! EntityCollectionViewCell

        cell.titleLabel.textColor    = primaryTextColor
        cell.subtitleLabel.textColor = secondaryTextColor
        cell.detailLabel.textColor   = secondaryTextColor
    }

}

// MARK: - Chaining methods

extension SummaryThumbnailFormItem {
    
    @discardableResult
    public func decorate(_ displayable: EntitySummaryDisplayable) -> Self {
        self.title = displayable.title
        self.subtitle = displayable.detail1
        self.detail = displayable.detail2
        self.category = displayable.category
        self.badge = displayable.badge
        self.borderColor = displayable.borderColor
        self.badgeColor = displayable.borderColor
        self.highlightStyle = .fade
        self.image = displayable.thumbnail(ofSize: style == .hero ? .large : .medium)
        self.imageTintColor = displayable.iconColor
        return self
    }

    @discardableResult
    public func style(_ style: EntityCollectionViewCell.Style) -> Self {
        self.style = style
        return self
    }

    @discardableResult
    public func category(_ category: String?) -> Self {
        self.category = category
        return self
    }

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
    public func badge(_ badge: UInt) -> Self {
        self.badge = badge
        return self
    }

    @discardableResult
    public func badgeColor(_ badgeColor: UIColor?) -> Self {
        self.badgeColor = badgeColor
        return self
    }

    @discardableResult
    public func borderColor(_ borderColor: UIColor?) -> Self {
        self.borderColor = borderColor
        return self
    }
    
    @discardableResult
    public func imageTintColor(_ imageTintColor: UIColor?) -> Self {
        self.imageTintColor = imageTintColor
        return self
    }

    @discardableResult
    public func image(_ image: ImageLoadable?) -> Self {
        self.image = image
        return self
    }

}
