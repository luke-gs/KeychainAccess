//
//  DropDownFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 18/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class DropDownFormItem<T: Pickable>: BaseFormItem, DefaultReusable, FormValidatable, SelectionActionable {

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

    public var dropDownTitle: String?

    public var selectedIndexes: IndexSet?

    public var options: [T] = []

    public var formatter: (([T]) -> String)?

    public var onValueChanged: (([T]) -> ())?

    public var allowsMultipleSelection: Bool = false


    public var selectionAction: SelectionAction? {
        let action = PickerAction<T>(title: dropDownTitle ?? title?.sizing().string ?? "Options",
                                            options: options,
                                            selectedIndexes: selectedIndexes,
                                            allowsMultipleSelection: allowsMultipleSelection)

        action.updateHandler = { [weak self] in
            guard let `self` = self, let action = self.action else { return }
            self.selectedIndexes = action.selectedIndexes
            self.reloadLiveValidationState()

            let selectedOptions: [T]
            if let selectedIndexes = self.selectedIndexes {
                selectedOptions = self.options[selectedIndexes]
            } else {
                selectedOptions = []
            }

            self.onValueChanged?(selectedOptions)
            self.reloadItem()
        }
        self.action = action
        return action
    }

    private var action: PickerAction<T>?

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
        if let selected = selectedIndexes {
            if let formatter = formatter {
                value = formatter(options[selected])
            } else {
                value = options[selected].flatMap({ return $0.title }).joined(separator: ", ")
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

extension DropDownFormItem {

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
    public func options(_ options: [T]) -> Self {
        self.options = options
        return self
    }

    @discardableResult
    public func selectedIndexes(_ selectedIndexes: IndexSet?) -> Self {
        self.selectedIndexes = selectedIndexes
        return self
    }

    @discardableResult
    public func formatter(_ formatter: @escaping (([T]) -> String)) -> Self {
        self.formatter = formatter
        return self
    }

    @discardableResult
    public func allowsMultipleSelection(_ allowsMultipleSelection: Bool) -> Self {
        self.allowsMultipleSelection = allowsMultipleSelection
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
    public func onValueChanged(_ onValueChanged: @escaping (([T]?) -> ())) -> Self {
        self.onValueChanged = onValueChanged
        return self
    }

}
