//
//  PickerFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

import Foundation


public class PickerFormItem<T>: BaseFormItem, SelectionActionable, DefaultReusable, FormValidatable {

    public var title: StringSizable?

    public var value: StringSizable?

    public var placeholder: StringSizable?

    public var image: UIImage?

    public var isRequired: Bool {
        return requiredSpecification != nil
    }

    public var imageSeparation: CGFloat = CellImageLabelSeparation

    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation

    public var selectionAction: SelectionAction? {
        return pickerAction
    }

    public var pickerAction: ValueSelectionAction<T>?

    public var onValueChanged: ((T?) -> ())?

    public init() {
        super.init(cellType: CollectionViewFormValueFieldCell.self, reuseIdentifier: PickerFormItem.defaultReuseIdentifier)

        selectionStyle = .underline
        accessory = ItemAccessory.dropDown
    }

    public convenience init(pickerAction: ValueSelectionAction<T>) {
        self.init()

        self.pickerAction = pickerAction
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormValueFieldCell
        let traitCollection = cell.traitCollection

        let titleLabel = cell.titleLabel
        titleLabel.apply(sizable: title ?? pickerAction?.title, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection))

        if isRequired {
            titleLabel.makeRequired(with: title ?? pickerAction?.title)
        }

        cell.valueLabel.apply(sizable: pickerAction?.displayText(), defaultFont: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection))
        cell.placeholderLabel.apply(sizable: placeholder ?? FormRequired.default.dropDownAction, defaultFont: .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection))
        cell.imageView.image = image

        pickerAction?.updateHandler = { [weak self] in
            guard let `self` = self, let pickerAction = self.pickerAction else { return }

            self.reloadLiveValidationState()
            self.onValueChanged?(pickerAction.selectedValue)

            guard let cell = self.cell else { return }
            self.configure(cell)
        }
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {

        var title = (self.title ?? pickerAction?.title)?.sizing()
        if isRequired {
            title?.makeRequired()
        }

        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: pickerAction?.displayText() ?? value, placeholder: placeholder, inWidth: contentWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, imageSeparation: imageSeparation, labelSeparation: labelSeparation, accessoryViewSize: .zero)
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {

        var title = (self.title ?? pickerAction?.title)?.sizing()
        if isRequired {
            title?.makeRequired()
        }

        return CollectionViewFormValueFieldCell.minimumContentWidth(withTitle: title, value: pickerAction?.displayText() ?? value, placeholder: placeholder, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, imageSeparation: CellImageLabelSeparation, accessoryViewSize: .zero)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)
        let placeholderTextColor = theme.color(forKey: .placeholderText)

        let cell = cell as! CollectionViewFormValueFieldCell

        let titleLabel = cell.titleLabel
        titleLabel.textColor = secondaryTextColor

        if isRequired {
            titleLabel.makeRequired(with: title ?? pickerAction?.title)
        }

        cell.valueLabel.textColor = primaryTextColor
        cell.placeholderLabel.textColor = placeholderTextColor
    }

    @discardableResult
    public func pickerAction(_ pickerAction: ValueSelectionAction<T>?) -> Self {
        self.pickerAction = pickerAction
        return self
    }

    @discardableResult
    public func onValueChanged(_ onValueChanged: ((T?) -> ())?) -> Self {
        self.onValueChanged = onValueChanged
        return self
    }

    // MARK: - Validation

    public private(set) var validator = Validator()

    public var candidate: Any? { return pickerAction?.displayText() }

    fileprivate var rules = [ValidatorRule]()

    fileprivate var requiredSpecification: ValidatorRule? {
        didSet {
            updateValidator()
        }
    }

    private func updateValidator() {
        var rules = self.rules
        if let specification = requiredSpecification {
            rules.insert(specification, at: 0)
        }
        validator = Validator(rules: rules)
    }

    public func reloadSubmitValidationState() {
        validator.validateAndUpdateErrorIfNeeded(candidate, shouldInstallTimer: false, checkSubmitRule: true, forItem: self)
    }

    public func reloadLiveValidationState() {
        validator.validateAndUpdateErrorIfNeeded(candidate, shouldInstallTimer: false, checkSubmitRule: false, forItem: self)
    }

    public func validateValueForSubmission() -> ValidateResult {
        return validator.validate(candidate, checkHardRule: true, checkSoftRule: true, checkSubmitRule: true)
    }

}


// MARK: - Chaining methods

extension PickerFormItem {

    @discardableResult
    public func title(_ title: StringSizable?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    public func value(_ value: StringSizable?) -> Self {
        self.value = value
        return self
    }

    @discardableResult
    public func placeholder(_ placeholder: StringSizable?) -> Self {
        self.placeholder = placeholder
        return self
    }

    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    public func required(_ message: String = FormRequired.default.message) -> Self {
        self.requiredSpecification = ValidatorRule.submit(specification: CountSpecification.min(1), message: message)
        return self
    }

    @discardableResult
    public func notRequired() -> Self {
        self.requiredSpecification = nil
        return self
    }

    @discardableResult
    public func imageSeparation(_ separation: CGFloat) -> Self {
        self.imageSeparation = separation
        return self
    }

    @discardableResult
    public func labelSeparation(_ separation: CGFloat) -> Self {
        self.labelSeparation = separation
        return self
    }


}
