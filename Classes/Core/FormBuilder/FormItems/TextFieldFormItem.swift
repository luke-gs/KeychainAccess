//
//  TextFieldFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 21/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class TextFieldFormItem: BaseFormItem, FormValidatable {

    public var title: StringSizable?

    public var text: StringSizable?

    public var placeholder: StringSizable?

    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation

    public var onValueChanged: ((String?) -> ())?

    public var isRequired: Bool {
        return requiredSpecification != nil
    }

    public init() {
        super.init(cellType: CollectionViewFormTextFieldCell.self, reuseIdentifier: CollectionViewFormTextFieldCell.defaultReuseIdentifier)

        contentMode = .top
        selectionStyle = .underline
    }

    public convenience init(title: StringSizable?, text: StringSizable? = nil, placeholder: StringSizable? = nil) {
        self.init()

        self.title = title
        self.text = text
        self.placeholder = placeholder
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormTextFieldCell
        cell.labelSeparation = labelSeparation

        let traitCollection = cell.traitCollection

        let titleLabel = cell.titleLabel
        titleLabel.apply(sizable: self.title, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection))

        if isRequired {
            titleLabel.makeRequired(with: title)
        }

        let textField = cell.textField
        textField.applyText(sizable: text, defaultFont: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection))
        textField.applyPlaceholder(sizable: placeholder ?? defaultPlaceholderTextForCurrentState(), defaultFont: .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection))

        textField.allTargets.forEach {
            textField.removeTarget($0, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        }
        textField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        textField.delegate = self

        textField.autocapitalizationType = autocapitalizationType
        textField.autocorrectionType = autocorrectionType
        textField.spellCheckingType = spellCheckingType
        textField.keyboardType = keyboardType
        textField.keyboardAppearance = keyboardAppearance
        textField.returnKeyType = returnKeyType
        textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        textField.isSecureTextEntry = secureTextEntry
        textField.textContentType = textContentType
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {

        var title = self.title?.sizing()
        if isRequired {
            title?.makeRequired()
        }

        return CollectionViewFormTextFieldCell.minimumContentWidth(withTitle: title, enteredText: text, placeholder: placeholder, compatibleWith: traitCollection, accessoryViewSize: .zero)
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {

        var title = self.title?.sizing()
        if isRequired {
            title?.makeRequired()
        }

        return CollectionViewFormTextFieldCell.minimumContentHeight(withTitle: title, enteredText: text, inWidth: contentWidth, compatibleWith: traitCollection, labelSeparation: labelSeparation, accessoryViewSize: .zero)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)
        let placeholderTextColor = theme.color(forKey: .placeholderText)

        let cell = cell as! CollectionViewFormTextFieldCell

        cell.titleLabel.textColor = secondaryTextColor
        if isRequired {
            cell.titleLabel.makeRequired(with: title)
        }

        cell.textField.textColor = primaryTextColor
        cell.textField.placeholderTextColor = placeholderTextColor
    }

    // MARK: - Private

    private func defaultPlaceholderTextForCurrentState() -> String? {
        return FormRequired.default.placeholder(withRequired: isRequired)
    }

    // MARK: - Form validatable

    public private(set) var validator = Validator()

    public var candidate: Any? { return text?.sizing().string.ifNotEmpty() }

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

    // MARK: - Text input traits

    public var autocapitalizationType: UITextAutocapitalizationType = .sentences

    public var autocorrectionType: UITextAutocorrectionType = .default

    public var spellCheckingType: UITextSpellCheckingType = .default

    public var keyboardType: UIKeyboardType = .default

    public var keyboardAppearance: UIKeyboardAppearance = .default

    public var returnKeyType: UIReturnKeyType = .default

    public var enablesReturnKeyAutomatically: Bool = false

    public var secureTextEntry: Bool = false

    public var textContentType: UITextContentType? = nil

}

extension TextFieldFormItem: UITextFieldDelegate {

    @objc fileprivate func textFieldTextDidChange(_ textField: UITextField) {
        let newText = textField.text
        if var sizing = text as? StringSizing {
            sizing.string = newText ?? ""
            text = sizing
        } else {
            text = newText
        }

        validator.validateAndUpdateErrorIfNeeded(newText?.ifNotEmpty(), shouldInstallTimer: true, checkSubmitRule: false, forItem: self)
        onValueChanged?(newText)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string)
        return validator.validateAndUpdateErrorIfNeeded(newText.ifNotEmpty(), shouldInstallTimer: true, checkSubmitRule: false, forItem: self)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if validator.validateAndUpdateErrorIfNeeded(candidate, shouldInstallTimer: false, checkSubmitRule: true, forItem: self) {
            textField.resignFirstResponder()
        }
        return false
    }

    public func reloadSubmitValidationState() {
        let shouldCheck = candidate != nil || isRequired
        validator.validateAndUpdateErrorIfNeeded(candidate, shouldInstallTimer: false, checkSubmitRule: shouldCheck, forItem: self)
    }

    public func validateValueForSubmission() -> ValidateResult {
        let shouldCheck = candidate != nil || isRequired
        return validator.validate(candidate, checkHardRule: shouldCheck, checkSoftRule: shouldCheck, checkSubmitRule: shouldCheck)
    }

    public func reloadLiveValidationState() {
        validator.validateAndUpdateErrorIfNeeded(candidate, shouldInstallTimer: false, checkSubmitRule: false, forItem: self)
    }

}


// MARK: - Chaining methods

extension TextFieldFormItem {

    @discardableResult
    public func title(_ title: StringSizable?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    public func text(_ text: StringSizable?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    public func placeholder(_ placeholder: StringSizable?) -> Self {
        self.placeholder = placeholder
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
    public func labelSeparation(_ labelSeparation: CGFloat) -> Self {
        self.labelSeparation = labelSeparation
        return self
    }

    @discardableResult
    public func softValidate(_ specification: Specification, message: String) -> Self {
        let rule = ValidatorRule.soft(specification: specification, message: message)
        rules.append(rule)
        validator.addRule(rule)
        return self
    }

    @discardableResult
    public func strictValidate(_ specification: Specification, message: String) -> Self {
        let rule = ValidatorRule.strict(specification: specification, message: message)
        rules.append(rule)
        validator.addRule(rule)
        return self
    }

    @discardableResult
    public func submitValidate(_ specification: Specification, message: String) -> Self {
        let rule = ValidatorRule.submit(specification: specification, message: message)
        rules.append(rule)
        validator.addRule(rule)
        return self
    }

    @discardableResult
    public func onValueChanged(_ onValueChanged: ((String?) -> ())?) -> Self {
        self.onValueChanged = onValueChanged
        return self
    }

    @discardableResult
    public func autocapitalizationType(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        self.autocapitalizationType = autocapitalizationType
        return self
    }

    @discardableResult
    public func autocorrectionType(_ autocorrectionType: UITextAutocorrectionType) -> Self {
        self.autocorrectionType = autocorrectionType
        return self
    }

    @discardableResult
    public func spellCheckingType(_ spellCheckingType: UITextSpellCheckingType) -> Self {
        self.spellCheckingType = spellCheckingType
        return self
    }

    @discardableResult
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        self.keyboardType = keyboardType
        return self
    }

    @discardableResult
    public func keyboardAppearance(_ keyboardAppearance: UIKeyboardAppearance) -> Self {
        self.keyboardAppearance = keyboardAppearance
        return self
    }

    @discardableResult
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        self.returnKeyType = returnKeyType
        return self
    }

    @discardableResult
    public func enablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
        self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        return self
    }

    @discardableResult
    public func secureTextEntry(_ secureTextEntry: Bool) -> Self {
        self.secureTextEntry = secureTextEntry
        return self
    }

    @discardableResult
    public func textContentType(_ textContentType: UITextContentType?) -> Self {
        self.textContentType = textContentType
        return self
    }

}
