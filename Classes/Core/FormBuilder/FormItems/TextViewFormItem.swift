//
//  TextViewFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 22/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class TextViewFormItem: CollectionViewFormItem, FormValidatable {

    public var title: StringSizable?

    public var text: StringSizable?

    public var placeholder: StringSizable?

    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation

    public var onValueChanged: ((String?) -> ())?

    public var isRequired: Bool {
        return requiredSpecification != nil
    }

    public init() {
        super.init(cellType: CollectionViewFormTextViewCell.self, reuseIdentifier: CollectionViewFormTextViewCell.defaultReuseIdentifier)

        contentMode = .top
        selectionStyle = .underline
    }

    public convenience init(title: StringSizable?, text: StringSizable?, placeholder: StringSizable?) {
        self.init()

        self.title = title
        self.text = text
        self.placeholder = placeholder
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormTextViewCell
        let traitCollection = cell.traitCollection

        let titleLabel = cell.titleLabel
        titleLabel.apply(sizable: title, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection))

        if isRequired {
            titleLabel.makeRequired(with: title)
        }

        let textView = cell.textView
        textView.apply(sizable: text, defaultFont: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection))
        textView.placeholderLabel.apply(sizable: placeholder ?? defaultPlaceholderTextForCurrentState(), defaultFont: .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection))
        textView.delegate = self

        textView.autocapitalizationType = autocapitalizationType
        textView.autocorrectionType = autocorrectionType
        textView.spellCheckingType = spellCheckingType
        textView.keyboardType = keyboardType
        textView.keyboardAppearance = keyboardAppearance
        textView.returnKeyType = returnKeyType
        textView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        textView.isSecureTextEntry = secureTextEntry
        textView.textContentType = textContentType
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {

        var title = self.title?.sizing()
        if isRequired {
            title?.makeRequired()
        }

        return CollectionViewFormTextViewCell.minimumContentHeight(withTitle: title, enteredText: text, inWidth: contentWidth, compatibleWith: traitCollection, labelSeparation: labelSeparation, accessoryViewSize: .zero)
    }

    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let primaryTextColor = theme.color(forKey: .primaryText)
        let secondaryTextColor = theme.color(forKey: .secondaryText)
        let placeholderTextColor = theme.color(forKey: .placeholderText)

        let cell = cell as! CollectionViewFormTextViewCell
        let titleLabel = cell.titleLabel
        titleLabel.textColor = secondaryTextColor

        if isRequired {
            titleLabel.makeRequired(with: title)
        }

        cell.textView.textColor = primaryTextColor
        cell.textView.placeholderLabel.textColor = placeholderTextColor
    }

    /// MARK: - Private

    private func defaultPlaceholderTextForCurrentState() -> String? {
        return isRequired ? NSLocalizedString("Required", comment: "Form placeholder text - Required") : NSLocalizedString("Optional", comment: "Form placeholder text - Optional")
    }


    /// MARK: - Form validatable

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

    /// MARK: - Text input traits

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

extension TextViewFormItem: UITextViewDelegate {

    public func textViewDidChange(_ textView: UITextView) {
        var newText = textView.text
        if var sizing = text as? StringSizing {
            sizing.string = newText ?? ""
            self.text = sizing
        } else {
            self.text = newText
        }

        validator.validateAndUpdateErrorIfNeeded(newText?.ifNotEmpty(), shouldInstallTimer: true, checkSubmitRule: false, forItem: self)
        onValueChanged?(newText)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = (textView.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: text)
        return validator.validateAndUpdateErrorIfNeeded(newText.ifNotEmpty(), shouldInstallTimer: true, checkSubmitRule: false, forItem: self)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        validator.validateAndUpdateErrorIfNeeded(candidate, shouldInstallTimer: false, checkSubmitRule: true, forItem: self)
    }

    public func reloadSubmitValidationState() {
        let shouldCheck = candidate != nil || isRequired
        validator.validateAndUpdateErrorIfNeeded(candidate, shouldInstallTimer: false, checkSubmitRule: shouldCheck, forItem: self)
    }

    public func reloadLiveValidationState() {
        validator.validate(candidate, checkHardRule: true, checkSoftRule: true, checkSubmitRule: false)
    }

    public func validateValueForSubmission() -> ValidateResult {
        let shouldCheck = candidate != nil || isRequired
        return validator.validate(candidate, checkHardRule: true, checkSoftRule: true, checkSubmitRule: shouldCheck)
    }

}

/// MARK: - Chaining methods

extension TextViewFormItem {

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
    public func required(_ message: String = "This is required.") -> Self {
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
