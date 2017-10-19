//
//  PickerFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class PickerFormItem<T>: BaseFormItem, SelectionActionable, DefaultReusable, FormValidatable {

    public var title: StringSizable?

    public var value: StringSizable?

    public var placeholder: StringSizable?

    public var image: UIImage?

    public var isRequired: Bool {
        return requiredSpecification != nil
    }

    // MARK: - Styling

    public var imageSeparation: CGFloat = CellImageLabelSeparation

    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation

    // MARK: - Picker properties

    public var selectionAction: SelectionAction? {
        pickerAction.title = pickerTitle ?? title?.sizing().string
        return pickerAction
    }

    public var pickerAction: ValueSelectionAction<T>

    public var pickerTitle: String?

    public var selectedValue: T? {
        didSet {
            pickerAction.selectedValue = selectedValue
        }
    }

    public var onValueChanged: ((T?) -> ())?

    public var formatter: ((T) -> String)?

    public init(pickerAction: ValueSelectionAction<T>) {
        self.pickerAction = pickerAction

        super.init(cellType: CollectionViewFormValueFieldCell.self, reuseIdentifier: PickerFormItem.defaultReuseIdentifier)

        selectionStyle = .underline
        accessory = ItemAccessory.dropDown

        pickerAction.updateHandler = { [weak self] in
            guard let `self` = self else { return }

            self.selectedValue = self.pickerAction.selectedValue

            self.reloadLiveValidationState()
            self.onValueChanged?(pickerAction.selectedValue)

            guard let cell = self.cell else { return }
            self.configure(cell)
        }
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormValueFieldCell
        let traitCollection = cell.traitCollection

        let titleLabel = cell.titleLabel
        titleLabel.apply(sizable: title ?? pickerAction.title, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection))

        if isRequired {
            titleLabel.makeRequired(with: title ?? pickerAction.title)
        }

        cell.valueLabel.apply(sizable: valueSizing(), defaultFont: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection))
        cell.placeholderLabel.apply(sizable: placeholder ?? FormRequired.default.dropDownAction, defaultFont: .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection))
        cell.imageView.image = image
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {

        var title = (self.title ?? pickerAction.title)?.sizing()
        if isRequired {
            title?.makeRequired()
        }

        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: valueSizing(), placeholder: placeholder, inWidth: contentWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, imageSeparation: imageSeparation, labelSeparation: labelSeparation, accessoryViewSize: .zero)
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {

        var title = (self.title ?? pickerAction.title)?.sizing()
        if isRequired {
            title?.makeRequired()
        }

        return CollectionViewFormValueFieldCell.minimumContentWidth(withTitle: title, value: valueSizing(), placeholder: placeholder, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, imageSeparation: CellImageLabelSeparation, accessoryViewSize: .zero)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)
        let placeholderTextColor = theme.color(forKey: .placeholderText)

        let cell = cell as! CollectionViewFormValueFieldCell

        let titleLabel = cell.titleLabel
        titleLabel.textColor = secondaryTextColor

        if isRequired {
            titleLabel.makeRequired(with: title ?? pickerAction.title)
        }

        cell.valueLabel.textColor = primaryTextColor
        cell.placeholderLabel.textColor = placeholderTextColor
    }

    // MARK: - Private

    private func valueSizing() -> StringSizable? {
        var value: String?
        if let selectedValue = selectedValue {
            if let formatter = formatter {
                value = formatter(selectedValue)
            } else {
                value = pickerAction.displayText()
            }
        }

        var sizing = self.value?.sizing()
        sizing?.string = value ?? ""

        return sizing ?? value
    }

    // MARK: - Validation

    public private(set) var validator = Validator()

    public var candidate: Any? { return value?.sizing().string }

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
    public func selectedValue(_ selectedValue: T?) -> Self {
        self.selectedValue = selectedValue
        return self
    }

    @discardableResult
    public func pickerTitle(_ pickerTitle: String?) -> Self {
        self.pickerTitle = pickerTitle
        return self
    }

    @discardableResult
    public func formatter(_ formatter: ((T) -> String)?) -> Self {
        self.formatter = formatter
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

    @discardableResult
    public func onValueChanged(_ onValueChanged: ((T?) -> ())?) -> Self {
        self.onValueChanged = onValueChanged
        return self
    }

}
