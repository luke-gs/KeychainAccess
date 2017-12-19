//
//  OfficerDetailsViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class OfficerDetailsViewController: FormBuilderViewController {
    
    open static var contactPhoneValidation: (specification: Specification, message: String) = (
        specification: AustralianPhoneSpecification(),
        message: NSLocalizedString("Contact number must be a valid Australian phone number", comment: "")
    )
    
    // MARK: - View Model
    
    private var viewModel: OfficerDetailsViewModel
    
    // MARK: - Setup
    
    public init(viewModel: OfficerDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setTitleView(title: viewModel.navTitle(), subtitle: viewModel.navSubtitle())
    }
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.setTitleView(title: self.viewModel.navTitle(), subtitle: self.viewModel.navSubtitle())
        }, completion: nil)
    }
    
    // MARK: - Form
    
    override open func construct(builder: FormBuilder) {
        
        builder += HeaderFormItem(text: NSLocalizedString("OFFICER DETAILS", comment: ""), style: .plain)
        
        builder += TextFieldFormItem(title: NSLocalizedString("Contact Number", comment: ""), text: nil)
            .width(.column(2))
            .text(viewModel.content.contactNumber)
            .keyboardType(.numberPad)
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Contact number must be a number")
            .submitValidate(OfficerDetailsViewController.contactPhoneValidation.specification,
                            message: OfficerDetailsViewController.contactPhoneValidation.message)
            .onValueChanged {
                self.viewModel.content.contactNumber = $0
            }
        
        builder += DropDownFormItem(title: NSLocalizedString("Licence", comment: ""))
            // TODO: get these from manifest
            .options([NSLocalizedString("Gold", comment: ""),
                      NSLocalizedString("Silver", comment: ""),
                      NSLocalizedString("Nil", comment: "")])
            .required("Licence is required.")
            .allowsMultipleSelection(false)
            .width(.column(2))
            .selectedValue([viewModel.content.licenseType].removeNils())
            .onValueChanged {
                self.viewModel.content.licenseType = $0?.first
            }
        
        builder += TextFieldFormItem(title: NSLocalizedString("Capabilities", comment: ""))
            .width(.column(1))
            .text(viewModel.content.capabilities)
            .onValueChanged {
                self.viewModel.content.capabilities = $0
            }
        
        builder += TextFieldFormItem(title: NSLocalizedString("Remarks", comment: ""))
            .width(.column(1))
            .text(viewModel.content.remarks)
            .onValueChanged {
                self.viewModel.content.remarks = $0
            }
        
        builder += OptionFormItem(title: NSLocalizedString("This officer is the driver", comment: ""))
            .width(.column(1))
            .isChecked(viewModel.content.isDriver.isTrue)
            .onValueChanged {
                self.viewModel.content.isDriver = $0
            }
    }
    
    @objc func doneButtonTapped () {
        #if DEBUG
            // Skip validation when debug, to keep devs happy
            viewModel.saveForm()
            if view != nil { return }
        #endif
        
        let result = builder.validate()
        
        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            viewModel.saveForm()
        }
    }
    
    @objc func cancelButtonTapped() {
        viewModel.cancelForm()
        navigationController?.popViewController(animated: true)
    }
}

