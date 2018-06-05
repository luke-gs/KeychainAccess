//
//  FinaliseDetailsViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 24/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class FinaliseDetailsViewController: IntrinsicHeightFormBuilderViewController {

    // MARK: - Properties
    
    /// View model of the view controller
    public let viewModel: FinaliseDetailsViewModel
    
    public init(viewModel: FinaliseDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
        setupNavigationBarButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open func setupNavigationBarButtons() {
        // Create cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        
        // Create done button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(_:)))
    }
    
    /// Form builder implementation
    open override func construct(builder: FormBuilder) {
        builder.title = viewModel.navTitle()
        
        builder += ValueFormItem()
            .title("Primary Code")
            .value(viewModel.primaryCode)
            .width(.column(2))
        builder += DropDownFormItem(title: "Secondary Code")
            .options(viewModel.secondaryCodeOptions)
            .selectedValue([viewModel.secondaryCode].removeNils())
            .required()
            .onValueChanged({ [unowned self] in
                self.viewModel.secondaryCode = $0?.first
            })
            .width(.column(2))
        builder += TextFieldFormItem(title: "Remark")
            .text(viewModel.remark)
            .placeholder("Required")
            .required("Remark is required")
            .onValueChanged({ [unowned self] in
                self.viewModel.remark = $0
            })
            .width(.column(1))
    }
    
    
    @objc private func cancelButtonTapped(_ button: UIBarButtonItem) {
        viewModel.cancel()
        dismissAnimated()
    }
    
    @objc private func doneButtonTapped(_ button: UIBarButtonItem) {
        let result = builder.validate()
        
        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            viewModel.submit()
            dismissAnimated()
        }
    }
}
