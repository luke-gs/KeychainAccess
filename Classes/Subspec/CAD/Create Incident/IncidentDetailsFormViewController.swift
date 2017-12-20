//
//  IncidentDetailsFormViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentDetailsFormViewController: IntrinsicHeightFormBuilderViewController {

    private var viewModel: CreateIncidentViewModel
    
    public init(viewModel: CreateIncidentViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: NSLocalizedString("Incident Details", comment: "").uppercased())

        builder += DropDownFormItem(title: NSLocalizedString("Priority", comment: ""))
            .options(viewModel.priorityOptions)
            .selectedValue([viewModel.contentViewModel.priority?.rawValue].removeNils())
            .placeholder("Select")
            .required("Priority is required.")
            .allowsMultipleSelection(false)
            .width(.column(4))
            .onValueChanged { [unowned self] in
                if let value = $0?.first {
                    self.viewModel.contentViewModel.priority = IncidentGrade(rawValue: value)
                }
            }
        
        builder += DropDownFormItem(title: NSLocalizedString("Primary Code", comment: ""))
            .options(viewModel.primaryCodeOptions)
            .selectedValue([viewModel.contentViewModel.primaryCode].removeNils())
            .placeholder("Select")
            .required("Primary Code is required.")
            .allowsMultipleSelection(false)
            .width(.column(3))
            .onValueChanged { [unowned self] in
                self.viewModel.contentViewModel.primaryCode = $0?.first
            }
        
        builder += DropDownFormItem(title: NSLocalizedString("Secondary Code", comment: ""))
            .options(viewModel.secondaryCodeOptions)
            .selectedValue([viewModel.contentViewModel.secondaryCode].removeNils())
            .allowsMultipleSelection(false)
            .width(.column(3))
            .onValueChanged { [unowned self] in
                self.viewModel.contentViewModel.secondaryCode = $0?.first
            }
        
        builder += ValueFormItem() // TODO: Implement selecting location
            .title("Location")
            .value(viewModel.contentViewModel.location)
            .accessory(FormAccessoryView(style: .disclosure))
            .width(.column(1))
        
        builder += TextFieldFormItem(title: "Description")
            .placeholder("Required")
            .text(viewModel.contentViewModel.description)
            .required("Description is required")
            .onValueChanged { [unowned self] in
                self.viewModel.contentViewModel.description = $0
            }
            .width(.column(1))
        
        builder += HeaderFormItem(text: NSLocalizedString("Informant Details", comment: "").uppercased())
        builder += TextFieldFormItem(title: "Full Name")
            .placeholder("Required")
            .text(viewModel.contentViewModel.informantName)
            .required("Name is required")
            .onValueChanged { [unowned self] in
                self.viewModel.contentViewModel.informantName = $0
            }
            .width(.column(2))
        
        builder += TextFieldFormItem(title: "Contact Number")
            .required("A contact number is required")
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Contact number must be a number")
            .text(viewModel.contentViewModel.informantPhone)
            .onValueChanged { [unowned self] in
                self.viewModel.contentViewModel.informantPhone = $0
            }
            .width(.column(2))
    }
}
