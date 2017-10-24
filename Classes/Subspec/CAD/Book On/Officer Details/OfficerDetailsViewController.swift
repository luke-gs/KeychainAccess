//
//  OfficerDetailsViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class OfficerDetailsViewController: FormBuilderViewController {
    
    /// Model
    var officerDetails = OfficerDetails()
    
    /// View Model
    private var viewModel: OfficerDetailsViewModel
    
    /// Less transparent background color to default when used in form sheet, to give contrast for form text
    private let transparentBackgroundColor = UIColor(white: 1, alpha: 0.5)
    
    override open var wantsTransparentBackground: Bool {
        didSet {
            if wantsTransparentBackground && ThemeManager.shared.currentInterfaceStyle == .light {
                view?.backgroundColor = transparentBackgroundColor
            }
        }
    }
    
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
    
    override open func construct(builder: FormBuilder) {
        
        builder += HeaderFormItem(text: "OFFICER DETAILS", style: .plain)
        
        builder += TextFieldFormItem(title: "Contact Number", text: nil)
            .width(.column(2))
            .required("Contact number is required.")
            .onValueChanged {
                self.officerDetails.contactNumber = $0
        }
        
        builder += DropDownFormItem(title: "License")
            .options(["Gold", "Silver"])
            .required()
            .allowsMultipleSelection(false)
            .width(.column(2))
            .onValueChanged {
                self.officerDetails.license = $0?.first
        }
        
        builder += TextFieldFormItem(title: "Capabilities")
            .width(.column(1))
            .onValueChanged {
                self.officerDetails.capabilities = $0
        }
        
        builder += TextFieldFormItem(title: "Remarks")
            .width(.column(1))
            .onValueChanged {
                self.officerDetails.remarks = $0
        }
        
        builder += OptionFormItem(title: "This officer is the driver")
            .width(.column(1))
            .onValueChanged {
                self.officerDetails.driver = $0
        }
    }
    
    
    @objc func doneButtonTapped () {
        navigationController?.popViewController(animated: true)
        // TODO: Save changes
    }
    
    @objc func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

struct OfficerDetails {
    var contactNumber: String?
    var license: String?
    var capabilities: String?
    var remarks: String?
    var driver: Bool?
}
