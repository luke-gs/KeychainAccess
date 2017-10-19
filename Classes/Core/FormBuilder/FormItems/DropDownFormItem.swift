//
//  DropDownFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 18/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class DropDownFormItem<T: Pickable>: PickerFormItem<[T]> where T: Equatable {

    // MARK: - DropDown picker properties

    public var options: [T] = [] {
        didSet {
            action.options = options
        }
    }

    public var allowsMultipleSelection: Bool = false {
        didSet {
            action.allowsMultipleSelection = allowsMultipleSelection
        }
    }

    private let action = DropDownAction<T>()

    public init() {
        super.init(pickerAction: action)
    }

    public convenience init(title: StringSizable?) {
        self.init()
        self.title = title
    }

}

// MARK: - Chaining methods

extension DropDownFormItem {

    @discardableResult
    public func options(_ options: [T]) -> Self {
        self.options = options
        return self
    }

    @discardableResult
    public func allowsMultipleSelection(_ allowsMultipleSelection: Bool) -> Self {
        self.allowsMultipleSelection = allowsMultipleSelection
        return self
    }

}

class DropDownAction<T: Pickable>: ValueSelectionAction<[T]> where T: Equatable {

    public var options: [T] = []

    public var allowsMultipleSelection: Bool = false

    public override func viewController() -> UIViewController {
        let selectedIndexes = options.indexes { (option) -> Bool in
            return selectedValue?.contains(option) ?? false
        }

        let pickerTableViewController = PickerTableViewController(style: .plain, items: options)
        pickerTableViewController.title = title
        pickerTableViewController.selectedIndexes = selectedIndexes
        pickerTableViewController.allowsMultipleSelection = allowsMultipleSelection
        pickerTableViewController.selectionUpdateHandler = { [weak self] picker, selectedIndexes in
            self?.selectedValue = self?.options[selectedIndexes]
            self?.updateHandler?()
        }

        let navigationController = PopoverNavigationController(rootViewController: pickerTableViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.dismissHandler = { [weak self] _ in
            self?.dismissHandler?()
        }

        return navigationController
    }

    public override func displayText() -> String? {
        guard let selectedValue = selectedValue else { return nil }
        return selectedValue.flatMap({ return $0.title }).joined(separator: ", ")
    }

}
