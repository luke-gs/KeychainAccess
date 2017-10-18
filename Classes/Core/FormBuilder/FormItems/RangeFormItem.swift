//
//  RangeFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 18/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class RangeFormItem: BaseFormItem, DefaultReusable, FormValidatable, SelectionActionable {

    public var title: StringSizable?

    public var value: StringSizable?

    public var placeholder: StringSizable?

    public var image: UIImage?

    public var imageSeparation: CGFloat = CellImageLabelSeparation

    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation

    public var isRequired: Bool {
        return requiredSpecification != nil
    }

    // MARK: - Range picker properties

    public var rangePickerTitle: String?

    public var selectedRange: CountableClosedRange<Int>?

    public var range: CountableClosedRange<Int> = 0...10

    public var formatter: ((CountableClosedRange<Int>) -> String)?

    public var onValueChanged: ((CountableClosedRange<Int>?) -> ())?


    public var selectionAction: SelectionAction? {
        let action = NumberRangeAction(title: rangePickerTitle ?? title?.sizing().string ?? "Range", range: range, selected: selectedRange)
        action.updateHandler = { [weak self] in
            guard let `self` = self, let action = self.action else { return }
            self.selectedRange = action.selectedValue

            self.reloadLiveValidationState()
            self.onValueChanged?(action.selectedValue)

            self.reloadItem()
        }
        self.action = action
        return action
    }

    private var action: NumberRangeAction?

    public init() {
        super.init(cellType: CollectionViewFormValueFieldCell.self, reuseIdentifier: DateFormItem.defaultReuseIdentifier)

        selectionStyle = .underline
        accessory = ItemAccessory.dropDown
    }

    public convenience init(title: StringSizable?) {
        self.init()
        self.title = title
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormValueFieldCell
        let traitCollection = cell.traitCollection

        let titleLabel = cell.titleLabel
        titleLabel.apply(sizable: title, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection))

        if isRequired {
            titleLabel.makeRequired(with: title)
        }

        let placeholder: StringSizable = self.placeholder ?? FormRequired.default.dropDownAction

        cell.valueLabel.apply(sizable: valueSizing(), defaultFont: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection))
        cell.placeholderLabel.apply(sizable: placeholder, defaultFont: .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection))
        cell.imageView.image = image
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {

        var title = self.title?.sizing()
        if isRequired {
            title?.makeRequired()
        }

        let placeholder: StringSizable = self.placeholder ?? FormRequired.default.dropDownAction
        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: valueSizing(), placeholder: placeholder, inWidth: contentWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, imageSeparation: imageSeparation, labelSeparation: labelSeparation, accessoryViewSize: .zero)
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {

        var title = self.title?.sizing()
        if isRequired {
            title?.makeRequired()
        }

        let placeholder: StringSizable = self.placeholder ?? FormRequired.default.dropDownAction
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
            titleLabel.makeRequired(with: title)
        }

        cell.valueLabel.textColor = primaryTextColor
        cell.placeholderLabel.textColor = placeholderTextColor
    }

    // MARK: - Private

    private func valueSizing() -> StringSizable? {
        var value: String?
        if let range = selectedRange {
            if let formatter = formatter {
                value = formatter(range)
            } else if let min = range.min(), let max = range.max() {
                value = "\(min) - \(max)"
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

extension RangeFormItem {

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
    public func range(_ range: CountableClosedRange<Int>) -> Self {
        self.range = range
        return self
    }

    @discardableResult
    public func selectedRange(_ selectedRange: CountableClosedRange<Int>) -> Self {
        self.selectedRange = selectedRange
        return self
    }

    @discardableResult
    public func formatter(_ formatter: @escaping ((CountableClosedRange<Int>) -> String)) -> Self {
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
    public func onValueChanged(_ onValueChanged: @escaping ((CountableClosedRange<Int>?) -> ())) -> Self {
        self.onValueChanged = onValueChanged
        return self
    }

}
