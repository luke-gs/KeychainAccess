//
//  OptionGroupFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 2/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol FormItemContainer {

    var items: [BaseFormItem] { get }

}

public class OptionGroupFormItem: BaseFormItem, FormItemContainer, FormValidatable {

    public var title: StringSizable? {
        didSet {
            updateTitle()
        }
    }

    public var options: [String] = [] {
        didSet {
            guard oldValue != options else { return }
            updateItems()
        }
    }

    public var selectedIndexes: IndexSet = IndexSet()

    public var isRequired: Bool {
        return requiredSpecification != nil
    }

    public var onValueChanged: ((IndexSet) -> ())?

    public var items: [BaseFormItem] {
        var combined: [BaseFormItem] = optionItems
        if let titleItem = titleItem {
            combined.insert(titleItem, at: 0)
        }
        return combined
    }

    // MARK: - Style

    public let optionStyle: CollectionViewFormOptionCell.OptionStyle

    public var imageSeparation: CGFloat = CellImageLabelSeparation

    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation

    // MARK: - Internal items

    private var titleItem: BaseFormItem?
    private var optionItems: [OptionFormItem] = []


    public init(optionStyle: CollectionViewFormOptionCell.OptionStyle, options: [String]) {
        self.optionStyle = optionStyle

        super.init(cellType: CollectionViewFormOptionCell.self, reuseIdentifier: CollectionViewFormOptionCell.defaultReuseIdentifier)

        self.width = .column(1)

        defer {
            self.options = options
        }
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormOptionCell

        cell.imageSeparation = imageSeparation
        cell.labelSeparation = labelSeparation
    }

    // MARK: - Private

    private func updateTitle() {
        if title != nil {
            let titleItem = SubtitleFormItem(title: nil, subtitle: title)
            titleItem.contentMode = .bottom
            titleItem.separatorStyle = .none
            titleItem.width = .column(1)
            titleItem.height = .dynamic { [unowned titleItem] info -> CGFloat in
                return titleItem.intrinsicHeight(in: info.collectionView, layout: info.layout, givenContentWidth: info.contentWidth, for: info.traitCollection) - info.layout.itemLayoutMargins.bottom
            }
            titleItem.onConfigured = { [weak self] (cell) in
                guard let `self` = self, let cell = cell as? CollectionViewFormSubtitleCell else { return }
                if self.isRequired {
                    cell.subtitleLabel.makeRequired(with: self.title)
                }
            }
            titleItem.onThemeChanged = { [weak self] (cell, theme) in
                guard let `self` = self, let cell = cell as? CollectionViewFormSubtitleCell else { return }
                if self.isRequired {
                    cell.subtitleLabel.makeRequired(with: self.title)
                }
            }
            self.titleItem = titleItem
        } else {
            self.titleItem = nil
        }
    }

    private func updateItems() {
        let numberOfOptions = options.count
        optionItems = options.enumerated().map { index, option in
            let isLastItem = (numberOfOptions == index + 1)

            let item = OptionFormItem(title: option)
            item.separatorStyle = isLastItem ? .indented : .none
            item.onConfigured = { [weak self] cell in
                guard let `self` = self else { return }
                self.configure(cell)
            }
            item.width = .column(1)
            item.height = .dynamic { [weak self, unowned item] info -> CGFloat in
                guard let `self` = self else { return 0.0 }

                switch self.height {
                case .intrinsic:
                    return item.intrinsicHeight(in: info.collectionView, layout: info.layout, givenContentWidth: info.contentWidth, for: info.traitCollection) - (!isLastItem ? info.layout.itemLayoutMargins.bottom : 0.0)
                default:
                    return self.minimumContentHeight(in: info.collectionView, layout: info.layout, givenContentWidth: info.contentWidth, for: info.traitCollection)
                }
            }
            item.onThemeChanged = { [weak self] cell, theme in
                guard let `self` = self else { return }
                self.apply(theme: theme, toCell: cell)
            }
            item.onSelection = { [weak self] in
                guard let `self` = self else { return }
                self.onSelection?($0)
            }

            // Option item specific configurations
            item.optionStyle = optionStyle
            item.isChecked = self.selectedIndexes.contains(index)
            item.onValueChanged = { [weak self, unowned item] isChecked in
                guard let `self` = self else { return }
                if self.optionStyle == .radio {
                    self.selectedIndexes.removeAll()
                    self.items.forEach {
                        guard item != $0 else { return }
                        ($0 as? OptionFormItem)?.isChecked = false
                    }
                }

                if isChecked {
                    self.selectedIndexes.insert(index)
                } else {
                    self.selectedIndexes.remove(index)
                }

                self.reloadLiveValidationState()
                self.onValueChanged?(self.selectedIndexes)
            }
            return item
        }
    }

    // MARK: - Form validatable

    public private(set) var validator = Validator()

    public var candidate: Any? { return selectedIndexes }

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
        validator.validateAndUpdateErrorIfNeeded(candidate, shouldInstallTimer: false, checkSubmitRule: true, forItem: items.last ?? self)
    }

    public func reloadLiveValidationState() {
        validator.validateAndUpdateErrorIfNeeded(candidate, shouldInstallTimer: false, checkSubmitRule: false, forItem: items.last ?? self)
    }

    public func validateValueForSubmission() -> ValidateResult {
        return validator.validate(candidate, checkHardRule: true, checkSoftRule: true, checkSubmitRule: true)
    }

}

// MARK: - Chaining methods

extension OptionGroupFormItem {

    @discardableResult
    public func title(_ title: StringSizable?) -> Self {
        self.title = title
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
    public func selectedIndexes(_ selectedIndexes: IndexSet) -> Self {
        self.selectedIndexes = selectedIndexes
        return self
    }

    @discardableResult
    public func options(_ options: [String]) -> Self {
        self.options = options
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
    public func onValueChanged(_ onValueChanged: ((IndexSet) -> ())?) -> Self {
        self.onValueChanged = onValueChanged
        return self
    }

}
