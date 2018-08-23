//
//  ImageDetailFormItem.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class ImageDetailFormItem: BaseSupplementaryFormItem {

    public var layoutMargins: UIEdgeInsets? = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0)

    public var image: UIImage?

    public var title: StringSizable?

    public var titleColorKey: Theme.ColorKey?

    public var description: StringSizable?

    public var descriptionColorKey: Theme.ColorKey?

    public var separatorColor: UIColor?

    public init() {
        super.init(viewType: CollectionViewImageDetailView.self, kind: UICollectionElementKindSectionHeader, reuseIdentifier: CollectionViewImageDetailView.defaultReuseIdentifier)
    }

    public convenience init(image: UIImage? = nil,
                            title: StringSizable? = nil,
                            description: StringSizable? = nil) {
        self.init()
        self.image = image
        self.title = title
        self.description = description
    }

    public override func configure(_ view: UIView) {
        let view = view as! CollectionViewImageDetailView
        let fonts = CollectionViewImageDetailView.defaultFonts(compatibleWith: view.traitCollection)

        if let layoutMargins = layoutMargins {
            view.layoutMargins = layoutMargins
        }

        view.imageView.image = image
        view.titleLabel.apply(sizable: title, defaultFont: fonts.titleFont, defaultNumberOfLines: 1)
        view.descriptionLabel.apply(sizable: description, defaultFont: fonts.descriptionFont, defaultNumberOfLines: 1)
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, for traitCollection: UITraitCollection) -> CGFloat {

        var size: CGFloat = 0

        if let image = image {
            size += image.size.height
        }

        if let title = title {
            size += title
                .sizing(defaultNumberOfLines: 1, defaultFont: CollectionViewImageDetailView.defaultFont)
                .minimumHeight(inWidth: collectionView.bounds.width, compatibleWith: traitCollection)
        }

        if let description = description {
            size += description
                .sizing(defaultNumberOfLines: 1, defaultFont: CollectionViewImageDetailView.defaultFont)
                .minimumHeight(inWidth: collectionView.bounds.width, compatibleWith: traitCollection)
        }

        if let layoutMargins = layoutMargins {
            size += layoutMargins.top + layoutMargins.bottom
        }

        return size
    }

    public override func apply(theme: Theme, toView view: UICollectionReusableView) {
        let view = view as! CollectionViewImageDetailView

        let separatorColor = self.separatorColor ?? theme.color(forKey: .separator)

        view.separatorView.backgroundColor = separatorColor

        // set title text color
        if let titleColorAttrib = (title?.sizing().attributedString?.attributeIfExists(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor) {
            view.titleLabel.textColor = titleColorAttrib
        } else {
            view.titleLabel.textColor = theme.color(forKey: titleColorKey ?? .primaryText)
        }

        // set description text color
        if let descriptionColorAttrib = (description?.sizing().attributedString?.attributeIfExists(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor) {
            view.titleLabel.textColor = descriptionColorAttrib
        } else {
            view.descriptionLabel.textColor = theme.color(forKey: descriptionColorKey ?? .secondaryText)
        }
    }
}

// MARK: - Chaining methods

extension ImageDetailFormItem {

    @discardableResult
    public func layoutMargins(_ layoutMargins: UIEdgeInsets?) -> Self {
        self.layoutMargins = layoutMargins
        return self
    }

    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    public func title(_ title: String?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    public func titleColorKey(_ titleColorKey: Theme.ColorKey?) -> Self {
        self.titleColorKey = titleColorKey
        return self
    }

    @discardableResult
    public func description(_ description: String?) -> Self {
        self.description = description
        return self
    }

    @discardableResult
    public func descriptionColorKey(_ descriptionColorKey: Theme.ColorKey?) -> Self {
        self.descriptionColorKey = descriptionColorKey
        return self
    }

    @discardableResult
    public func separatorColor(_ color: UIColor?) -> Self {
        self.separatorColor = color
        return self
    }

}

