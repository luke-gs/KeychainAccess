//
//  CollectionViewFormStepperCell.swift
//  MPOLKit
//
//  Created by KGWH78 on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

fileprivate var kvoContext = 1
fileprivate var kvoStepperContext = 1

open class CollectionViewFormStepperCell: CollectionViewFormCell, UITextFieldDelegate {

    // MARK: - Public properties

    public let stepper = UIStepper(frame: .zero)

    public let titleLabel = UILabel(frame: .zero)

    public let textField = FormTextField(frame: .zero)

    open var valueChangedHandler: ((Double) -> (Void))?

    open var numberOfDecimalPlaces: Int = 0

    /// The horizontal separation between labels.
    open var labelSeparation: CGFloat = CellTitleSubtitleSeparation {
        didSet {
            if labelSeparation !=~ oldValue {
                setNeedsLayout()
            }
        }
    }

    /// The horizontal separation between labels.
    open var stepperSeparation: CGFloat = CellImageLabelSeparation {
        didSet {
            if labelSeparation !=~ oldValue {
                setNeedsLayout()
            }
        }
    }

    /// The selection state of the cell.
    open override var isSelected: Bool {
        didSet {
            if isSelected && oldValue == false && textField.isEnabled {
                _ = textField.becomeFirstResponder()
            } else if !isSelected && oldValue == true && textField.isFirstResponder {
                DispatchQueue.main.async {
                    _ = self.textField.resignFirstResponder()
                }
            }
        }
    }

    open override func commonInit() {
        super.commonInit()

        let titleLabel = self.titleLabel
        let textField = self.textField
        let stepper = self.stepper

        titleLabel.adjustsFontForContentSizeCategory = true
        textField.adjustsFontForContentSizeCategory = true

        titleLabel.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        textField.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        textField.textAlignment = .right
        textField.keyboardType = .numberPad

        updateTextField()

        let contentView = self.contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        contentView.addSubview(stepper)

        keyPathsAffectingLabelLayout.forEach {
            titleLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
        }

        textField.addObserver(self, forKeyPath: #keyPath(UITextField.font), context: &kvoContext)
        stepper.addTarget(self, action: #selector(stepperValueDidChange), for: .valueChanged)
        textField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        textField.delegate = self

        stepper.addObserver(self, forKeyPath: #keyPath(UIStepper.value), options: [], context: &kvoStepperContext)

        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditingWithNotification(_:)), name: .UITextFieldTextDidBeginEditing, object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditingWithNotification(_:)),   name: .UITextFieldTextDidEndEditing,   object: textField)
    }

    deinit {
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
        }
        textField.removeObserver(self, forKeyPath: #keyPath(UITextField.font), context: &kvoContext)
        stepper.removeObserver(self, forKeyPath: #keyPath(UIStepper.value), context: &kvoStepperContext)
    }

    // MARK: - Private

    @objc private func stepperValueDidChange() {
        updateTextField(force: true)
        notifyValueChange()
    }

    private func notifyValueChange() {
        valueChangedHandler?(stepper.value)
    }

    private func updateTextField(force: Bool = false) {
        if !textField.isFirstResponder || force {
            textField.text = CollectionViewFormStepperCell.textForValue(stepper.value, numberOfDecimalPlaces: numberOfDecimalPlaces)
        }
    }

    private class func textForValue(_ value: Double, numberOfDecimalPlaces: Int) -> String {
        return String(format: "%.\(numberOfDecimalPlaces)f", value)
    }

    // MARK: - Text field delegate

    private let numberFormatter = NumberFormatter()

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string)

        if newText.isEmpty {
            return true
        }

        if numberOfDecimalPlaces > 0 {
            let tokens = newText.split(separator: ".")
            if tokens.count > 2 {
                return false
            }

            if tokens.last == "." {
                return true
            }
        }

        let number = NumberFormatter().number(from: newText)

        return number != nil
    }

    @objc private func textFieldTextDidChange(_ textField: UITextField) {
        guard let text = textField.text, let value = numberFormatter.number(from: text) else {
            return
        }
        stepper.value = value.doubleValue
        notifyValueChange()
    }

    open func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }

    open func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, let value = numberFormatter.number(from: text)?.doubleValue {
            if value > stepper.maximumValue || value < stepper.minimumValue {
                stepper.value = value
                notifyValueChange()
            }
        } else {
            stepper.value = 0
            notifyValueChange()
        }

        updateTextField(force: true)
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    // MARK: - Observer

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            setNeedsLayout()
        } else if context == &kvoStepperContext {
            updateTextField()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // MARK: - Overrides

    open override func layoutSubviews() {
        super.layoutSubviews()

        let contentView = self.contentView
        let displayScale = traitCollection.currentDisplayScale
        let isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft

        var contentRect = contentView.bounds.insetBy(contentView.layoutMargins)
        let contentTrailingEdge = isRightToLeft ? contentRect.minX : contentRect.maxX

        let accessorySize: CGSize

        if let size = self.accessoryView?.frame.size, size.isEmpty == false {
            accessorySize = size
            let inset = size.width + CollectionViewFormCell.accessoryContentInset
            contentRect.size.width -= inset

            if isRightToLeft {
                contentRect.origin.x += inset
            }
        } else {
            accessorySize = .zero
        }

        // work out label sizes
        let maxTextSize = CGSize(width: contentRect.width, height: .greatestFiniteMagnitude)
        let valueSize = textField.sizeThatFits(maxTextSize).constrained(to: maxTextSize)

        let maxTitleSize = CGSize(width: contentRect.width - valueSize.width - labelSeparation, height: .greatestFiniteMagnitude)
        let titleSize = titleLabel.sizeThatFits(maxTitleSize).constrained(to: maxTitleSize)

        let stepperSize = stepper.intrinsicContentSize

        // Work out major content positions
        let centerYOfContent: CGFloat

        let halfContent = max(titleSize.height, valueSize.height, stepperSize.height, accessorySize.height) / 2.0
        let minimumContentCenterY = contentRect.minY + halfContent
        switch contentMode {
        case .bottom, .bottomLeft, .bottomRight:
            centerYOfContent = max(minimumContentCenterY, contentRect.maxY - halfContent)
        case .top, .topLeft, .topRight:
            centerYOfContent = minimumContentCenterY
        default:
            centerYOfContent = max(minimumContentCenterY, contentRect.midY)
        }


        // Position the accessory view
        let accessoryViewFrame = CGRect(origin: CGPoint(x: contentTrailingEdge - (isRightToLeft ? 0.0 : accessorySize.width),
                                                        y: (centerYOfContent - (accessorySize.height / 2.0)).rounded(toScale: displayScale)),
                                        size: accessorySize)

        accessoryView?.frame = accessoryViewFrame

        // Position the labels
        titleLabel.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - titleSize.width : contentRect.minX, y: (centerYOfContent - (titleSize.height / 2.0)).rounded(toScale: displayScale)), size: titleSize)
        stepper.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.minX : contentRect.maxX - stepperSize.width, y: (centerYOfContent - (stepperSize.height / 2.0)).rounded(toScale: displayScale)), size: stepperSize)

        let titleFrame = titleLabel.frame
        let textFieldSize = CGSize(width: stepper.frame.minX - titleFrame.maxX - stepperSeparation - labelSeparation, height: valueSize.height)

        textField.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.minX + stepperSize.width + stepperSeparation : titleFrame.maxX + labelSeparation, y: (centerYOfContent - (valueSize.height / 2.0)).rounded(toScale: displayScale)), size: textFieldSize)

    }

    open class func minimumContentWidth(withTitle title: StringSizable?, value: Double, valueFont: UIFont?, numberOfDecimalPlaces: Int, compatibleWith traitCollection: UITraitCollection, stepperSeparation: CGFloat = CellImageLabelSeparation, labelSeparation: CGFloat = CellTitleSubtitleSeparation, accessoryViewSize: CGSize = .zero) -> CGFloat {
        var titleSizing = title?.sizing()
        if titleSizing != nil {
            if titleSizing!.font == nil {
                titleSizing!.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
            }
            if titleSizing!.numberOfLines == nil {
                titleSizing!.numberOfLines = 1
            }
        }

        let valueString = CollectionViewFormStepperCell.textForValue(value, numberOfDecimalPlaces: numberOfDecimalPlaces)

        var valueSizing = valueString.sizing()
        valueSizing.font = valueFont ?? .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        valueSizing.numberOfLines = 1

        let titleWidth = titleSizing?.minimumWidth(compatibleWith: traitCollection) ?? 0.0
        let valueWidth = valueSizing.minimumWidth(compatibleWith: traitCollection)
        let accessorySpace = accessoryViewSize.isEmpty ? 0.0 : accessoryViewSize.width + CollectionViewFormCell.accessoryContentInset
        let stepperWidth: CGFloat = UIStepper().intrinsicContentSize.width

        return titleWidth + labelSeparation + valueWidth + stepperSeparation + stepperWidth + accessorySpace
    }

    open class func minimumContentHeight(withTitle title: StringSizable?, value: Double, valueFont: UIFont?, numberOfDecimalPlaces: Int, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection, stepperSeparation: CGFloat = CellImageLabelSeparation, labelSeparation: CGFloat = CellTitleSubtitleSeparation, accessoryViewSize: CGSize = .zero) -> CGFloat {
        var titleSizing = title?.sizing()
        if titleSizing != nil {
            if titleSizing!.font == nil {
                titleSizing!.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
            }
            if titleSizing!.numberOfLines == nil {
                titleSizing!.numberOfLines = 1
            }
        }

        let valueString = CollectionViewFormStepperCell.textForValue(value, numberOfDecimalPlaces: numberOfDecimalPlaces)

        var valueSizing = valueString.sizing()
        valueSizing.font = valueFont ?? .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        valueSizing.numberOfLines = 1

        let isAccesssoryEmpty = accessoryViewSize.isEmpty

        let valueWidth = valueSizing.minimumWidth(compatibleWith: traitCollection)

        let availableWidth = width - (isAccesssoryEmpty ? 0.0 : accessoryViewSize.width + CollectionViewFormCell.accessoryContentInset)

        let titleWidth = availableWidth - valueWidth - (title != nil ? labelSeparation : 0.0)

        let valueHeight = valueSizing.minimumHeight(inWidth: availableWidth, compatibleWith: traitCollection)
        let titleHeight = titleSizing?.minimumHeight(inWidth: titleWidth, compatibleWith: traitCollection) ?? 0.0

        let combinedHeight = max(titleHeight, valueHeight).ceiled(toScale: traitCollection.currentDisplayScale)

        let stepperHeight: CGFloat = UIStepper().intrinsicContentSize.height

        return max(combinedHeight, stepperHeight, (isAccesssoryEmpty ? 0.0 : accessoryViewSize.height))
    }

    // MARK: - Accessibility

    open override var accessibilityLabel: String? {
        get { return super.accessibilityLabel?.ifNotEmpty() ?? titleLabel.text }
        set { super.accessibilityLabel = newValue }
    }

    open override var accessibilityValue: String? {
        get {
            if let setValue = super.accessibilityValue {
                return setValue
            }
            let text = textField.text
            if text?.isEmpty ?? true {
                return textField.placeholder
            }
            return text
        }
        set {
            super.accessibilityValue = newValue
        }
    }

    open override var isAccessibilityElement: Bool {
        get {
            if textField.isEditing { return false }
            return super.isAccessibilityElement
        }
        set {
            super.isAccessibilityElement = newValue
        }
    }

    // MARK: - Notifications

    @objc private func textFieldDidBeginEditingWithNotification(_ notification: NSNotification) {
        guard isSelected == false,
            let collectionView = superview(of: UICollectionView.self),
            let indexPath = collectionView.indexPath(for: self) else { return }

        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }

    @objc private func textFieldDidEndEditingWithNotification(_ notification: NSNotification) {
        guard isSelected,
            let collectionView = superview(of: UICollectionView.self),
            let indexPath = collectionView.indexPath(for: self) else { return }

        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }

    /// Custom hitTest so that touches landing above, below or behind the stepper doesn't activate the text field.
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }

        if point.x > stepper.frame.minX {
            return stepper
        }

        return view
    }

}
