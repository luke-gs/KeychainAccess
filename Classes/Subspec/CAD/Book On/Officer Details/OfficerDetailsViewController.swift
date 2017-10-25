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
        
        builder += HeaderFormItem(text: "OFFICER DETAILS", style: .plain)
        
        builder += TextFieldFormItem(title: "Contact Number", text: nil)
            .width(.column(2))
            .required("Contact number is required.")
            .onValueChanged {
                self.viewModel.officerDetails.contactNumber = $0
        }
        
        builder += DropDownFormItem(title: "License")
            .options(["Gold", "Silver"])
            .required()
            .allowsMultipleSelection(false)
            .width(.column(2))
            .onValueChanged {
                self.viewModel.officerDetails.license = $0?.first
        }
        
        builder += TextFieldFormItem(title: "Capabilities")
            .width(.column(1))
            .onValueChanged {
                self.viewModel.officerDetails.capabilities = $0
        }
        
        builder += TextFieldFormItem(title: "Remarks")
            .width(.column(1))
            .onValueChanged {
                self.viewModel.officerDetails.remarks = $0
        }
        
        builder += OptionFormItem(title: "This officer is the driver")
            .width(.column(1))
            .onValueChanged {
                self.viewModel.officerDetails.driver = $0
        }
    }
    
    @objc func doneButtonTapped () {
        let result = builder.validate()
        
        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            firstly {
                return viewModel.submitForm()
                }.then { status in
                    self.navigationController?.popViewController(animated: true)
                }.catch { error in
                    let title = NSLocalizedString("Failed to submit form", comment: "")
                    AlertQueue.shared.addSimpleAlert(title: title, message: error.localizedDescription)
            }
        }
    }
    
    @objc func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

