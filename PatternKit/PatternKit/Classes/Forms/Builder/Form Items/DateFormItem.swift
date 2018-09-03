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

    public var minimumDate: Date? {
        didSet {
            action.minimumDate = minimumDate
        }
    }

    public var maximumDate: Date? {
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

    public var hasNowButton: Bool = false {
        didSet {
            action.hasNowButton = hasNowButton
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
        self.formatter = { return dateFormatter.string(from: $0) }
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
    public func withNowButton(_ hasNowButton: Bool) -> Self {
        self.hasNowButton = hasNowButton
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

    public var hasNowButton: Bool = false

    public init(mode: UIDatePickerMode = .date, selectedValue: Date? = nil) {
        self.mode = mode

        super.init()

        self.selectedValue = selectedValue
    }

    public override func viewController() -> UIViewController {

        let dateViewController = PopoverDatePickerViewController(withNowButton: hasNowButton)
        dateViewController.title = title

        let datePicker = dateViewController.datePicker
        datePicker.date = selectedValue ?? Date()
        datePicker.datePickerMode = mode
        datePicker.minuteInterval = minuteInterval ?? 1
        datePicker.timeZone = timeZone
        datePicker.locale = locale

        let updateHandler: (Date) -> () = { [weak self] date in

            if let minDate = self?.minimumDate, datePicker.date < minDate {
                datePicker.setDate(minDate, animated: true)
                self?.selectedValue = minDate
            } else if let maxDate = self?.maximumDate, datePicker.date > maxDate {
                datePicker.setDate(maxDate, animated: true)
                self?.selectedValue = maxDate
            } else {
                self?.selectedValue = date
            }
            
            self?.updateHandler?()
        }
        dateViewController.dateUpdateHandler = updateHandler

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
        return DateFormatter.preferredDateTimeStyle.string(from: selectedValue)
    }

}
