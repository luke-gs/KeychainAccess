//
//  QuantityPickerFormItem.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class QuantityPickerFormItem: PickerFormItem<[QuantityPicked]> {

    private let action: QuantityPickerAction

    public init(viewModel: QuantityPickerViewModel, title: StringSizable?) {
        action = QuantityPickerAction(viewModel: viewModel)
        super.init(pickerAction: action)

        self.accessory = ItemAccessory.disclosure
        self.title = title

        // Format display text for initial values
        action.selectedValue = viewModel.items
        action.updateHandler?()
    }

}

class QuantityPickerAction: ValueSelectionAction<[QuantityPicked]> {

    public var viewModel: QuantityPickerViewModel

    public init(viewModel: QuantityPickerViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public override func viewController() -> UIViewController {
        let viewController = QuantityPickerViewController(viewModel: viewModel)
        viewController.builder.title = title
        viewController.doneHandler = { [weak self] picked in
            viewController.navigationController?.popViewController(animated: true)
            self?.selectedValue = picked
            self?.updateHandler?()
            self?.dismissHandler?()
        }
        viewController.cancelHandler = { [weak self] previousItems in
            viewController.navigationController?.popViewController(animated: true)
            self?.viewModel.items = previousItems
            self?.selectedValue = previousItems
            self?.updateHandler?()
            self?.dismissHandler?()
        }
        viewController.modalPresentationStyle = .none
        return viewController
    }

    public override func displayText() -> String? {
        guard let selectedValue = selectedValue else { return nil }
        return selectedValue.flatMap({ item in
            if let title = item.object.title, item.count > 0 {
                return "\(title) (\(item.count))"
            }
            return nil
        }).joined(separator: ", ")
    }

}
