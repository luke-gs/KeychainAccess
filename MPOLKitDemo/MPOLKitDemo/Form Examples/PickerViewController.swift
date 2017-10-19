//
//  PickerViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class PickerViewController: FormBuilderViewController {

    override func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: "PICKER EXAMPLES")

        builder.forceLinearLayout = true

        builder += DropDownFormItem()
            .title("Greeting")
            .options(["Hello", "Bye Bye", "Good Night"])

        builder += DateFormItem()
            .title("Birth Date")
            .dateFormatter(.formDate)

        builder += RangeFormItem()
            .title("Repeats")
            .range(1...10)

        builder += PickerFormItem(pickerAction: RandomValuePicker(options: [1, 2, 3, 4, 5]))
            .title("Custom Picker")


        builder += HeaderFormItem(text: "PICKER EXAMPLES WITH FORMATTER")

        builder += DropDownFormItem()
            .title("Greeting")
            .options(["Hello", "Bye Bye", "Good Night"])
            .formatter({
                return "I say \($0.joined(separator: ", "))"
            })


        builder += DateFormItem()
            .title("Birth Date")
            .formatter({
                return "My birthday is \(DateFormatter.formDate.string(from: $0))"
            })

        builder += RangeFormItem()
            .title("Repeats")
            .range(1...10)
            .formatter({
                return "Say \($0.min()!) to \($0.max()!)"
            })

        builder += PickerFormItem(pickerAction: RandomValuePicker(options: [1, 2, 3, 4, 5]))
            .title("Custom Picker")
            .formatter({ return "You have chosen \($0)"})

    }

}

class RandomValuePicker: ValueSelectionAction<Int> {

    public let options: [Int]

    public init(options: [Int]) {
        self.options = options
        super.init()
    }

    public override func viewController() -> UIViewController {
        var selectedIndexes: IndexSet?
        if let selectedValue = selectedValue {
            if let index = options.index(of: selectedValue) {
                selectedIndexes = IndexSet(integer: index)
            }
        }

        let pickerTableViewController = PickerTableViewController(style: .plain, items: options)
        pickerTableViewController.title = title
        pickerTableViewController.selectedIndexes = selectedIndexes ?? IndexSet()
        pickerTableViewController.selectionUpdateHandler = { [weak self] picker, selectedIndexes in
            self?.selectedValue = self?.options[selectedIndexes].first
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
        return "\(selectedValue)"
    }

}

extension Int: Pickable {

    public var title: String? { return "\(self)" }

    public var subtitle: String? { return nil }

}

