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
    
    // MARK: - View Model
    
    private var viewModel: OfficerDetailsViewModel
    
    // MARK: - View Appearance
    
    /// Less transparent background color to default when used in form sheet, to give contrast for form text
    private let transparentBackgroundColor = UIColor(white: 1, alpha: 0.5)
    
    override open var wantsTransparentBackground: Bool {
        didSet {
            if wantsTransparentBackground && ThemeManager.shared.currentInterfaceStyle == .light {
                view?.backgroundColor = transparentBackgroundColor
            }
        }
    }
    
    override open func apply(_ theme: Theme) {
        super.apply(theme)
        if wantsTransparentBackground && ThemeManager.shared.currentInterfaceStyle == .light {
            view?.backgroundColor = transparentBackgroundColor
        }
    }
    
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
            .text(viewModel.details.contactNumber)
            .required("Contact number is required.")
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Contact number must be a number")
            .onValueChanged {
                self.viewModel.details.contactNumber = $0
            }
        
        builder += DropDownFormItem(title: NSLocalizedString("License", comment: ""))
            .options([NSLocalizedString("Gold", comment: ""), NSLocalizedString("Silver", comment: "")])
            .required()
            .allowsMultipleSelection(false)
            .width(.column(2))
            .selectedValue([viewModel.details.licenseType].removeNils())
            .onValueChanged {
                self.viewModel.details.licenseType = $0?.first
            }
        
        builder += TextFieldFormItem(title: NSLocalizedString("Capabilities", comment: ""))
            .width(.column(1))
            .text(viewModel.details.capabilities)
            .onValueChanged {
                self.viewModel.details.capabilities = $0
            }
        
        builder += TextFieldFormItem(title: NSLocalizedString("Remarks", comment: ""))
            .width(.column(1))
            .text(viewModel.details.remarks)
            .onValueChanged {
                self.viewModel.details.remarks = $0
            }
        
        builder += OptionFormItem(title: NSLocalizedString("This officer is the driver", comment: ""))
            .width(.column(1))
            .isChecked(viewModel.details.isDriver.isTrue)
            .onValueChanged {
                self.viewModel.details.isDriver = $0
            }
    }
    
    @objc func doneButtonTapped () {
        let result = builder.validate()
        
        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            viewModel.saveForm()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func cancelButtonTapped() {
        viewModel.cancelForm()
        navigationController?.popViewController(animated: true)
    }
}

