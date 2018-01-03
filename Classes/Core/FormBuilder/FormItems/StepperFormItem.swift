//
//  StepperFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class StepperFormItem: BaseFormItem {

    public var title: StringSizable?

    public var minimumValue: Double = 0

    public var maximumValue: Double = 10

    public var value: Double = 0

    public var stepValue: Double = 1

    public var onValueChanged: ((Double) -> ())?

    public var numberOfDecimalPlaces: Int = 0

    public var customValueFont: UIFont?

    public var displaysZeroValue: Bool = true

    public init() {
        super.init(cellType: CollectionViewFormStepperCell.self, reuseIdentifier: CollectionViewFormStepperCell.defaultReuseIdentifier)
        self.selectionStyle = UnderlineStyle.selection()
    }

    public convenience init(title: StringSizable? = nil) {
        self.init()

        self.title = title
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormStepperCell

        cell.displaysZeroValue = displaysZeroValue
        cell.titleLabel.apply(sizable: title, defaultFont: .preferredFont(forTextStyle: .subheadline, compatibleWith: cell.traitCollection))
        cell.textField.font = customValueFont ?? .preferredFont(forTextStyle: .headline, compatibleWith: cell.traitCollection)

        cell.valueChangedHandler = { [weak self] in
            self?.value = $0
            self?.onValueChanged?($0)
        }
        cell.numberOfDecimalPlaces = numberOfDecimalPlaces

        let stepper = cell.stepper
        stepper.maximumValue = maximumValue
        stepper.minimumValue = minimumValue
        stepper.stepValue = stepValue
        stepper.value = value
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormStepperCell.minimumContentHeight(withTitle: title, value: value, valueFont: customValueFont, numberOfDecimalPlaces: numberOfDecimalPlaces, inWidth: contentWidth, compatibleWith: traitCollection, stepperSeparation: CellImageLabelSeparation, labelSeparation: CellImageLabelSeparation, accessoryViewSize: accessory?.size ?? .zero)
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormStepperCell.minimumContentWidth(withTitle: title, value: value, valueFont: customValueFont, numberOfDecimalPlaces: numberOfDecimalPlaces, compatibleWith: traitCollection, stepperSeparation: CellImageLabelSeparation, labelSeparation: CellTitleSubtitleSeparation, accessoryViewSize: accessory?.size ?? .zero)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)

        let cell = cell as! CollectionViewFormStepperCell

        cell.titleLabel.textColor = secondaryTextColor
        cell.textField.textColor = primaryTextColor
    }
}

extension StepperFormItem {

    @discardableResult
    public func title(_ title: StringSizable?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    public func value(_ value: Double) -> Self {
        self.value = value
        return self
    }

    @discardableResult
    public func stepValue(_ stepValue: Double) -> Self {
        self.stepValue = stepValue
        return self
    }

    @discardableResult
    public func minimumValue(_ minimumValue: Double) -> Self {
        self.minimumValue = minimumValue
        return self
    }

    @discardableResult
    public func maximumValue(_ maximumValue: Double) -> Self {
        self.maximumValue = maximumValue
        return self
    }

    @discardableResult
    public func onValueChanged(_ onValueChanged: ((Double) -> ())?) -> Self {
        self.onValueChanged = onValueChanged
        return self
    }

    @discardableResult
    public func numberOfDecimalPlaces(_ numberOfDecimalPlaces: Int) -> Self {
        self.numberOfDecimalPlaces = numberOfDecimalPlaces
        return self
    }

    @discardableResult
    public func customValueFont(_ customValueFont: UIFont?) -> Self {
        self.customValueFont = customValueFont
        return self
    }

    @discardableResult
    public func displaysZeroValue(_ displaysZeroValue: Bool) -> Self {
        self.displaysZeroValue = displaysZeroValue
        return self
    }

}
