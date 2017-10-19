//
//  RangeFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 18/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class RangeFormItem: PickerFormItem<CountableClosedRange<Int>> {

    // MARK: - Range picker properties

    public var range: CountableClosedRange<Int> = 0...10 {
        didSet {
            action.range = range
        }
    }

    private let action = NumberRangeAction()

    public init() {
        super.init(pickerAction: action)
    }

    public convenience init(title: StringSizable?) {
        self.init()
        self.title = title
    }

}

// MARK: - Chaining methods

extension RangeFormItem {

    @discardableResult
    public func range(_ range: CountableClosedRange<Int>) -> Self {
        self.range = range
        return self
    }

}
