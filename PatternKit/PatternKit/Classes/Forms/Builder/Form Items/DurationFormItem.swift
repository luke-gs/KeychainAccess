//
//  DurationFormItem.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class DurationFormItem: PickerFormItem<TimeInterval> {
    
    // MARK: - Date picker properties
    
    public var minuteInterval: Int? {
        didSet {
            action.minuteInterval = minuteInterval
        }
    }

    private let action = DurationAction()
    
    public init() {
        super.init(pickerAction: action)
    }
    
    public convenience init(title: StringSizable?) {
        self.init()
        self.title = title
    }
}

// MARK: - Chaining methods

extension DurationFormItem {
    
    @discardableResult
    public func minuteInterval(_ minuteInterval: Int?) -> Self {
        self.minuteInterval = minuteInterval
        return self
    }
    
    @discardableResult
    public func date(_ date: Date?) -> Self {
        self.action.date = date
        return self
    }
}


class DurationAction: ValueSelectionAction<TimeInterval> {
    
    public var minuteInterval: Int?
    public var date: Date?
    
    public init(selectedValue: TimeInterval? = nil) {
        super.init()
        
        self.selectedValue = selectedValue
    }
    
    var datePicker: UIDatePicker?
    
    public override func viewController() -> UIViewController {
        let dateViewController = PopoverDatePickerViewController(withNowButton: false)
        dateViewController.title = title
        
        let datePicker = dateViewController.datePicker
        datePicker.countDownDuration = selectedValue ?? 0
        datePicker.datePickerMode = .countDownTimer
        datePicker.minuteInterval = minuteInterval ?? 1
        if let date = date {
            datePicker.setDate(date, animated: true)
        } else {
            // Hack to fix bug where first change does not appear
            let date = DateComponents(calendar: Calendar(identifier: .gregorian), hour: 0, minute: 0).date!
            datePicker.setDate(date, animated: true)
        }

        self.datePicker = datePicker
        
        let updateHandler: (Date) -> () = { [weak self, unowned datePicker] _ in
            self?.date = datePicker.date
            self?.selectedValue = datePicker.countDownDuration
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
        guard let timeInterval = datePicker?.countDownDuration else { return nil }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        
        return formatter.string(from: timeInterval)
    }
    
}
