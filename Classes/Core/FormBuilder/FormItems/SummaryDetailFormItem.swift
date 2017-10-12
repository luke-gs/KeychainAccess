//
//  SummaryDetailFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class SummaryDetailFormItem: BaseFormItem {

    /// MARK: - Detail properties

    public var category: String?

    public var title: String?

    public var subtitle: String?

    public var detail: String?

    public var isDetailPlaceholder: Bool = false

    public var buttonTitle: String?

    public var borderColor: UIColor?

    public var image: ImageLoadable?

    
    /// MARK: - Custom actions

    public var onImageTapped: (() -> ())?

    public var onButtonTapped: (() -> ())?

    public init() {
        super.init(cellType: EntityDetailCollectionViewCell.self, reuseIdentifier: EntityDetailCollectionViewCell.defaultReuseIdentifier)
        contentMode = .top
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! EntityDetailCollectionViewCell

        cell.sourceLabel.text = category
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        cell.descriptionLabel.text = detail
        cell.isDescriptionPlaceholder = isDetailPlaceholder
        cell.additionalDetailsButton.setTitle(buttonTitle, for: .normal)

        let thumbnailView = cell.thumbnailView
        thumbnailView.borderColor = borderColor
        thumbnailView.imageView.image = image?.sizing().image

        thumbnailView.allTargets.forEach {
            thumbnailView.removeTarget($0, action: #selector(imageTapped), for: .primaryActionTriggered)
        }

        thumbnailView.isEnabled = onImageTapped != nil
        thumbnailView.addTarget(self, action: #selector(imageTapped), for: .primaryActionTriggered)

        cell.additionalDetailsButtonActionHandler =  { [weak self] _ in
            self?.onButtonTapped?()
        }

        image?.requestImage(completion: { (imageSizable) in
            cell.thumbnailView.imageView.image = imageSizable.sizing().image
        })
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: title,
                                                                   subtitle: subtitle,
                                                                   description: isDetailPlaceholder ? nil : detail,
                                                                   descriptionPlaceholder: isDetailPlaceholder ? detail : nil,
                                                                   additionalDetails: buttonTitle,
                                                                   source: category,
                                                                   inWidth: contentWidth,
                                                                   compatibleWith: traitCollection)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)
        let placeholderTextColor = theme.color(forKey: .placeholderText)

        let cell = cell as! EntityDetailCollectionViewCell
        cell.titleLabel.textColor       = primaryTextColor
        cell.subtitleLabel.textColor    = secondaryTextColor
        cell.descriptionLabel.textColor = isDetailPlaceholder ? placeholderTextColor : secondaryTextColor
    }

    @objc private func imageTapped() {
        self.onImageTapped?()
    }

}


/// MARK: - Chaining methods

extension SummaryDetailFormItem {

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
    public func detailPlaceholder(_ isDetailPlaceholder: Bool) -> Self {
        self.isDetailPlaceholder = isDetailPlaceholder
        return self
    }

    @discardableResult
    public func buttonTitle(_ buttonTitle: String?) -> Self {
        self.buttonTitle = buttonTitle
        return self
    }

    @discardableResult
    public func borderColor(_ borderColor: UIColor?) -> Self {
        self.borderColor = borderColor
        return self
    }

    @discardableResult
    public func image(_ image: ImageLoadable?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    public func onImageTapped(_ onImageTapped: (() -> ())?) -> Self {
        self.onImageTapped = onImageTapped
        return self
    }

    @discardableResult
    public func onButtonTapped(_ onButtonTapped: (() -> ())?) -> Self {
        self.onButtonTapped = onButtonTapped
        return self
    }

}
