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
    public func datePickerMode(_ datePickerMode: UIDatePickerMode) -> Self {
        self.datePickerMode = datePickerMode
        return self
    }

    @discardableResult
    public func dateFormatter(_ dateFormatter: DateFormatter) -> Self {
        self.formatter = { return dateFormatter.string(from: $0) }
        return self
    }

}
