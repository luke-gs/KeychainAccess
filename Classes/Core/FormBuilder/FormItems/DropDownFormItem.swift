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

    private let action = PickerAction<T>()

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
