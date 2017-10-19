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

    public var title: String?

    public var selectedValue: T?

    public var updateHandler: (() -> ())?

    public var dismissHandler: (() -> ())?

    public init() { }

    open func viewController() -> UIViewController {
        MPLRequiresConcreteImplementation()
    }

    open func displayText() -> String? {
        MPLRequiresConcreteImplementation()
    }

}


public class PickerAction<T: Pickable>: ValueSelectionAction<[T]> where T: Equatable {

    public var options: [T] = []

    public var allowsMultipleSelection: Bool = false

    public override func viewController() -> UIViewController {
        let selectedIndexes = options.indexes { (option) -> Bool in
            return selectedValue?.contains(option) ?? false
        }

        let pickerTableViewController = PickerTableViewController(style: .plain, items: options)
        pickerTableViewController.title = title
        pickerTableViewController.selectedIndexes = selectedIndexes ?? IndexSet()
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


public class DateAction: ValueSelectionAction<Date> {

    public var mode: UIDatePickerMode

    public var minimumDate: Date?

    public var maximumDate: Date?

    public init(mode: UIDatePickerMode = .date, selectedValue: Date? = nil) {
        self.mode = mode

        super.init()

        self.selectedValue = selectedValue
    }

    public override func viewController() -> UIViewController {
        let dateViewController = PopoverDatePickerViewController()
        dateViewController.title = title
        dateViewController.dateUpdateHandler = { [weak self] date in
            self?.selectedValue = date
            self?.updateHandler?()
        }

        let datePicker = dateViewController.datePicker
        datePicker.date = selectedValue ?? Date()
        datePicker.datePickerMode = mode
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate

        let navigationController = PopoverNavigationController(rootViewController: dateViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.dismissHandler = { [weak self] _ in
            self?.dismissHandler?()
        }

        return navigationController
    }

    public override func displayText() -> String? {
        guard let selectedValue = selectedValue else { return nil }
        return DateFormatter.formDateAndTime.string(from: selectedValue)
    }

}

public class NumberRangeAction: ValueSelectionAction<CountableClosedRange<Int>>, NumberRangePickerDelegate {

    public var range: CountableClosedRange<Int> = 1...10

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
        guard let selectedValue = selectedValue, let min = selectedValue.min(), let max = selectedValue.max() else { return nil }
        return "\(min) - \(max)"
    }

    public func numberRangePicker(_ numberPicker: NumberRangePickerViewController, didUpdateMinValue minValue: Int, maxValue: Int) {
        selectedValue = minValue...maxValue
        updateHandler?()
    }

    public func numberRangePickerDidSelectNoRange(_ picker: NumberRangePickerViewController) {

    }

}
