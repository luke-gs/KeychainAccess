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

    public var title: StringSizable?

    public var subtitle: StringSizable?

    public var detail: StringSizable?

    public var badge: UInt = 0

    public var badgeColor: UIColor?

    public var borderColor: UIColor?
    
    public var imageTintColor: UIColor?

    public var image: ImageLoadable?

    // MARK: - Customization

    public var titleTextColor: UIColor?

    public var subtitleTextColor: UIColor?

    public var detailTextColor: UIColor?

    public init(style: EntityCollectionViewCell.Style = .hero) {
        self.style = style

        super.init(cellType: EntityCollectionViewCell.self, reuseIdentifier: EntityCollectionViewCell.defaultReuseIdentifier)

        separatorStyle = .none
        highlightStyle = .enlarge
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! EntityCollectionViewCell

        cell.style = style
        cell.sourceLabel.text = category
        cell.titleLabel.apply(sizable: title, defaultFont: defaultTitleFont(for: cell.traitCollection).withSize(20), defaultNumberOfLines: 1)
        cell.subtitleLabel.apply(sizable: subtitle, defaultFont: defaultSubtitleFont(for: cell.traitCollection).withSize(15), defaultNumberOfLines: 1)
        cell.detailLabel.apply(sizable: detail, defaultFont: defaultDetailFont(for: cell.traitCollection), defaultNumberOfLines: 2)
        cell.borderColor = badgeColor
        cell.badgeCount = badge
        cell.thumbnailView.borderColor = borderColor
        cell.thumbnailView.tintColor = imageTintColor

        let sizing = image?.sizing()
        cell.thumbnailView.imageView.image = sizing?.image
        cell.thumbnailView.imageView.contentMode = sizing?.contentMode ?? .center
        

        image?.loadImage(completion: { (imageSizable) in
            let sizing = imageSizable.sizing()
            if self.cell == cell {
                cell.thumbnailView.imageView.image = sizing.image
                cell.thumbnailView.imageView.contentMode = sizing.contentMode ?? .center
            }
        })
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return EntityCollectionViewCell.minimumContentWidth(forStyle: style)
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return EntityCollectionViewCell.minimumContentHeight(forStyle: style,
                                                             title: title?.sizing(defaultNumberOfLines: 1, defaultFont: defaultTitleFont(for: traitCollection)),
                                                             subtitle: subtitle?.sizing(defaultNumberOfLines: 1, defaultFont: defaultSubtitleFont(for: traitCollection)),
                                                             detail: detail?.sizing(defaultNumberOfLines: 2, defaultFont: defaultDetailFont(for: traitCollection)),
                                                             compatibleWith: traitCollection)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = titleTextColor ?? theme.color(forKey: .primaryText)
        let secondaryTextColor = subtitleTextColor ?? theme.color(forKey: style == .detail ? .primaryText : .secondaryText)
        let tertiaryTextColor = detailTextColor ?? theme.color(forKey: .secondaryText)

        let cell = cell as! EntityCollectionViewCell

        cell.titleLabel.textColor    = primaryTextColor
        cell.subtitleLabel.textColor = secondaryTextColor
        cell.detailLabel.textColor   = tertiaryTextColor
    }
    
    private func defaultTitleFont(for traitCollection: UITraitCollection?) -> UIFont {
        return .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
    }
    
    private func defaultSubtitleFont(for traitCollection: UITraitCollection?) -> UIFont {
        return .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
    }
    
    private func defaultDetailFont(for traitCollection: UITraitCollection?) -> UIFont {
        return .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
    }

}

// MARK: - Chaining methods

extension SummaryThumbnailFormItem {

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
    public func detail(_ detail: StringSizable?) -> Self {
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

    @discardableResult
    public func titleTextColor(_ titleTextColor: UIColor?) -> Self {
        self.titleTextColor = titleTextColor
        return self
    }

    @discardableResult
    public func subtitleTextColor(_ subtitleTextColor: UIColor?) -> Self {
        self.subtitleTextColor = subtitleTextColor
        return self
    }

    @discardableResult
    public func detailTextColor(_ detailTextColor: UIColor?) -> Self {
        self.detailTextColor = detailTextColor
        return self
    }

}
