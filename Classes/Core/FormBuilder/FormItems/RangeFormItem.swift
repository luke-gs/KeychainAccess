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

    public var range: CountableClosedRange<Int> = 0...1 {
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

class NumberRangeAction: ValueSelectionAction<CountableClosedRange<Int>>, NumberRangePickerDelegate {

    public var range: CountableClosedRange<Int> = 0...1

    public override func viewController() -> UIViewController {
        if selectedValue == nil {
            selectedValue = range
            updateHandler?()
        }
        
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
