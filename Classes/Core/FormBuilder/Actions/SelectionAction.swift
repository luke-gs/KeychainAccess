//
//  SelectionAction.swift
//  MPOLKit
//
//  Created by KGWH78 on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol SelectionActionable {

    var selectionAction: SelectionAction? { get }

}


public protocol SelectionAction: class {

    /// The view controller to be displayed
    ///
    /// - Returns: A view controller
    func viewController() -> UIViewController

    /// This must be called when the view controller is dismissed.
    var dismissHandler: (() -> ())? { get set }

}


open class ValueSelectionAction<T>: SelectionAction {

    public let title: String

    public var selectedValue: T?

    public var updateHandler: (() -> ())?

    public var dismissHandler: (() -> ())?

    public var valueFormatter: ((T) -> String?)?

    public init(title: String) {
        self.title = title
    }

    open func viewController() -> UIViewController {
        MPLRequiresConcreteImplementation()
    }

    open func displayText() -> String? {
        guard let selectedValue = selectedValue else { return nil }

        if let formatter = valueFormatter {
            return formatter(selectedValue)
        }

        return nil
    }

}


public class PickerAction<T: Pickable>: ValueSelectionAction<[T]> {

    public let options: [T]

    public var selectedIndexes: IndexSet?

    public var allowMultipleSelection: Bool

    public override var selectedValue: [T]? {
        get {
            guard let selectedIndexes = selectedIndexes else { return nil }
            return options[selectedIndexes]
        }
        set { }
    }

    public init(title: String, options: [T], selectedIndexes: IndexSet? = nil, allowMultipleSelection: Bool = false) {
        self.options = options
        self.allowMultipleSelection = allowMultipleSelection

        super.init(title: title)

        self.selectedIndexes = selectedIndexes
    }

    public override func viewController() -> UIViewController {
        let pickerTableViewController = PickerTableViewController(style: .plain, items: options)
        pickerTableViewController.title = title
        pickerTableViewController.selectedIndexes = selectedIndexes ?? IndexSet()
        pickerTableViewController.allowsMultipleSelection = allowMultipleSelection
        pickerTableViewController.selectionUpdateHandler = { [weak self] picker, selectedIndexes in
            self?.selectedIndexes = selectedIndexes
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
        guard let selectedIndexes = selectedIndexes else { return nil }

        if let text = super.displayText() {
            return text
        }

        return options[selectedIndexes].flatMap({ return $0.title }).joined(separator: ", ")
    }

}


public class DateAction: ValueSelectionAction<Date> {

    public let mode: UIDatePickerMode

    public let formatter: DateFormatter

    public init(title: String, mode: UIDatePickerMode = .date, selectedValue: Date? = nil, formatter: DateFormatter = .formDateAndTime) {
        self.mode = mode
        self.formatter = formatter

        super.init(title: title)

        self.selectedValue = selectedValue
    }

    public override func viewController() -> UIViewController {
        let dateViewController = PopoverDatePickerViewController()
        dateViewController.title = title
        dateViewController.dateUpdateHandler = { [weak self] date in
            self?.selectedValue = date
            self?.updateHandler?()
        }

        let navigationController = PopoverNavigationController(rootViewController: dateViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.dismissHandler = { [weak self] _ in
            self?.dismissHandler?()
        }

        return navigationController
    }

    public override func displayText() -> String? {
        guard let selectedValue = selectedValue else { return nil }

        if let text = super.displayText() {
            return text
        }

        return formatter.string(from: selectedValue)
    }

}

public class NumberRangeAction: ValueSelectionAction<CountableClosedRange<Int>>, NumberRangePickerDelegate {

    public let range: CountableClosedRange<Int>

    public init(title: String, range: CountableClosedRange<Int>, selected: CountableClosedRange<Int>? = nil) {
        self.range = range

        super.init(title: title)
    }

    public override func viewController() -> UIViewController {
        let min = range.min()!
        let max = range.max()!

        let viewController = NumberRangePickerViewController(min: min, max: max, currentMin: selectedValue?.min() ?? min, currentMax: selectedValue?.max() ?? max)
        viewController.title = title
        viewController.delegate = self

        let navigationController = PopoverNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.dismissHandler = { [weak self] _ in
            self?.dismissHandler?()
        }

        return navigationController
    }

    public override func displayText() -> String? {
        guard let selectedValue = selectedValue else { return nil }

        if let text = super.displayText() {
            return text
        }

        guard let min = selectedValue.min(), let max = selectedValue.max() else { return nil }
        return "\(min) - \(max)"
    }

    public func numberRangePicker(_ numberPicker: NumberRangePickerViewController, didUpdateMinValue minValue: Int, maxValue: Int) {
        selectedValue = minValue...maxValue
        updateHandler?()
    }

    public func numberRangePickerDidSelectNoRange(_ picker: NumberRangePickerViewController) {

    }

}
