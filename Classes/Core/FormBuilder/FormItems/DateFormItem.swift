//
//  DateFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class DateFormItem: PickerFormItem<Date> {

    // MARK: - Date picker properties

    public var datePickerMode: UIDatePickerMode = .date {
        didSet {
            action.mode = datePickerMode
        }
    }

    public var minimumDate: Date?  {
        didSet {
            action.minimumDate = minimumDate
        }
    }

    public var maximumDate: Date?  {
        didSet {
            action.maximumDate = maximumDate
        }
    }

    public var minuteInterval: Int? {
        didSet {
            action.minuteInterval = minuteInterval
        }
    }

    public var locale: Locale = .current {
        didSet {
            action.locale = locale
        }
    }

    public var timeZone: TimeZone? {
        didSet {
            action.timeZone = timeZone
        }
    }

    public var dateFormatter: DateFormatter? {
        didSet {
            // Use date formatter to create generic display formatter block
            if let dateFormatter = dateFormatter {
                self.formatter = { [weak self] value in
                    return self?.relativeDisplayText(value) ?? dateFormatter.string(from: value)
                }
            } else {
                self.formatter = nil
            }
        }
    }

    private let action = DateAction()

    public init() {
        super.init(pickerAction: action)
    }

    public convenience init(title: StringSizable?) {
        self.init()
        self.title = title
    }

    /// Optional date formatter used to prefix normal date formatter with a relative date
    public var prefixRelativeDateFormatter: DateFormatter?

    /// Support for relative dates when used with a custom date/time format. NSDateFormatter does not support this :(
    public func relativeDisplayText(_ value: Date) -> String? {
        if let dateFormatter = self.dateFormatter, let prefixRelativeDateFormatter = self.prefixRelativeDateFormatter {
            var components: [String] = []
            if let relativeText = value.relativeDateForHuman() {
                components.append(relativeText)
            } else {
                components.append(prefixRelativeDateFormatter.string(from: value))
            }
            components.append(dateFormatter.string(from: value))
            return components.joined(separator: ", ")
        }
        return nil
    }

}

// MARK: - Chaining methods

extension DateFormItem {

    @discardableResult
    public func minimumDate(_ minimumDate: Date?) -> Self {
        self.minimumDate = minimumDate
        return self
    }

    @discardableResult
    public func maximumDate(_ maximumDate: Date?) -> Self {
        self.maximumDate = maximumDate
        return self
    }

    @discardableResult
    public func minuteInterval(_ minuteInterval: Int?) -> Self {
        self.minuteInterval = minuteInterval
        return self
    }

    @discardableResult
    public func datePickerMode(_ datePickerMode: UIDatePickerMode) -> Self {
        self.datePickerMode = datePickerMode
        return self
    }

    @discardableResult
    public func dateFormatter(_ dateFormatter: DateFormatter) -> Self {
        self.dateFormatter = dateFormatter
        return self
    }

    @discardableResult
    public func locale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }

    @discardableResult
    public func timeZone(_ timeZone: TimeZone?) -> Self {
        self.timeZone = timeZone
        return self
    }

    @discardableResult
    public func prefixRelativeDateFormatter(_ prefixRelativeDateFormatter: DateFormatter?) -> Self {
        self.prefixRelativeDateFormatter = prefixRelativeDateFormatter
        return self
    }

}


class DateAction: ValueSelectionAction<Date> {

    public var mode: UIDatePickerMode

    public var minimumDate: Date?

    public var maximumDate: Date?

    public var minuteInterval: Int?

    public var locale: Locale = .current

    public var timeZone: TimeZone?

    public init(mode: UIDatePickerMode = .date, selectedValue: Date? = nil) {
        self.mode = mode

        super.init()

        self.selectedValue = selectedValue
    }

    public override func viewController() -> UIViewController {
        let updateHandler: (Date) -> () = { [weak self] date in
            self?.selectedValue = date
            self?.updateHandler?()
        }

        let dateViewController = PopoverDatePickerViewController()
        dateViewController.title = title
        dateViewController.dateUpdateHandler = updateHandler

        let datePicker = dateViewController.datePicker
        datePicker.date = selectedValue ?? Date()
        datePicker.datePickerMode = mode
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        datePicker.minuteInterval = minuteInterval ?? 1
        datePicker.timeZone = timeZone
        datePicker.locale = locale

        updateHandler(datePicker.date)

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
