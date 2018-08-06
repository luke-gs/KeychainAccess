//
//  SubItemFormItem.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class SubItemFormItem: BaseFormItem {

    public var title: StringSizable?

    public var detail: StringSizable?

    public var detailFont: UIFont?

    public var detailColorKey: Theme.ColorKey?

    public var imageTintColor: UIColor?

    public var image: UIImage?

    public var actionButton: UIButton?

    private var actionButtonHandler: ((UIButton) -> Void)?

    public init() {
        super.init(cellType: SubItemCollectionViewCell.self, reuseIdentifier: SubItemCollectionViewCell.defaultReuseIdentifier)

        highlightStyle = .fade
        selectionStyle = .fade
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! SubItemCollectionViewCell

        cell.titleLabel.apply(sizable: title, defaultFont: defaultTitleFont(for: cell.traitCollection), defaultNumberOfLines: 1)
        cell.detailLabel.apply(sizable: detail, defaultFont: detailFont ?? defaultDetailFont(for: cell.traitCollection), defaultNumberOfLines: 1)

        let sizing = image?.sizing()
        cell.imageView.image = sizing?.image
        cell.imageView.contentMode = sizing?.contentMode ?? .right

        cell.actionButton = actionButton
        cell.actionButton?.setTitleColor(cell.tintColor, for: .normal)
        cell.actionButton?.setTitleColor(cell.tintColor?.withAlphaComponent(0.5), for: .highlighted)
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return SubItemCollectionViewCell.minimumContentHeight(withTitle: title?.sizing(defaultNumberOfLines: 1, defaultFont: defaultTitleFont(for: traitCollection)),
                                                                    detail:
                                                                      detail?.sizing(defaultNumberOfLines: 1, defaultFont: defaultSubtitleFont(for: traitCollection)),
                                                                 accessorySize: accessory?.size,
                                                                 inWidth: contentWidth,
                                                                 compatibleWith: traitCollection)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let tintColor = theme.color(forKey: .tint)

        let cell = cell as! SubItemCollectionViewCell
        cell.titleLabel.textColor = UIColor.black
        cell.detailLabel.textColor = theme.color(forKey: detailColorKey ?? .secondaryText)

        cell.actionButton?.setTitleColor(tintColor, for: .normal)
        cell.actionButton?.setTitleColor(tintColor?.withAlphaComponent(0.5), for: .highlighted)
        cell.imageView.tintColor = self.imageTintColor ?? tintColor
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

extension SubItemFormItem {

    @discardableResult
    public func title(_ title: StringSizable?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    public func detail(_ detail: StringSizable?) -> Self {
        self.detail = detail
        return self
    }

    @discardableResult
    public func detailFont(_ detailFont: UIFont?) -> Self {
        self.detailFont = detailFont
        return self
    }

    @discardableResult
    public func detailColorKey(_ detailColorKey: Theme.ColorKey) -> Self {
        self.detailColorKey = detailColorKey
        return self
    }

    @discardableResult
    public func imageTintColor(_ imageTintColor: UIColor?) -> Self {
        self.imageTintColor = imageTintColor
        return self
    }

    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    public func actionButton(title: String, handler: @escaping ((UIButton) -> Void)) -> Self {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
        button.addTarget(self, action: #selector(actionButtonTapped(button:)), for: .touchUpInside)
        self.actionButton = button
        self.actionButtonHandler = handler
        return self
    }

    @objc private func actionButtonTapped(button: UIButton) {
        actionButtonHandler?(button)
    }
}
