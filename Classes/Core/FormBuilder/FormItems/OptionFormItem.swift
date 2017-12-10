//
//  OptionFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 25/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class OptionFormItem: BaseFormItem {

    public var optionStyle: CollectionViewFormOptionCell.OptionStyle = .checkbox

    public var title: StringSizable?

    public var subtitle: StringSizable?

    public var imageSeparation: CGFloat = CellImageLabelSeparation

    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation

    public var isChecked: Bool = false {
        didSet {
            guard let cell = cell as? CollectionViewFormOptionCell else { return }
            cell.isChecked = isChecked
        }
    }

    public var onValueChanged: ((Bool) -> ())?

    public init() {
        super.init(cellType: CollectionViewFormOptionCell.self, reuseIdentifier: CollectionViewFormOptionCell.defaultReuseIdentifier)
        width = .column(1)
    }

    public convenience init(title: StringSizable?, subtitle: StringSizable? = nil) {
        self.init()

        self.title = title
        self.subtitle = subtitle
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormOptionCell

        cell.optionStyle = optionStyle
        cell.isChecked = isChecked
        cell.imageSeparation = imageSeparation
        cell.labelSeparation = labelSeparation

        cell.valueChangedHandler = { [weak self] isChecked in
            guard let `self` = self else { return }

            self.isChecked = isChecked
            self.onValueChanged?(isChecked)
        }

        cell.titleLabel.apply(sizable: title, defaultFont: SelectableButton.font(compatibleWith: cell.traitCollection))
        cell.subtitleLabel.apply(sizable: subtitle, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: cell.traitCollection))
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormOptionCell.minimumContentWidth(withStyle: optionStyle, title: title, subtitle: subtitle, compatibleWith: traitCollection, imageSeparation: imageSeparation, accessoryViewSize: .zero)
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormOptionCell.minimumContentHeight(withStyle: optionStyle, title: title, subtitle: subtitle, inWidth: contentWidth, compatibleWith: traitCollection, imageSeparation: imageSeparation, labelSeparation: labelSeparation, accessoryViewSize: .zero)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)
        
        let cell = cell as! CollectionViewFormOptionCell

        cell.titleLabel.textColor = secondaryTextColor
        cell.subtitleLabel.textColor = primaryTextColor
    }

}

// MARK: - Chaining methods

extension OptionFormItem {

    @discardableResult
    public func optionStyle(_ optionStyle: CollectionViewFormOptionCell.OptionStyle) -> Self {
        self.optionStyle = optionStyle
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
    public func imageSeparation(_ imageSeparation: CGFloat) -> Self {
        self.imageSeparation = imageSeparation
        return self
    }

    @discardableResult
    public func labelSeparation(_ labelSeparation: CGFloat) -> Self {
        self.labelSeparation = labelSeparation
        return self
    }

    @discardableResult
    public func isChecked(_ isChecked: Bool) -> Self {
        self.isChecked = isChecked
        return self
    }

    @discardableResult
    public func onValueChanged(_ onValueChanged: ((Bool) -> (Void))?) -> Self {
        self.onValueChanged = onValueChanged
        return self
    }

}

