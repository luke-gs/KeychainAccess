//
//  SummaryListFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 21/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class SummaryListFormItem: BaseFormItem {

    public var category: String?

    public var title: String?

    public var subtitle: String?

    public var badge: UInt = 0

    public var badgeColor: UIColor?

    public var borderColor: UIColor?

    public var imageTintColor: UIColor?

    public var image: ImageLoadable?

    public init() {
        super.init(cellType: EntityListCollectionViewCell.self, reuseIdentifier: EntityListCollectionViewCell.defaultReuseIdentifier)

        highlightStyle = .enlarge
        selectionStyle = .enlarge
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! EntityListCollectionViewCell

        cell.sourceLabel.text = category
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        cell.borderColor = badgeColor
        cell.actionCount = badge
        cell.thumbnailView.borderColor = borderColor
        cell.thumbnailView.tintColor = imageTintColor

        let sizing = image?.sizing()
        cell.thumbnailView.imageView.image = sizing?.image
        cell.thumbnailView.imageView.contentMode = sizing?.contentMode ?? .center

        image?.loadImage(completion: { (imageSizable) in
            let sizing = imageSizable.sizing()
            cell.thumbnailView.imageView.image = sizing.image
            cell.thumbnailView.imageView.contentMode = sizing.contentMode ?? .center
        })
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return EntityListCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)

        let cell = cell as! EntityListCollectionViewCell
        cell.titleLabel.textColor = primaryTextColor
        cell.subtitleLabel.textColor = secondaryTextColor
    }

}


// MARK: - Chaining methods

extension SummaryListFormItem {

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
